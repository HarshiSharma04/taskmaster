import { Response, NextFunction } from 'express';
import bcrypt from 'bcryptjs';
import prisma from '../lib/prisma';
import { AuthRequest } from '../middleware/auth.middleware';
import { AppError } from '../middleware/error.middleware';

export const updateProfile = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { username, email } = req.body;

    const updateData: any = {};
    if (username) updateData.username = username;
    if (email) updateData.email = email;

    const user = await prisma.user.update({
      where: { id: userId },
      data: updateData,
      select: { id: true, email: true, username: true, updatedAt: true },
    });

    res.json({ message: 'Profile updated', user });
  } catch (error) {
    next(error);
  }
};

export const changePassword = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { currentPassword, newPassword } = req.body;

    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new AppError('User not found', 404);

    const isValid = await bcrypt.compare(currentPassword, user.passwordHash);
    if (!isValid) throw new AppError('Current password is incorrect', 400);

    const passwordHash = await bcrypt.hash(newPassword, 12);
    await prisma.user.update({ where: { id: userId }, data: { passwordHash } });

    res.json({ message: 'Password changed successfully' });
  } catch (error) {
    next(error);
  }
};
