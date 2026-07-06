import { NextFunction, Request, Response } from 'express';
import { ApiError } from '../lib/apiError';
import { verifyAccessToken } from '../lib/jwt';

declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace Express {
    interface Request {
      userId?: string;
      role?: 'TRAINER' | 'STUDENT' | 'ADMIN' | null;
    }
  }
}

export function requireAuth(req: Request, _res: Response, next: NextFunction) {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) {
    throw new ApiError(401, 'Missing or invalid Authorization header');
  }
  const token = header.slice('Bearer '.length);
  try {
    const payload = verifyAccessToken(token);
    req.userId = payload.userId;
    req.role = payload.role;
    next();
  } catch {
    throw new ApiError(401, 'Invalid or expired access token');
  }
}

export function requireAdmin(req: Request, _res: Response, next: NextFunction) {
  if (req.role !== 'ADMIN') {
    throw new ApiError(403, 'Admin access required');
  }
  next();
}
