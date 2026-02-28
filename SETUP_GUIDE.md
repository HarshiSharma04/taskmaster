# 📋 TaskMaster — Complete Setup Guide
## Task Management System (Node.js Backend + Flutter Android App)

---

## 🗂️ PROJECT STRUCTURE

```
taskmaster/
├── backend/                   ← Node.js + TypeScript API
│   ├── prisma/
│   │   └── schema.prisma      ← Database schema
│   ├── src/
│   │   ├── index.ts           ← Entry point
│   │   ├── app.ts             ← Express app
│   │   ├── controllers/       ← Route handlers
│   │   ├── middleware/        ← Auth, error, validation
│   │   ├── routes/            ← API routes
│   │   ├── services/          ← (future services)
│   │   ├── lib/prisma.ts      ← DB client
│   │   └── utils/jwt.utils.ts ← Token helpers
│   ├── .env.example
│   ├── package.json
│   └── tsconfig.json
│
└── flutter_app/               ← Flutter Android App
    ├── lib/
    │   ├── main.dart           ← App entry point
    │   ├── config/             ← Colors, theme, config
    │   ├── models/             ← Data models
    │   ├── services/           ← API & storage services
    │   ├── repositories/       ← Data access layer
    │   ├── providers/          ← Riverpod state management
    │   ├── screens/            ← UI screens
    │   │   ├── auth/           ← Login, Register, Splash
    │   │   ├── tasks/          ← Dashboard, Create, Detail
    │   │   └── profile/        ← Profile, Settings
    │   ├── widgets/            ← Reusable UI components
    │   └── utils/router.dart   ← Navigation
    └── pubspec.yaml
```

---

## ⚙️ PART 1: BACKEND SETUP

### Prerequisites
- Node.js 18+ (download from nodejs.org)
- npm (comes with Node.js)

### Step 1: Open Terminal / Command Prompt

On Windows: Press Win+R, type `cmd`, press Enter
On Mac: Open Terminal app

### Step 2: Navigate to backend folder
```bash
cd path/to/taskmaster/backend
# Example: cd C:\Users\YourName\taskmaster\backend
```

### Step 3: Install dependencies
```bash
npm install
```

### Step 4: Create environment file
Create a file named `.env` in the backend folder with this content:

```env
DATABASE_URL="file:./dev.db"
JWT_ACCESS_SECRET="mySecretAccessKey2024ChangeThisInProduction123"
JWT_REFRESH_SECRET="mySecretRefreshKey2024ChangeThisInProduction456"
ACCESS_TOKEN_EXPIRY="15m"
REFRESH_TOKEN_EXPIRY="7d"
PORT=3000
NODE_ENV="development"
CORS_ORIGIN="*"
```

### Step 5: Set up database
```bash
npx prisma migrate dev --name init
npx prisma generate
```

### Step 6: Start the backend server
```bash
npm run dev
```

You should see:
```
🚀 TaskMaster API running on port 3000
📖 Environment: development
🔗 Health check: http://localhost:3000/health
```

### ✅ Test the backend
Open your browser and visit: `http://localhost:3000/health`
You should see: `{"status":"ok","timestamp":"...","version":"1.0.0","service":"TaskMaster API"}`

---

## 📱 PART 2: FLUTTER APP SETUP

### Prerequisites - Installing Flutter

1. **Download Flutter SDK:**
   - Go to: https://flutter.dev/docs/get-started/install/windows
   - Download the Flutter SDK zip
   - Extract to `C:\flutter` (Windows) or `~/flutter` (Mac/Linux)

2. **Add Flutter to PATH:**
   - Windows: Search "Environment Variables" → Edit System Environment Variables → Path → Add `C:\flutter\bin`
   - Mac/Linux: Add `export PATH="$HOME/flutter/bin:$PATH"` to your `.bashrc` or `.zshrc`

3. **Install Android Studio:**
   - Download from: https://developer.android.com/studio
   - During installation, make sure to install "Android SDK"

