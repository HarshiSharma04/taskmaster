import { Router } from 'express';
import { body } from 'express-validator';
import { updateProfile, changePassword } from '../controllers/user.controller';
import { authenticate } from '../middleware/auth.middleware';
import { validate } from '../middleware/validate.middleware';

const router = Router();

router.use(authenticate);

router.patch(
  '/profile',
  [
    body('username').optional().isLength({ min: 3, max: 30 }).matches(/^[a-zA-Z0-9_]+$/),
    body('email').optional().isEmail().normalizeEmail(),
  ],
  validate,
  updateProfile
);

router.post(
  '/change-password',
  [
    body('currentPassword').notEmpty().withMessage('Current password required'),
    body('newPassword').isLength({ min: 8 }).withMessage('New password min 8 chars'),
  ],
  validate,
  changePassword
);

export default router;
