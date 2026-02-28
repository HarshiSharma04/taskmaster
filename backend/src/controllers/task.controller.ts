import { Response, NextFunction } from 'express';
import { Prisma, TaskStatus, Priority } from '@prisma/client';
import prisma from '../lib/prisma';
import { AuthRequest } from '../middleware/auth.middleware';
import { AppError } from '../middleware/error.middleware';

export const getTasks = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const {
      page = '1',
      limit = '10',
      status,
      priority,
      search,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = req.query;

    const pageNum = Math.max(1, parseInt(page as string));
    const limitNum = Math.min(50, Math.max(1, parseInt(limit as string)));
    const skip = (pageNum - 1) * limitNum;

    // Build filter conditions
    const where: Prisma.TaskWhereInput = { userId };

    if (status && Object.values(TaskStatus).includes(status as TaskStatus)) {
      where.status = status as TaskStatus;
    }

    if (priority && Object.values(Priority).includes(priority as Priority)) {
      where.priority = priority as Priority;
    }

    if (search) {
      where.OR = [
        { title: { contains: search as string, mode: 'insensitive' } },
        { description: { contains: search as string, mode: 'insensitive' } },
      ];
    }

    // Build sort
    const validSortFields = ['createdAt', 'updatedAt', 'title', 'dueDate', 'priority'];
    const sortField = validSortFields.includes(sortBy as string) ? sortBy as string : 'createdAt';
    const orderBy: any = { [sortField]: sortOrder === 'asc' ? 'asc' : 'desc' };

    const [tasks, total] = await Promise.all([
      prisma.task.findMany({
        where,
        orderBy,
        skip,
        take: limitNum,
      }),
      prisma.task.count({ where }),
    ]);

    // Parse tags from JSON strings
    const parsedTasks = tasks.map(task => ({
      ...task,
      tags: task.tags ? JSON.parse(task.tags) : [],
    }));

    res.json({
      tasks: parsedTasks,
      pagination: {
        page: pageNum,
        limit: limitNum,
        total,
        totalPages: Math.ceil(total / limitNum),
        hasMore: skip + limitNum < total,
      },
    });
  } catch (error) {
    next(error);
  }
};

export const getTaskById = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const userId = req.user!.userId;

    const task = await prisma.task.findFirst({
      where: { id, userId },
    });

    if (!task) {
      throw new AppError('Task not found', 404);
    }

    res.json({
      task: {
        ...task,
        tags: task.tags ? JSON.parse(task.tags) : [],
      },
    });
  } catch (error) {
    next(error);
  }
};

export const createTask = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { title, description, status, priority, dueDate, tags } = req.body;

    const task = await prisma.task.create({
      data: {
        title,
        description,
        status: status || TaskStatus.PENDING,
        priority: priority || Priority.MEDIUM,
        dueDate: dueDate ? new Date(dueDate) : null,
        tags: tags ? JSON.stringify(tags) : null,
        userId,
      },
    });

    res.status(201).json({
      message: 'Task created successfully',
      task: {
        ...task,
        tags: task.tags ? JSON.parse(task.tags) : [],
      },
    });
  } catch (error) {
    next(error);
  }
};

export const updateTask = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const userId = req.user!.userId;

    // Verify task belongs to user
    const existing = await prisma.task.findFirst({ where: { id, userId } });
    if (!existing) {
      throw new AppError('Task not found', 404);
    }

    const { title, description, status, priority, dueDate, tags } = req.body;

    const updateData: Prisma.TaskUpdateInput = {};
    if (title !== undefined) updateData.title = title;
    if (description !== undefined) updateData.description = description;
    if (status !== undefined) updateData.status = status;
    if (priority !== undefined) updateData.priority = priority;
    if (dueDate !== undefined) updateData.dueDate = dueDate ? new Date(dueDate) : null;
    if (tags !== undefined) updateData.tags = JSON.stringify(tags);

    const task = await prisma.task.update({
      where: { id },
      data: updateData,
    });

    res.json({
      message: 'Task updated successfully',
      task: {
        ...task,
        tags: task.tags ? JSON.parse(task.tags) : [],
      },
    });
  } catch (error) {
    next(error);
  }
};

export const deleteTask = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const userId = req.user!.userId;

    const existing = await prisma.task.findFirst({ where: { id, userId } });
    if (!existing) {
      throw new AppError('Task not found', 404);
    }

    await prisma.task.delete({ where: { id } });

    res.json({ message: 'Task deleted successfully' });
  } catch (error) {
    next(error);
  }
};

export const toggleTask = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const userId = req.user!.userId;

    const existing = await prisma.task.findFirst({ where: { id, userId } });
    if (!existing) {
      throw new AppError('Task not found', 404);
    }

    // Toggle: PENDING/IN_PROGRESS -> COMPLETED, COMPLETED -> PENDING
    const newStatus = existing.status === TaskStatus.COMPLETED
      ? TaskStatus.PENDING
      : TaskStatus.COMPLETED;

    const task = await prisma.task.update({
      where: { id },
      data: { status: newStatus },
    });

    res.json({
      message: `Task marked as ${newStatus.toLowerCase()}`,
      task: {
        ...task,
        tags: task.tags ? JSON.parse(task.tags) : [],
      },
    });
  } catch (error) {
    next(error);
  }
};

export const getTaskStats = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const userId = req.user!.userId;

    const [total, pending, inProgress, completed, urgent] = await Promise.all([
      prisma.task.count({ where: { userId } }),
      prisma.task.count({ where: { userId, status: TaskStatus.PENDING } }),
      prisma.task.count({ where: { userId, status: TaskStatus.IN_PROGRESS } }),
      prisma.task.count({ where: { userId, status: TaskStatus.COMPLETED } }),
      prisma.task.count({ where: { userId, priority: Priority.URGENT } }),
    ]);

    // Overdue tasks
    const overdue = await prisma.task.count({
      where: {
        userId,
        status: { not: TaskStatus.COMPLETED },
        dueDate: { lt: new Date() },
      },
    });

    res.json({
      stats: {
        total,
        pending,
        inProgress,
        completed,
        urgent,
        overdue,
        completionRate: total > 0 ? Math.round((completed / total) * 100) : 0,
      },
    });
  } catch (error) {
    next(error);
  }
};
