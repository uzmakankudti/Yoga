import { Router } from 'express';
import bcrypt from 'bcryptjs';
import { ApiError } from '../lib/apiError';
import { asyncHandler } from '../middleware/errorHandler';
import { prisma } from '../lib/prisma';
import { createOtpRequest, verifyOtpRequest } from '../lib/otp';
import { signAccessToken, signRefreshToken, verifyRefreshToken } from '../lib/jwt';

export const authRouter = Router();

function isEmailIdentifier(identifier: string): boolean {
  return identifier.includes('@');
}

authRouter.post(
  '/admin/login',
  asyncHandler(async (req, res) => {
    const { email, password } = req.body as { email?: string; password?: string };
    if (!email || !password) throw new ApiError(400, 'email and password are required');

    const admin = await prisma.admin.findUnique({ where: { email } });
    if (!admin || !(await bcrypt.compare(password, admin.passwordHash))) {
      throw new ApiError(401, 'Invalid admin credentials');
    }

    const accessToken = signAccessToken({ userId: admin.id, role: 'ADMIN' });
    const refreshToken = signRefreshToken(admin.id);
    res.json({ accessToken, refreshToken, role: 'admin', userId: admin.id });
  }),
);

authRouter.post(
  '/otp/request',
  asyncHandler(async (req, res) => {
    const { identifier, channel } = req.body as { identifier?: string; channel?: string };
    if (!identifier || (channel !== 'phone' && channel !== 'email')) {
      throw new ApiError(400, 'identifier and channel ("phone" | "email") are required');
    }
    const { requestId, otp } = createOtpRequest(identifier);
    // Dev-only convenience: real deployments must not echo the OTP back to the client.
    res.json({ requestId, otp });
  }),
);

authRouter.post(
  '/otp/verify',
  asyncHandler(async (req, res) => {
    const { requestId, otp } = req.body as { requestId?: string; otp?: string };
    if (!requestId || !otp) {
      throw new ApiError(400, 'requestId and otp are required');
    }
    const result = verifyOtpRequest(requestId, otp);
    if (!result) {
      throw new ApiError(400, 'Invalid or expired OTP');
    }

    const { identifier } = result;
    const isEmail = isEmailIdentifier(identifier);
    // Accounts are provisioned by an Admin (or, for students, their Trainer) —
    // there's no self-registration, so an unrecognized identifier is an error
    // rather than something we silently create a blank account for.
    const user = await prisma.user.findUnique({
      where: isEmail ? { email: identifier } : { phone: identifier },
    });
    if (!user) {
      throw new ApiError(404, 'No account found for this identifier. Please contact your administrator.');
    }

    const accessToken = signAccessToken({ userId: user.id, role: user.role });
    const refreshToken = signRefreshToken(user.id);
    res.json({ accessToken, refreshToken, role: user.role?.toLowerCase() ?? null, userId: user.id });
  }),
);

authRouter.post(
  '/refresh',
  asyncHandler(async (req, res) => {
    const { refreshToken } = req.body as { refreshToken?: string };
    if (!refreshToken) throw new ApiError(400, 'refreshToken is required');
    let payload: { userId: string };
    try {
      payload = verifyRefreshToken(refreshToken);
    } catch {
      throw new ApiError(401, 'Invalid or expired refresh token');
    }

    const admin = await prisma.admin.findUnique({ where: { id: payload.userId } });
    if (admin) {
      res.json({
        accessToken: signAccessToken({ userId: admin.id, role: 'ADMIN' }),
        refreshToken: signRefreshToken(admin.id),
      });
      return;
    }

    const user = await prisma.user.findUnique({ where: { id: payload.userId } });
    if (!user) throw new ApiError(401, 'User no longer exists');
    res.json({
      accessToken: signAccessToken({ userId: user.id, role: user.role }),
      refreshToken: signRefreshToken(user.id),
    });
  }),
);
