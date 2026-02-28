import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';

import authRoutes from './routes/auth.routes';
import taskRoutes from './routes/task.routes';
import userRoutes from './routes/user.routes';
import { errorHandler } from './middleware/error.middleware';
import { notFoundHandler } from './middleware/notFound.middleware';

const app = express();

// Security middleware
app.use(helmet());
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// Request parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Logging
if (process.env.NODE_ENV !== 'test') {
  app.use(morgan('combined'));
}

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    service: 'TaskMaster API',
  });
});

// Routes
app.use('/auth', authRoutes);
app.use('/tasks', taskRoutes);
app.use('/users', userRoutes);

// Error handling
app.use(notFoundHandler);
app.use(errorHandler);

export default app;
