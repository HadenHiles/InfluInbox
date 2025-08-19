/* eslint-disable @typescript-eslint/no-non-null-assertion */
/* eslint-disable require-jsdoc */
/* eslint-disable max-len */
import * as crypto from "crypto";

const IV_LENGTH = 16; // AES block size

function buildKey(rawKey: string): Buffer {
  if (!rawKey) throw new Error("Encryption key not provided");
  // Ensure 32 bytes (AES-256)
  if (rawKey.length < 32) {
    return Buffer.from(rawKey.padEnd(32, "0"));
  }
  return Buffer.from(rawKey.slice(0, 32));
}

export function encrypt(text: string, key: string): string {
  const k = buildKey(key);
  const iv = crypto.randomBytes(IV_LENGTH);
  const cipher = crypto.createCipheriv("aes-256-cbc", k, iv);
  const encrypted = Buffer.concat([cipher.update(text, "utf8"), cipher.final()]);
  return iv.toString("hex") + ":" + encrypted.toString("hex");
}

export function decrypt(text: string, key: string): string {
  const k = buildKey(key);
  const parts = text.split(":");
  if (parts.length < 2) throw new Error("Invalid encrypted payload format");
  const iv = Buffer.from(parts.shift()!, "hex");
  const encryptedText = Buffer.from(parts.join(":"), "hex");
  const decipher = crypto.createDecipheriv("aes-256-cbc", k, iv);
  const decrypted = Buffer.concat([decipher.update(encryptedText), decipher.final()]);
  return decrypted.toString("utf8");
}
