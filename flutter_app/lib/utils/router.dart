import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/tasks/task_dashboard_screen.dart';
import '../screens/tasks/task_detail_screen.dart';
import '../screens/tasks/create_task_screen.dart';
import '../screens/profile/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isInitialized = authState.isInitialized;
      final isAuthenticated = authState.isAuthenticated;
      final isSplash = state.matchedLocation == '/splash';
      final isAuth = state.matchedLocation.startsWith('/auth');

      if (!isInitialized) return '/splash';
      if (isSplash && isInitialized) {
        return isAuthenticated ? '/tasks' : '/auth/login';
      }
      if (!isAuthenticated && !isAuth && !isSplash) return '/auth/login';
      if (isAuthenticated && isAuth) return '/tasks';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/auth/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/auth/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/tasks',
        builder: (_, __) => const TaskDashboardScreen(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (_, __) => const CreateTaskScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final taskId = state.pathParameters['id']!;
              return TaskDetailScreen(taskId: taskId);
            },
          ),
          GoRoute(
            path: ':id/edit',
            builder: (context, state) {
              final taskId = state.pathParameters['id']!;
              return CreateTaskScreen(taskId: taskId);
            },
          ),
        ],
      ),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    ],
  );
});
