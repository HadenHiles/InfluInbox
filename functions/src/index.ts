/* eslint-disable @typescript-eslint/no-unused-vars */
/* eslint-disable max-len */
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { OAuth2Client } from "google-auth-library";
import { ConfidentialClientApplication } from "@azure/msal-node";
import { encrypt, decrypt } from "./utils/encryption";
import axios from "axios";

admin.initializeApp();
const db = admin.firestore();

interface OAuthLoginData {
  provider: "google" | "microsoft";
  code: string;
  redirectUri: string;
  userId: string;
  recaptchaToken?: string;
}

interface EmailAuthData {
  email: string;
  password: string;
  recaptchaToken?: string;
}

// Environment / secret values (configure as Firebase secrets when deploying)
const FIREBASE_WEB_API_KEY = process.env.FIREBASE_WEB_API_KEY;
const ENCRYPTION_KEY = process.env.ENCRYPTION_KEY || "";
const RECAPTCHA_SECRET = process.env.RECAPTCHA_SECRET || "";

if (!FIREBASE_WEB_API_KEY) {
  functions.logger.warn("FIREBASE_WEB_API_KEY not set - email auth callables will fail.");
}
if (!ENCRYPTION_KEY) {
  functions.logger.warn("ENCRYPTION_KEY not set - encryption will fail.");
}

async function validateRecaptcha(recaptchaToken: string | undefined): Promise<void> {
  if (!RECAPTCHA_SECRET) {
    functions.logger.warn("RECAPTCHA_SECRET missing - skipping reCAPTCHA validation (NOT SECURE FOR PROD)");
    return;
  }
  if (!recaptchaToken) {
    throw new functions.https.HttpsError("failed-precondition", "Missing reCAPTCHA token");
  }
  const params = new URLSearchParams();
  params.append("secret", RECAPTCHA_SECRET);
  params.append("response", recaptchaToken);
  try {
    const resp = await axios.post("https://www.google.com/recaptcha/api/siteverify", params, { headers: { "Content-Type": "application/x-www-form-urlencoded" } });
    const data = resp.data as { success: boolean; score?: number };
    if (!data.success) throw new functions.https.HttpsError("permission-denied", "reCAPTCHA failed");
    if (typeof data.score === "number" && data.score < 0.5) throw new functions.https.HttpsError("permission-denied", "reCAPTCHA score too low");
  } catch (e) {
    if (e instanceof functions.https.HttpsError) throw e;
    functions.logger.error("reCAPTCHA validation error", e);
    throw new functions.https.HttpsError("internal", "reCAPTCHA validation error");
  }
}

/**
 * createUser callable - creates Firebase Auth user with email/password
 * and returns custom token for client sign-in.
 */
export const emailSignUp = functions.https.onCall(async (data: unknown, context) => {
  const { email, password, recaptchaToken } = data as EmailAuthData;
  if (!email || !password) {
    throw new functions.https.HttpsError("invalid-argument", "Email and password required.");
  }
  await validateRecaptcha(recaptchaToken);
  try {
    const userRecord = await admin.auth().createUser({ email, password });
    const customToken = await admin.auth().createCustomToken(userRecord.uid);
    return { uid: userRecord.uid, customToken };
  } catch (e: any) {
    if (e.code === "auth/email-already-exists") {
      throw new functions.https.HttpsError("already-exists", "Email already registered.");
    }
    functions.logger.error("emailSignUp error", e);
    throw new functions.https.HttpsError("internal", "Failed to create user");
  }
});

/**
 * emailSignIn callable - uses Firebase REST API to verify password and returns idToken.
 * We encrypt the refresh token and store it in Firestore `userTokens/{uid}`.
 */
