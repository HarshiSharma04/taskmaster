import jwt, { SignOptions } from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import prisma from '../lib/prisma';

export interface TokenPayload {
  userId: string;
  email: string;
  username: string;
}

export interface JwtPayload extends TokenPayload {
  iat: number;
  exp: number;
}

export const generateAccessToken = (payload: TokenPayload): string => {
  const secret = process.env.JWT_ACCESS_SECRET;
  if (!secret) throw new Error('JWT_ACCESS_SECRET not configured');

  const options: SignOptions = {
    expiresIn: (process.env.ACCESS_TOKEN_EXPIRY || '15m') as any,
  };

  return jwt.sign(payload, secret, options);
};

export const generateRefreshToken = (): string => {
  return uuidv4() + '-' + uuidv4() + '-' + Date.now().toString(36);
};

export const verifyAccessToken = (token: string): JwtPayload => {
  const secret = process.env.JWT_ACCESS_SECRET;
  if (!secret) throw new Error('JWT_ACCESS_SECRET not configured');

  return jwt.verify(token, secret) as JwtPayload;
};

export const saveRefreshToken = async (userId: string, token: string): Promise<void> => {
  const expiry = new Date();
  const days = parseInt(process.env.REFRESH_TOKEN_EXPIRY?.replace('d', '') || '7');
  expiry.setDate(expiry.getDate() + days);

  await prisma.refreshToken.create({
    data: {
      token,
      userId,
      expiresAt: expiry,
    },
  });
};

export const validateRefreshToken = async (token: string) => {
  const refreshToken = await prisma.refreshToken.findUnique({
    where: { token },
    include: { user: true },
  });

  if (!refreshToken) return null;
  if (refreshToken.isRevoked) return null;
  if (refreshToken.expiresAt < new Date()) {
    await prisma.refreshToken.update({
      where: { id: refreshToken.id },
      data: { isRevoked: true },
    });
    return null;
  }

  return refreshToken;
};

export const revokeRefreshToken = async (token: string): Promise<void> => {
  await prisma.refreshToken.updateMany({
    where: { token },
    data: { isRevoked: true },
  });
};

export const revokeAllUserTokens = async (userId: string): Promise<void> => {
  await prisma.refreshToken.updateMany({
    where: { userId },
    data: { isRevoked: true },
  });
};
