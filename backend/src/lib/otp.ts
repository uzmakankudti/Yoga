import { randomUUID } from 'crypto';

interface PendingOtp {
  identifier: string;
  otp: string;
  expiresAt: number;
}

const OTP_TTL_MS = 5 * 60 * 1000;
const pending = new Map<string, PendingOtp>();

function generateOtp(): string {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

export function createOtpRequest(identifier: string): { requestId: string; otp: string } {
  const requestId = randomUUID();
  const otp = generateOtp();
  pending.set(requestId, { identifier, otp, expiresAt: Date.now() + OTP_TTL_MS });
  // Dev-only: real SMS/email delivery is not configured, so the OTP is logged here.
  console.log(`[OTP] identifier=${identifier} requestId=${requestId} otp=${otp}`);
  return { requestId, otp };
}

export function verifyOtpRequest(requestId: string, otp: string): { identifier: string } | null {
  const record = pending.get(requestId);
  if (!record) return null;
  if (Date.now() > record.expiresAt) {
    pending.delete(requestId);
    return null;
  }
  if (record.otp !== otp) return null;
  pending.delete(requestId);
  return { identifier: record.identifier };
}