export const emailSignIn = functions.https.onCall(async (data: unknown, context) => {
  const { email, password, recaptchaToken } = data as EmailAuthData;
  if (!email || !password) {
    throw new functions.https.HttpsError("invalid-argument", "Email and password required.");
  }
  if (!FIREBASE_WEB_API_KEY) {
    throw new functions.https.HttpsError("failed-precondition", "Missing FIREBASE_WEB_API_KEY env var");
  }
  await validateRecaptcha(recaptchaToken);
  if (!ENCRYPTION_KEY) {
    throw new functions.https.HttpsError("failed-precondition", "Missing ENCRYPTION_KEY secret");
  }
  try {
    const resp = await axios.post(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${FIREBASE_WEB_API_KEY}`, {
      email,
      password,
      returnSecureToken: true,
    });
    const { localId, idToken, refreshToken } = resp.data;
    const encrypted = encrypt(refreshToken, ENCRYPTION_KEY);
    await db.collection("userTokens").doc(localId).set({
      provider: "password",
      refreshToken: encrypted,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
    return { uid: localId, idToken };
  } catch (e: any) {
    const code = e.response?.data?.error?.message;
    if (code === "EMAIL_NOT_FOUND" || code === "INVALID_PASSWORD") {
      throw new functions.https.HttpsError("not-found", "Invalid credentials");
    }
    functions.logger.error("emailSignIn error", e);
    throw new functions.https.HttpsError("internal", "Sign in failed");
  }
});

export const oauthLogin = functions.https.onCall(async (data: unknown, context) => {
  const { provider, code, redirectUri, userId, recaptchaToken } = data as OAuthLoginData;
  if (!provider || !code || !redirectUri || !userId) {
    throw new functions.https.HttpsError("invalid-argument", "Missing required fields.");
  }
  await validateRecaptcha(recaptchaToken);
  if (!ENCRYPTION_KEY) {
    throw new functions.https.HttpsError("failed-precondition", "Missing ENCRYPTION_KEY secret");
  }
  let tokens: any;
  if (provider === "google") {
    const client = new OAuth2Client(
      process.env.GOOGLE_CLIENT_ID || "",
      process.env.GOOGLE_CLIENT_SECRET || "",
      redirectUri
    );
    const { tokens: googleTokens } = await client.getToken(code);
    tokens = googleTokens;
  } else if (provider === "microsoft") {
    const msalConfig = {
      auth: {
        clientId: process.env.MICROSOFT_CLIENT_ID || "",
        authority: "https://login.microsoftonline.com/common",
        clientSecret: process.env.MICROSOFT_CLIENT_SECRET || "",
      },
    };
    const cca = new ConfidentialClientApplication(msalConfig);
    const msalResponse = await cca.acquireTokenByCode({
      code,
      redirectUri,
      scopes: ["user.read", "mail.read", "offline_access"],
    });
    tokens = msalResponse;
  } else {
    throw new functions.https.HttpsError("invalid-argument", "Unknown provider");
  }
  try {
    const encryptedTokens = encrypt(JSON.stringify(tokens), ENCRYPTION_KEY);
    await db.collection("userTokens").doc(userId).set({
      provider,
      tokens: encryptedTokens,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
  } catch (e) {
    functions.logger.error("Failed to encrypt/store tokens", e);
    throw new functions.https.HttpsError("internal", "Failed to store tokens");
  }
  return { success: true };
});

export const refreshOAuthToken = functions.https.onCall(async (data: unknown, context) => {
  const { userId, provider } = data as { userId: string; provider: "google" | "microsoft" };
  if (!userId || !provider) throw new functions.https.HttpsError("invalid-argument", "userId and provider required");
  if (!ENCRYPTION_KEY) throw new functions.https.HttpsError("failed-precondition", "Missing ENCRYPTION_KEY secret");
  const doc = await db.collection("userTokens").doc(userId).get();
  if (!doc.exists) throw new functions.https.HttpsError("not-found", "No stored tokens for user");
  const dataDoc = doc.data();
  if (!dataDoc?.tokens) throw new functions.https.HttpsError("failed-precondition", "Stored tokens missing");
  let parsed: any;
  try {
    const decrypted = decrypt(dataDoc.tokens, ENCRYPTION_KEY);
    parsed = JSON.parse(decrypted);
  } catch (e) {
    functions.logger.error("Failed to decrypt tokens", e);
    throw new functions.https.HttpsError("internal", "Corrupt token store");
  }
  if (provider === "google") {
    const refreshToken = parsed.refresh_token || parsed.refreshToken;
    if (!refreshToken) throw new functions.https.HttpsError("failed-precondition", "No refresh token available");
    try {
      const params = new URLSearchParams();
      params.append("client_id", process.env.GOOGLE_CLIENT_ID || "");
      params.append("client_secret", process.env.GOOGLE_CLIENT_SECRET || "");
      params.append("grant_type", "refresh_token");
      params.append("refresh_token", refreshToken);
      const resp = await axios.post("https://oauth2.googleapis.com/token", params, { headers: { "Content-Type": "application/x-www-form-urlencoded" } });
      const newTokens = { ...parsed, ...resp.data };
      if (!newTokens.refresh_token) newTokens.refresh_token = refreshToken; // Google may omit
      const encrypted = encrypt(JSON.stringify(newTokens), ENCRYPTION_KEY);
      await db.collection("userTokens").doc(userId).set({
        provider: "google",
        tokens: encrypted,
        refreshedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
      return { success: true, provider: "google", expiresIn: resp.data.expires_in };
    } catch (e) {
      functions.logger.error("Google token refresh failed", e);
      throw new functions.https.HttpsError("internal", "Google token refresh failed");
    }
  } else if (provider === "microsoft") {
    return { success: false, provider: "microsoft", message: "Refresh not implemented yet" };
  } else {
    throw new functions.https.HttpsError("invalid-argument", "Unsupported provider");
  }
});
