import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../repositories/auth_repository.dart';
import '../repositories/task_repository.dart';
import '../models/user_model.dart';
import '../models/task_model.dart';

// ─── Core Providers ───────────────────────────────────────────────────────────

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(ref.watch(secureStorageProvider));
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref.watch(secureStorageProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiServiceProvider),
    ref.watch(storageServiceProvider),
  );
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.watch(apiServiceProvider));
});

// ─── Auth State ───────────────────────────────────────────────────────────────

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isInitialized;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isInitialized = false,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isInitialized,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    final user = await _repository.getCurrentUser();
    state = state.copyWith(user: user, isInitialized: true);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.login(email: email, password: password);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('AuthException: ', ''),
      );
      return false;
    }
  }

  Future<bool> register(String email, String username, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.register(
        email: email,
        username: username,
        password: password,
      );
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('AuthException: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(isInitialized: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

// ─── Task Filter State ────────────────────────────────────────────────────────

class TaskFilter {
  final String? status;
  final String? priority;
  final String search;
  final String sortBy;
  final String sortOrder;

  const TaskFilter({
    this.status,
    this.priority,
    this.search = '',
    this.sortBy = 'createdAt',
    this.sortOrder = 'desc',
  });

  TaskFilter copyWith({
    String? status,
    String? priority,
    String? search,
    String? sortBy,
    String? sortOrder,
    bool clearStatus = false,
    bool clearPriority = false,
  }) {
    return TaskFilter(
      status: clearStatus ? null : (status ?? this.status),
      priority: clearPriority ? null : (priority ?? this.priority),
      search: search ?? this.search,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

final taskFilterProvider = StateProvider<TaskFilter>((ref) => const TaskFilter());

// ─── Task List State ──────────────────────────────────────────────────────────

class TaskListState {
  final List<TaskModel> tasks;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final PaginationInfo? pagination;
  final int currentPage;

  const TaskListState({
    this.tasks = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.pagination,
    this.currentPage = 1,
  });

  bool get hasMore => pagination?.hasMore ?? false;

  TaskListState copyWith({
    List<TaskModel>? tasks,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    PaginationInfo? pagination,
    int? currentPage,
    bool clearError = false,
  }) {
    return TaskListState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      pagination: pagination ?? this.pagination,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class TaskListNotifier extends StateNotifier<TaskListState> {
  final TaskRepository _repository;
  final Ref _ref;

  TaskListNotifier(this._repository, this._ref) : super(const TaskListState());

  TaskFilter get _filter => _ref.read(taskFilterProvider);

  Future<void> loadTasks({bool refresh = false}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repository.getTasks(
        page: 1,
        limit: 10,
        status: _filter.status,
        priority: _filter.priority,
        search: _filter.search.isEmpty ? null : _filter.search,
        sortBy: _filter.sortBy,
        sortOrder: _filter.sortOrder,
      );
      state = state.copyWith(
        tasks: result.tasks,
        pagination: result.pagination,
        currentPage: 1,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('TaskException: ', ''),
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final result = await _repository.getTasks(
        page: nextPage,
        limit: 10,
        status: _filter.status,
        priority: _filter.priority,
        search: _filter.search.isEmpty ? null : _filter.search,
        sortBy: _filter.sortBy,
        sortOrder: _filter.sortOrder,
      );
      state = state.copyWith(
        tasks: [...state.tasks, ...result.tasks],
        pagination: result.pagination,
        currentPage: nextPage,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<bool> createTask({
    required String title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    List<String>? tags,
  }) async {
    try {
      await _repository.createTask(
        title: title,
        description: description,
        status: status,
        priority: priority,
        dueDate: dueDate,
        tags: tags,
      );
      await loadTasks(refresh: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateTask(String id, {
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    List<String>? tags,
  }) async {
    try {
      final updated = await _repository.updateTask(id,
        title: title,
        description: description,
        status: status,
        priority: priority,
        dueDate: dueDate,
        tags: tags,
      );
      state = state.copyWith(
        tasks: state.tasks.map((t) => t.id == id ? updated : t).toList(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteTask(String id) async {
    try {
      await _repository.deleteTask(id);
      state = state.copyWith(
        tasks: state.tasks.where((t) => t.id != id).toList(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleTask(String id) async {
    try {
      final updated = await _repository.toggleTask(id);
      state = state.copyWith(
        tasks: state.tasks.map((t) => t.id == id ? updated : t).toList(),
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}

final taskListProvider =
    StateNotifierProvider<TaskListNotifier, TaskListState>((ref) {
  return TaskListNotifier(ref.watch(taskRepositoryProvider), ref);
});

// ─── Task Stats Provider ──────────────────────────────────────────────────────

final taskStatsProvider = FutureProvider<TaskStats>((ref) async {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.getStats();
});