4. **Set up Flutter in Android Studio:**
   - Open Android Studio
   - Go to: File → Settings → Plugins → Search "Flutter" → Install
   - Also install the "Dart" plugin
   - Restart Android Studio

5. **Accept Android licenses:**
   ```bash
   flutter doctor --android-licenses
   ```
   Press 'y' for all prompts

6. **Verify setup:**
   ```bash
   flutter doctor
   ```
   All items should have green checkmarks (except optional ones)

---

### Creating the Flutter Project in Android Studio

**Option A: Open existing project (RECOMMENDED)**

1. Open Android Studio
2. Click "Open" (or File → Open)
3. Navigate to the `taskmaster/flutter_app` folder
4. Click "OK"
5. Wait for Gradle sync to complete

**Option B: Create fresh project then copy files**

1. Open Android Studio
2. Click "New Flutter Project"
3. Select "Flutter" → Next
4. Set:
   - Project name: `taskmaster`
   - Project location: wherever you want
   - Organization: `com.example`
   - Android language: Kotlin
5. Click Finish
6. Copy all files from `flutter_app/lib/` to your new project's `lib/`
7. Replace `pubspec.yaml` with the provided one

---

### Setting Up an Android Emulator

1. In Android Studio: Tools → Device Manager → Create Device
2. Choose "Pixel 7" → Next
3. Select "API 34" (Android 14) → Download if needed → Next
4. Click Finish
5. Press the ▶ Play button to start the emulator

---

### Installing Flutter Dependencies

In Android Studio, open the terminal (View → Tool Windows → Terminal):
```bash
flutter pub get
```

---

### ⚠️ IMPORTANT: Configure the API URL

Open `lib/config/app_config.dart` and find:
```dart
static const String baseUrl = 'http://10.0.2.2:3000';
```

- **Android Emulator**: Use `http://10.0.2.2:3000` ← This is correct for emulator!
- **Physical Android device**: 
  1. Find your computer's IP: run `ipconfig` (Windows) or `ifconfig` (Mac)
  2. Look for IPv4 Address (e.g., 192.168.1.5)
  3. Change to: `http://192.168.1.5:3000`
  4. Make sure your phone and computer are on the same WiFi

---

### Running the App

1. Make sure backend is running (`npm run dev` in terminal)
2. Make sure emulator is running
3. In Android Studio, select the emulator from the device dropdown
4. Click the green ▶ Run button (or press Shift+F10)

---

## 🏗️ FILE CREATION GUIDE

### Where to create files in Android Studio

When you need to add files to your Flutter project:

1. **Right-click** on the folder (e.g., `lib/widgets`)
2. Select **New → Dart File**
3. Type the filename (without .dart extension)
4. Paste the code

### File locations (create these in this order):
```
lib/config/app_config.dart           ← Theme, colors, constants
lib/models/task_model.dart           ← Task data model
lib/models/user_model.dart           ← User data model
lib/services/api_service.dart        ← HTTP service with Dio
lib/services/storage_service.dart    ← Secure storage
lib/repositories/auth_repository.dart
lib/repositories/task_repository.dart
lib/providers/providers.dart         ← Riverpod state management
lib/utils/router.dart               ← Navigation
lib/widgets/custom_text_field.dart
lib/widgets/app_snackbar.dart
lib/widgets/task_card.dart
lib/widgets/priority_badge.dart
lib/widgets/status_badge.dart
lib/widgets/stats_card.dart
lib/widgets/filter_bar.dart
lib/widgets/empty_state.dart
lib/widgets/task_shimmer.dart
lib/screens/auth/splash_screen.dart
lib/screens/auth/login_screen.dart
lib/screens/auth/register_screen.dart
lib/screens/tasks/task_dashboard_screen.dart
lib/screens/tasks/create_task_screen.dart
lib/screens/tasks/task_detail_screen.dart
lib/screens/profile/profile_screen.dart
lib/main.dart                        ← Replace existing main.dart
```

