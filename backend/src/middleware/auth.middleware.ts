import { Request, Response, NextFunction } from 'express';
import { verifyAccessToken, TokenPayload } from '../utils/jwt.utils';

export interface AuthRequest extends Request {
  user?: TokenPayload;
}

export const authenticate = (req: AuthRequest, res: Response, next: NextFunction): void => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    res.status(401).json({
      error: 'Unauthorized',
      message: 'No authentication token provided',
    });
    return;
  }

  const token = authHeader.substring(7);

  try {
    const payload = verifyAccessToken(token);
    req.user = {
      userId: payload.userId,
      email: payload.email,
      username: payload.username,
    };
    next();
  } catch (error: any) {
    if (error.name === 'TokenExpiredError') {
      res.status(401).json({
        error: 'TokenExpired',
        message: 'Access token has expired. Please refresh your token.',
      });
    } else {
      res.status(401).json({
        error: 'Unauthorized',
        message: 'Invalid authentication token',
      });
    }
  }
};
