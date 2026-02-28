import { Router } from 'express';
import { body } from 'express-validator';
import { register, login, refresh, logout, getMe } from '../controllers/auth.controller';
import { authenticate } from '../middleware/auth.middleware';
import { validate } from '../middleware/validate.middleware';

const router = Router();

router.post(
  '/register',
  [
    body('email').isEmail().normalizeEmail().withMessage('Valid email required'),
    body('username')
      .isLength({ min: 3, max: 30 })
      .matches(/^[a-zA-Z0-9_]+$/)
      .withMessage('Username must be 3-30 alphanumeric characters'),
    body('password')
      .isLength({ min: 8 })
      .withMessage('Password must be at least 8 characters'),
  ],
  validate,
  register
);

router.post(
  '/login',
  [
    body('email').isEmail().normalizeEmail().withMessage('Valid email required'),
    body('password').notEmpty().withMessage('Password is required'),
  ],
  validate,
  login
);

router.post(
  '/refresh',
  [body('refreshToken').notEmpty().withMessage('Refresh token required')],
  validate,
  refresh
);

router.post('/logout', authenticate, logout);

router.get('/me', authenticate, getMe);

export default router;
