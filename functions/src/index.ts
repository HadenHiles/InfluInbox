/* eslint-disable @typescript-eslint/no-unused-vars */
/* eslint-disable max-len */
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {OAuth2Client} from "google-auth-library";
import {ConfidentialClientApplication} from "@azure/msal-node";
import {encrypt} from "./utils/encryption";

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

admin.initializeApp();
const db = admin.firestore();

interface OAuthLoginData {
  provider: "google" | "microsoft";
  code: string;
  redirectUri: string;
  userId: string;
}

export const oauthLogin = functions.https.onCall(
    async (data: unknown, context) => {
      const {provider, code, redirectUri, userId} = data as OAuthLoginData;
      let tokens;

      if (!provider || !code || !redirectUri || !userId) {
        throw new functions.https.HttpsError("invalid-argument", "Missing required fields.");
      }

      if (provider === "google") {
        const client = new OAuth2Client(
            process.env.GOOGLE_CLIENT_ID || "",
            process.env.GOOGLE_CLIENT_SECRET || "",
            redirectUri
        );
        const {tokens: googleTokens} = await client.getToken(code);
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

      // Encrypt tokens before storing
      const encryptedTokens = encrypt(JSON.stringify(tokens));
      await db.collection("userTokens").doc(userId).set({
        provider,
        tokens: encryptedTokens,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {success: true};
    }
);
