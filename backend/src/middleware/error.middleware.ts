import { Request, Response, NextFunction } from 'express';

export class AppError extends Error {
  statusCode: number;
  isOperational: boolean;

  constructor(message: string, statusCode: number) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }
}

export const errorHandler = (
  err: any,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  console.error('Error:', err);

  // Prisma errors
  if (err.code === 'P2002') {
    res.status(409).json({
      error: 'Conflict',
      message: 'A record with this data already exists',
    });
    return;
  }

  if (err.code === 'P2025') {
    res.status(404).json({
      error: 'NotFound',
      message: 'The requested resource was not found',
    });
    return;
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    res.status(401).json({
      error: 'Unauthorized',
      message: 'Invalid token',
    });
    return;
  }

  if (err.name === 'TokenExpiredError') {
    res.status(401).json({
      error: 'TokenExpired',
      message: 'Token has expired',
    });
    return;
  }

  // Operational errors
  if (err instanceof AppError) {
    res.status(err.statusCode).json({
      error: err.name || 'Error',
      message: err.message,
    });
    return;
  }

  // Default 500 error
  res.status(500).json({
    error: 'InternalServerError',
    message: process.env.NODE_ENV === 'production'
      ? 'An unexpected error occurred'
      : err.message,
  });
};
