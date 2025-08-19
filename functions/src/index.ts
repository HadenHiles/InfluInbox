/* eslint-disable @typescript-eslint/no-unused-vars */
/* eslint-disable max-len */
/* eslint-disable object-curly-spacing */
/* eslint-disable indent */

import { encrypt, decrypt } from "./utils/encryption";
import axios, { AxiosError } from "axios";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { logger } from "firebase-functions";
import * as admin from "firebase-admin";
import { OAuth2Client } from "google-auth-library";
import { ConfidentialClientApplication } from "@azure/msal-node";

admin.initializeApp();
const db = admin.firestore();

/**
 * Fetch a secret value (injected as environment var by Firebase). Throws if missing
 * when required=true so downstream code can rely on a definite string without
 * using non-null assertions.
 * @param {string} name Secret / env var name
 * @param {boolean} required Whether to throw if undefined (default true)
 * @return {string} secret value
 * @throws {HttpsError} if required and missing
 */
function getSecret(name: string, required = true): string {
  const v = process.env[name];
  if (!v) {
    if (required) throw new HttpsError("failed-precondition", `Missing secret: ${name}`);
    return ""; // graceful fallback for optional secrets
  }
  return v;
}

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

interface GoogleOAuthTokens {
  access_token?: string;
  refresh_token?: string;
  expires_in?: number;
  token_type?: string;
  id_token?: string;
  scope?: string;
}

// No top-level secret reads to avoid empty-string capture on build

/**
 * Validate reCAPTCHA token (v2/v3). Skips if secret missing (dev/emulator).
 * @param {string | undefined} recaptchaToken reCAPTCHA user response token from client
 * @throws {HttpsError} on missing token or verification failure
 */
async function validateRecaptcha(recaptchaToken: string | undefined): Promise<void> {
  const recaptchaSecret = process.env.RECAPTCHA_SECRET;
  if (!recaptchaSecret) {
    logger.warn("RECAPTCHA_SECRET missing - skipping reCAPTCHA validation (NOT SECURE FOR PROD)");
    return;
  }
  if (!recaptchaToken) {
    throw new HttpsError("failed-precondition", "Missing reCAPTCHA token");
  }
  const params = new URLSearchParams();
  params.append("secret", recaptchaSecret);
  params.append("response", recaptchaToken);
  try {
    const resp = await axios.post("https://www.google.com/recaptcha/api/siteverify", params, { headers: { "Content-Type": "application/x-www-form-urlencoded" } });
    const data = resp.data as { success: boolean; score?: number };
    if (!data.success) throw new HttpsError("permission-denied", "reCAPTCHA failed");
    if (typeof data.score === "number" && data.score < 0.5) throw new HttpsError("permission-denied", "reCAPTCHA score too low");
  } catch (e) {
    if (e instanceof HttpsError) throw e;
    logger.error("reCAPTCHA validation error", e);
    throw new HttpsError("internal", "reCAPTCHA validation error");
  }
}

/**
 * createUser callable - creates Firebase Auth user with email/password
 * and returns custom token for client sign-in.
 */
export const emailSignUp = onCall({ secrets: ["ENCRYPTION_KEY", "RECAPTCHA_SECRET"] }, async (request) => {
  const { email, password, recaptchaToken } = request.data as EmailAuthData;
  if (!email || !password) {
    throw new HttpsError("invalid-argument", "Email and password required.");
  }
  await validateRecaptcha(recaptchaToken);
  try {
    const userRecord = await admin.auth().createUser({ email, password });
    const customToken = await admin.auth().createCustomToken(userRecord.uid);
    return { uid: userRecord.uid, customToken };
  } catch (e: unknown) {
    if (e && typeof e === "object" && "code" in e && (e as { code?: string }).code === "auth/email-already-exists") {
      throw new HttpsError("already-exists", "Email already registered.");
    }
    logger.error("emailSignUp error", e);
    throw new HttpsError("internal", "Failed to create user");
  }
});

/**
 * emailSignIn callable - uses Firebase REST API to verify password and returns idToken.
 * We encrypt the refresh token and store it in Firestore `userTokens/{uid}`.
 */