---

## 📦 Building the APK

Once the app runs correctly in the emulator:

```bash
flutter build apk --release
```

The APK will be at:
`build/app/outputs/flutter-apk/app-release.apk`

For a smaller APK (split by architecture):
```bash
flutter build apk --split-per-abi
```

---

## 🔌 API ENDPOINTS REFERENCE

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /auth/register | Register new user |
| POST | /auth/login | Login |
| POST | /auth/refresh | Refresh access token |
| POST | /auth/logout | Logout |
| GET | /auth/me | Get current user |

### Tasks
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /tasks | Get tasks (paginated, filtered, searchable) |
| POST | /tasks | Create task |
| GET | /tasks/stats | Get task statistics |
| GET | /tasks/:id | Get task by ID |
| PATCH | /tasks/:id | Update task |
| DELETE | /tasks/:id | Delete task |
| POST | /tasks/:id/toggle | Toggle task status |

### Query Parameters for GET /tasks
- `page` - Page number (default: 1)
- `limit` - Items per page (1-50, default: 10)
- `status` - Filter: PENDING | IN_PROGRESS | COMPLETED
- `priority` - Filter: LOW | MEDIUM | HIGH | URGENT
- `search` - Search in title and description
- `sortBy` - Sort field: createdAt | updatedAt | title | dueDate
- `sortOrder` - asc | desc

---

## 🎨 APP FEATURES

### Authentication
- ✅ Registration with email, username, password
- ✅ Login with JWT tokens
- ✅ Secure token storage (flutter_secure_storage)
- ✅ Automatic token refresh on 401 errors
- ✅ Logout with token revocation
- ✅ Session persistence (auto-login)

### Task Dashboard
- ✅ Stats card with completion rate
- ✅ Task list with ListView.builder (efficient rendering)
- ✅ Pull-to-refresh
- ✅ Infinite scroll / pagination
- ✅ Search tasks by title/description
- ✅ Filter by status and priority
- ✅ Swipe to edit/delete (flutter_slidable)
- ✅ Animated task cards

### Task Management (CRUD)
- ✅ Create task with title, description, status, priority, due date, tags
- ✅ View task details
- ✅ Edit task
- ✅ Delete task with confirmation
- ✅ Toggle task status (pending ↔ completed)

### UI/UX
- ✅ Beautiful beige/terracotta color scheme
- ✅ Playfair Display + Lato typography
- ✅ Smooth animations (flutter_animate)
- ✅ Shimmer loading states
- ✅ Error snackbars with icons
- ✅ Priority color strips on cards
- ✅ Overdue task highlighting
- ✅ Tag chips

### Architecture
- ✅ Clean architecture: UI → Providers → Repositories → Services
- ✅ Riverpod state management
- ✅ GoRouter navigation
- ✅ Dependency injection via Riverpod

---

## 🐛 TROUBLESHOOTING

### "Connection refused" error in app
- Make sure backend is running: `npm run dev`
- Check the baseUrl in `app_config.dart`
- For emulator, use `10.0.2.2:3000`

### Flutter packages not found
```bash
flutter pub get
flutter clean
flutter pub get
```

### Prisma errors
```bash
npx prisma db push
npx prisma generate
```

### Android SDK not found
- Open Android Studio → SDK Manager
- Install Android SDK (API 33 or 34)
- Set ANDROID_HOME environment variable

### "flutter: command not found"
- Make sure Flutter bin folder is in your PATH
- Restart terminal after updating PATH

---

## 🚀 DEPLOYMENT TIPS

For production deployment:
1. Change JWT secrets to strong random strings
2. Use PostgreSQL instead of SQLite (change `provider = "postgresql"` in schema.prisma)
3. Deploy backend to Railway, Render, or Heroku
4. Update `baseUrl` in Flutter app to your deployed backend URL
5. Build release APK: `flutter build apk --release`
