# TaskMaster — Task Management System

> A full-stack task management application built with **Node.js + TypeScript** (backend) and **Flutter** (Android), featuring JWT authentication, real-time CRUD operations, and a polished mobile UI.

---

## 📋 Table of Contents
- [Project Overview](#project-overview)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Features](#features)
- [API Documentation](#api-documentation)
- [Setup & Running](#setup--running)
- [Flutter App](#flutter-app)
- [Screenshots](#screenshots)

---

## Project Overview

TaskMaster is a complete task management system that allows users to register, log in, and perform full CRUD operations on their personal tasks. The system is split into two parts:

- **Part 1 — Backend API**: A secure REST API built with Node.js, TypeScript, and Prisma ORM
- **Part 2 — Mobile App**: A Flutter Android app with clean architecture and modern state management

---

## Tech Stack

### Backend
| Technology | Purpose |
|------------|---------|
| Node.js + TypeScript | Server runtime |
| Express.js | Web framework |
| Prisma ORM | Database access layer |
| SQLite | SQL database |
| JWT (jsonwebtoken) | Access + Refresh token auth |
| bcryptjs | Password hashing |
| express-validator | Input validation |
| helmet + cors | Security middleware |

### Flutter App
| Technology | Purpose |
|------------|---------|
| Flutter 3.x | Cross-platform mobile framework |
| Riverpod | State management |
| Dio | HTTP client with interceptors |
| GoRouter | Navigation |
| flutter_secure_storage | Secure token storage |
| flutter_animate | Animations |
| flutter_slidable | Swipe actions |
| Google Fonts | Typography (Playfair Display + Lato) |
| shimmer | Loading skeletons |

---

## Architecture

### Backend — Layered Architecture
```
src/
├── controllers/      ← Request handlers (auth, tasks, users)
├── middleware/       ← Auth guard, error handler, validator
├── routes/           ← Route definitions
├── utils/            ← JWT helpers
├── lib/              ← Prisma client singleton
├── app.ts            ← Express app setup
└── index.ts          ← Entry point
```

### Flutter App — Clean Architecture
```
lib/
├── config/           ← Theme, colors, constants
├── models/           ← Data models (Task, User)
├── services/         ← API service (Dio), Storage service
├── repositories/     ← Data access layer (Auth, Task)
├── providers/        ← Riverpod state (Auth, TaskList, Filter)
├── screens/          ← UI screens
│   ├── auth/         ← Splash, Login, Register
│   ├── tasks/        ← Dashboard, Create/Edit, Detail
│   └── profile/      ← Profile, Change Password
└── widgets/          ← Reusable components
```

---

## Features

### Authentication
-  User registration with email, username, password validation
-  Login with JWT Access Token (15 min) + Refresh Token (7 days)
-  Automatic token refresh — Dio interceptor catches 401, refreshes silently, retries original request
-  Refresh token rotation (old token revoked on each refresh)
-  Secure token storage using `flutter_secure_storage` (Android Keystore)
-  Logout with server-side token revocation
-  Session persistence (auto-login on app restart)
-  Password hashing with bcrypt (12 salt rounds)

### Task Management
-  Create tasks with title, description, status, priority, due date, tags
-  Read task list with efficient `ListView.builder` rendering
-  Update any task field via PATCH endpoint
-  Delete tasks with confirmation dialog
-  Toggle task status (Pending ↔ Completed)
-  Task statistics (completion rate, overdue, urgent counts)

### Dashboard
-  Pull-to-refresh
-  Infinite scroll pagination (10 tasks per page)
-  Search by title and description
-  Filter by status (Pending / In Progress / Completed)
-  Filter by priority (Low / Medium / High / Urgent)
-  Swipe left to edit or delete (flutter_slidable)
-  Shimmer loading skeletons
-  Overdue task highlighting

### UI/UX
-  Custom beige/terracotta color palette
-  Playfair Display + Lato typography
-  Smooth entry animations on all screens
-  Priority color strips on task cards
-  Friendly error Snackbars for 401, 500, network errors
-  Confirmation dialogs for destructive actions

---

## API Documentation

### Base URL
```
http://localhost:3000
```

### Authentication Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/auth/register` | Register new user | No |
| POST | `/auth/login` | Login and get tokens | No |
| POST | `/auth/refresh` | Get new access token | No |
| POST | `/auth/logout` | Revoke refresh token | Yes |
| GET | `/auth/me` | Get current user | Yes |

#### POST /auth/register
```json
Request:
{
  "email": "user@example.com",
  "username": "john_doe",
  "password": "password123"
}

Response 201:
{
  "user": { "id": "...", "email": "...", "username": "..." },
  "accessToken": "eyJ...",
  "refreshToken": "uuid-uuid-..."
}
```

#### POST /auth/login
```json
Request:
{ "email": "user@example.com", "password": "password123" }

Response 200:
{
  "user": { "id": "...", "email": "...", "username": "..." },
  "accessToken": "eyJ...",
  "refreshToken": "uuid-uuid-..."
}
```

#### POST /auth/refresh
```json
Request:
{ "refreshToken": "uuid-uuid-..." }

Response 200:
{ "accessToken": "eyJ...", "refreshToken": "new-uuid-..." }
```

---

### Task Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/tasks` | Get tasks (paginated, filtered, searchable) |
| POST | `/tasks` | Create a new task |
| GET | `/tasks/stats` | Get task statistics |
| GET | `/tasks/:id` | Get single task |
| PATCH | `/tasks/:id` | Update task |
| DELETE | `/tasks/:id` | Delete task |
| POST | `/tasks/:id/toggle` | Toggle task status |

#### GET /tasks — Query Parameters
| Parameter | Type | Description |
|-----------|------|-------------|
| `page` | number | Page number (default: 1) |
| `limit` | number | Items per page, max 50 (default: 10) |
| `status` | string | PENDING \| IN_PROGRESS \| COMPLETED |
| `priority` | string | LOW \| MEDIUM \| HIGH \| URGENT |
| `search` | string | Search in title and description |
| `sortBy` | string | createdAt \| updatedAt \| title \| dueDate |
| `sortOrder` | string | asc \| desc |

#### POST /tasks
```json
Request:
{
  "title": "Complete project",
  "description": "Finish the assessment",
  "status": "IN_PROGRESS",
  "priority": "HIGH",
  "dueDate": "2025-12-31T00:00:00.000Z",
  "tags": ["work", "urgent"]
}
```

---

## Setup & Running

### Prerequisites
- Node.js 18+
- npm

### Backend Setup

```bash
# 1. Navigate to backend
cd backend

# 2. Install dependencies
npm install

# 3. Create environment file
cp .env.example .env

# 4. Run database migration
npx prisma migrate dev --name init
npx prisma generate

# 5. Start the server
npm run dev
```

Server runs at `http://localhost:3000`

Health check: `http://localhost:3000/health`

### Environment Variables (.env)
```env
DATABASE_URL="file:./dev.db"
JWT_ACCESS_SECRET="your-secret-key-min-32-chars"
JWT_REFRESH_SECRET="your-refresh-secret-min-32-chars"
ACCESS_TOKEN_EXPIRY="15m"
REFRESH_TOKEN_EXPIRY="7d"
PORT=3000
NODE_ENV="development"
CORS_ORIGIN="*"
```

---

## Flutter App

### Prerequisites
- Flutter 3.x SDK
- Android Studio
- Android Emulator (API 34 recommended)

### Running the App

```bash
# 1. Navigate to flutter app
cd flutter_app

# 2. Install dependencies
flutter pub get

# 3. Run on emulator
flutter run
```

### API URL Configuration
Open `lib/config/app_config.dart`:
```dart
// Android Emulator
static const String baseUrl = 'http://10.0.2.2:3000';

// Physical device (replace with your computer's IP)
static const String baseUrl = 'http://192.168.x.x:3000';
```

### Building APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## Security Implementation

- Passwords hashed with **bcrypt** (12 rounds)
- **JWT Access Tokens** expire in 15 minutes
- **Refresh Tokens** are single-use (rotated on every refresh)
- Tokens stored in **Android Keystore** via flutter_secure_storage
- All task endpoints protected with Bearer token authentication
- Input validation on all endpoints via express-validator
- HTTP security headers via **helmet**

---

## Error Handling

The API returns consistent error responses:

```json
{
  "error": "ErrorType",
  "message": "Human readable message"
}
```

| Status Code | Meaning |
|-------------|---------|
| 400 | Validation error |
| 401 | Unauthorized / Token expired |
| 404 | Resource not found |
| 409 | Conflict (duplicate email/username) |
| 500 | Internal server error |

The Flutter app displays user-friendly Snackbars for all errors.
