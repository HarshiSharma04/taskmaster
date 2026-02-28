import { Router } from 'express';
import { body, query } from 'express-validator';
import {
  getTasks,
  getTaskById,
  createTask,
  updateTask,
  deleteTask,
  toggleTask,
  getTaskStats,
} from '../controllers/task.controller';
import { authenticate } from '../middleware/auth.middleware';
import { validate } from '../middleware/validate.middleware';

const router = Router();

// All task routes require authentication
router.use(authenticate);

// Stats endpoint
router.get('/stats', getTaskStats);

// Get all tasks with pagination, filtering, and search
router.get(
  '/',
  [
    query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
    query('limit').optional().isInt({ min: 1, max: 50 }).withMessage('Limit must be 1-50'),
    query('status').optional().isIn(['PENDING', 'IN_PROGRESS', 'COMPLETED']).withMessage('Invalid status'),
    query('priority').optional().isIn(['LOW', 'MEDIUM', 'HIGH', 'URGENT']).withMessage('Invalid priority'),
    query('sortOrder').optional().isIn(['asc', 'desc']).withMessage('Sort order must be asc or desc'),
  ],
  validate,
  getTasks
);

// Create task
router.post(
  '/',
  [
    body('title').notEmpty().isLength({ max: 200 }).withMessage('Title is required (max 200 chars)'),
    body('description').optional().isLength({ max: 2000 }).withMessage('Description max 2000 chars'),
    body('status').optional().isIn(['PENDING', 'IN_PROGRESS', 'COMPLETED']).withMessage('Invalid status'),
    body('priority').optional().isIn(['LOW', 'MEDIUM', 'HIGH', 'URGENT']).withMessage('Invalid priority'),
    body('dueDate').optional().isISO8601().withMessage('Due date must be a valid ISO 8601 date'),
    body('tags').optional().isArray().withMessage('Tags must be an array'),
  ],
  validate,
  createTask
);

// Get task by ID
router.get('/:id', getTaskById);

// Update task
router.patch(
  '/:id',
  [
    body('title').optional().isLength({ min: 1, max: 200 }).withMessage('Title max 200 chars'),
    body('description').optional().isLength({ max: 2000 }).withMessage('Description max 2000 chars'),
    body('status').optional().isIn(['PENDING', 'IN_PROGRESS', 'COMPLETED']).withMessage('Invalid status'),
    body('priority').optional().isIn(['LOW', 'MEDIUM', 'HIGH', 'URGENT']).withMessage('Invalid priority'),
    body('dueDate').optional().isISO8601().withMessage('Due date must be a valid ISO 8601 date'),
    body('tags').optional().isArray().withMessage('Tags must be an array'),
  ],
  validate,
  updateTask
);

// Delete task
router.delete('/:id', deleteTask);

// Toggle task status
router.post('/:id/toggle', toggleTask);

export default router;
