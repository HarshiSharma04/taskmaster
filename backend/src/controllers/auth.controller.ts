import { Request, Response, NextFunction } from 'express';
import bcrypt from 'bcryptjs';
import prisma from '../lib/prisma';
import {
  generateAccessToken,
  generateRefreshToken,
  saveRefreshToken,
  validateRefreshToken,
  revokeRefreshToken,
  revokeAllUserTokens,
} from '../utils/jwt.utils';
import { AuthRequest } from '../middleware/auth.middleware';
import { AppError } from '../middleware/error.middleware';

export const register = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { email, username, password } = req.body;

    // Check if user exists
    const existingUser = await prisma.user.findFirst({
      where: { OR: [{ email }, { username }] },
    });

    if (existingUser) {
      if (existingUser.email === email) {
        throw new AppError('Email already registered', 409);
      }
      throw new AppError('Username already taken', 409);
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, 12);

    // Create user
    const user = await prisma.user.create({
      data: { email, username, passwordHash },
      select: { id: true, email: true, username: true, createdAt: true },
    });

    // Generate tokens
    const accessToken = generateAccessToken({
      userId: user.id,
      email: user.email,
      username: user.username,
    });
    const refreshToken = generateRefreshToken();
    await saveRefreshToken(user.id, refreshToken);

    res.status(201).json({
      message: 'User registered successfully',
      user,
      accessToken,
      refreshToken,
    });
  } catch (error) {
    next(error);
  }
};

export const login = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { email, password } = req.body;

    // Find user
    const user = await prisma.user.findUnique({ where: { email } });
    if (!user) {
      throw new AppError('Invalid email or password', 401);
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      throw new AppError('Invalid email or password', 401);
    }

    // Generate tokens
    const accessToken = generateAccessToken({
      userId: user.id,
      email: user.email,
      username: user.username,
    });
    const refreshToken = generateRefreshToken();
    await saveRefreshToken(user.id, refreshToken);

    res.json({
      message: 'Login successful',
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        createdAt: user.createdAt,
      },
      accessToken,
      refreshToken,
    });
  } catch (error) {
    next(error);
  }
};

export const refresh = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      throw new AppError('Refresh token required', 400);
    }

    const tokenRecord = await validateRefreshToken(refreshToken);
    if (!tokenRecord) {
      throw new AppError('Invalid or expired refresh token', 401);
    }

    // Revoke old token (rotation)
    await revokeRefreshToken(refreshToken);

    // Generate new tokens
    const newAccessToken = generateAccessToken({
      userId: tokenRecord.user.id,
      email: tokenRecord.user.email,
      username: tokenRecord.user.username,
    });
    const newRefreshToken = generateRefreshToken();
    await saveRefreshToken(tokenRecord.user.id, newRefreshToken);

    res.json({
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    });
  } catch (error) {
    next(error);
  }
};

export const logout = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { refreshToken } = req.body;

    if (refreshToken) {
      await revokeRefreshToken(refreshToken);
    }

    if (req.user) {
      // Optionally revoke all tokens for this user
      const { allDevices } = req.body;
      if (allDevices) {
        await revokeAllUserTokens(req.user.userId);
      }
    }

    res.json({ message: 'Logged out successfully' });
  } catch (error) {
    next(error);
  }
};

export const getMe = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user!.userId },
      select: {
        id: true,
        email: true,
        username: true,
        createdAt: true,
        updatedAt: true,
        _count: { select: { tasks: true } },
      },
    });

    if (!user) {
      throw new AppError('User not found', 404);
    }

    res.json({ user });
  } catch (error) {
    next(error);
  }
};