export const emailSignIn = onCall({ secrets: ["ENCRYPTION_KEY", "RECAPTCHA_SECRET", "WEB_API_KEY"] }, async (request) => {
  const { email, password, recaptchaToken } = request.data as EmailAuthData;
  if (!email || !password) {
    throw new HttpsError("invalid-argument", "Email and password required.");
  }
  const WEB_API_KEY = getSecret("WEB_API_KEY");
  await validateRecaptcha(recaptchaToken);
  const ENCRYPTION_KEY = getSecret("ENCRYPTION_KEY");
  try {
    const resp = await axios.post(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${WEB_API_KEY}`, { email, password, returnSecureToken: true });
    const { localId, idToken, refreshToken } = resp.data;
    const encrypted = encrypt(refreshToken, ENCRYPTION_KEY);
    await db.collection("userTokens").doc(localId).set({ provider: "password", refreshToken: encrypted, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
    return { uid: localId, idToken };
  } catch (err: unknown) {
    const axiosErr = err as AxiosError<{ error?: { message?: string } }>; // narrow
    const code = axiosErr.response?.data?.error?.message;
    if (code === "EMAIL_NOT_FOUND" || code === "INVALID_PASSWORD") {
      throw new HttpsError("not-found", "Invalid credentials");
    }
    logger.error("emailSignIn error", err);
    throw new HttpsError("internal", "Sign in failed");
  }
});

export const oauthLogin = onCall({ secrets: ["ENCRYPTION_KEY", "RECAPTCHA_SECRET", "GOOGLE_CLIENT_SECRET", "MICROSOFT_CLIENT_SECRET"] }, async (request) => {
  const { provider, code, redirectUri, userId, recaptchaToken } = request.data as OAuthLoginData;
  if (!provider || !code || !redirectUri || !userId) {
    throw new HttpsError("invalid-argument", "Missing required fields.");
  }
  await validateRecaptcha(recaptchaToken);
  const ENCRYPTION_KEY = getSecret("ENCRYPTION_KEY");
  let tokens: GoogleOAuthTokens | Record<string, unknown>;
  if (provider === "google") {
    const client = new OAuth2Client(
      process.env.GOOGLE_CLIENT_ID || "",
      process.env.GOOGLE_CLIENT_SECRET || "",
      redirectUri
    );
    const { tokens: googleTokens } = await client.getToken(code);
    tokens = { ...(googleTokens as Record<string, unknown>) } as GoogleOAuthTokens;
  } else if (provider === "microsoft") {
    const msalConfig = { auth: { clientId: process.env.MICROSOFT_CLIENT_ID || "", authority: "https://login.microsoftonline.com/common", clientSecret: process.env.MICROSOFT_CLIENT_SECRET || "" } };
    const cca = new ConfidentialClientApplication(msalConfig);
    const msalResponse = await cca.acquireTokenByCode({
      code,
      redirectUri,
      scopes: ["user.read", "mail.read", "offline_access"],
    });
    tokens = msalResponse;
  } else {
    throw new HttpsError("invalid-argument", "Unknown provider");
  }
  try {
    const encryptedTokens = encrypt(JSON.stringify(tokens), ENCRYPTION_KEY);
    await db.collection("userTokens").doc(userId).set({ provider, tokens: encryptedTokens, updatedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
  } catch (e) {
    logger.error("Failed to encrypt/store tokens", e);
    throw new HttpsError("internal", "Failed to store tokens");
  }
  return { success: true };
});

export const refreshOAuthToken = onCall({ secrets: ["ENCRYPTION_KEY", "GOOGLE_CLIENT_SECRET", "GOOGLE_CLIENT_ID"] }, async (request) => {
  const { userId, provider } = request.data as { userId: string; provider: "google" | "microsoft" };
  if (!userId || !provider) throw new HttpsError("invalid-argument", "userId and provider required");
  const ENCRYPTION_KEY = getSecret("ENCRYPTION_KEY");
  const doc = await db.collection("userTokens").doc(userId).get();
  if (!doc.exists) throw new HttpsError("not-found", "No stored tokens for user");
  const dataDoc = doc.data();
  if (!dataDoc?.tokens) throw new HttpsError("failed-precondition", "Stored tokens missing");
  let parsed: Record<string, unknown> & Partial<GoogleOAuthTokens>;
  try {
    const decrypted = decrypt(dataDoc.tokens, ENCRYPTION_KEY);
    parsed = JSON.parse(decrypted);
  } catch (e) {
    logger.error("Failed to decrypt tokens", e);
    throw new HttpsError("internal", "Corrupt token store");
  }
  if (provider === "google") {
    const refreshToken = parsed.refresh_token || (parsed as { refreshToken?: string }).refreshToken;
    if (!refreshToken) throw new HttpsError("failed-precondition", "No refresh token available");
    try {
      const params = new URLSearchParams();
      params.append("client_id", process.env.GOOGLE_CLIENT_ID || "");
      params.append("client_secret", process.env.GOOGLE_CLIENT_SECRET || "");
      params.append("grant_type", "refresh_token");
      params.append("refresh_token", refreshToken);
      const resp = await axios.post("https://oauth2.googleapis.com/token", params, { headers: { "Content-Type": "application/x-www-form-urlencoded" } });
      const newTokens: GoogleOAuthTokens & Record<string, unknown> = { ...parsed, ...resp.data };
      if (!newTokens.refresh_token) newTokens.refresh_token = refreshToken;
      const encrypted = encrypt(JSON.stringify(newTokens), ENCRYPTION_KEY);
      await db.collection("userTokens").doc(userId).set({ provider: "google", tokens: encrypted, refreshedAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
      return { success: true, provider: "google", expiresIn: resp.data.expires_in };
    } catch (e) {
      logger.error("Google token refresh failed", e);
      throw new HttpsError("internal", "Google token refresh failed");
    }
  } else if (provider === "microsoft") {
    return { success: false, provider: "microsoft", message: "Refresh not implemented yet" };
  } else {
    throw new HttpsError("invalid-argument", "Unsupported provider");
  }
});

// Return public (non-secret) OAuth client identifiers so the client app can configure SDKs without embedding constants.
export const getOAuthPublicConfig = onCall({ secrets: ["GOOGLE_CLIENT_ID", "MICROSOFT_CLIENT_ID"] }, async () => {
  const googleId = process.env.GOOGLE_CLIENT_ID || "";
  const microsoftId = process.env.MICROSOFT_CLIENT_ID || "";
  if (!googleId || !microsoftId) {
    throw new HttpsError("failed-precondition", "OAuth client IDs not configured");
  }
  return { googleClientId: googleId, microsoftClientId: microsoftId };
});
