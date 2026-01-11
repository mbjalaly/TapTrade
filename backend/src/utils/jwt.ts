import jwt, { type SignOptions } from 'jsonwebtoken';
import type { Request, Response, NextFunction } from 'express';

export type JwtUserPayload = {
  sub: string;
  username?: string;
};

export function jwtSecret(): string {
  return process.env.JWT_SECRET || 'dev_secret_change_me';
}

export function signUserToken(payload: JwtUserPayload): string {
  const options: SignOptions = {
    // jsonwebtoken types are strict about time strings; cast keeps env-driven config flexible.
    expiresIn: (process.env.JWT_EXPIRES_IN || '30d') as any,
  };
  return jwt.sign(payload, jwtSecret(), options);
}

export function requireAuth(req: Request, res: Response, next: NextFunction) {
  const auth = String(req.headers.authorization || '').trim();
  if (!auth.startsWith('Bearer ')) {
    return res.status(401).json({ errors: { code: 'token_not_valid' }, message: 'Missing token' });
  }
  const token = auth.slice(7);
  try {
    const decoded = jwt.verify(token, jwtSecret()) as any;
    (req as any).userId = String(decoded?.sub || '');
    if (!(req as any).userId) {
      return res.status(401).json({ errors: { code: 'token_not_valid' }, message: 'Invalid token' });
    }
    return next();
  } catch (_e) {
    return res.status(401).json({ errors: { code: 'token_not_valid' }, message: 'Token is invalid or expired' });
  }
}

