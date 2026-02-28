import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class ApiService {
  late final Dio _dio;
  final FlutterSecureStorage _storage;
  bool _isRefreshing = false;

  ApiService(this._storage) {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: AppConfig.accessTokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 &&
              !_isRefreshing &&
              !error.requestOptions.path.contains('/auth/refresh')) {
            _isRefreshing = true;
            try {
              final refreshed = await _refreshTokens();
              if (refreshed) {
                final token = await _storage.read(key: AppConfig.accessTokenKey);
                final opts = error.requestOptions;
                opts.headers['Authorization'] = 'Bearer $token';
                final response = await _dio.fetch(opts);
                _isRefreshing = false;
                return handler.resolve(response);
              }
            } catch (_) {}
            _isRefreshing = false;
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> _refreshTokens() async {
    try {
      final refreshToken = await _storage.read(key: AppConfig.refreshTokenKey);
      if (refreshToken == null) return false;

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {'Authorization': null},
        ),
      );

      final data = response.data as Map<String, dynamic>;
      await _storage.write(
        key: AppConfig.accessTokenKey,
        value: data['accessToken'] as String,
      );
      await _storage.write(
        key: AppConfig.refreshTokenKey,
        value: data['refreshToken'] as String,
      );
      return true;
    } catch (_) {
      // Clear tokens on refresh failure
      await _storage.delete(key: AppConfig.accessTokenKey);
      await _storage.delete(key: AppConfig.refreshTokenKey);
      await _storage.delete(key: AppConfig.userDataKey);
      return false;
    }
  }

  // ─── Auth endpoints ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
  }) async {
    final response = await _dio.post('/auth/register', data: {
      'email': email,
      'username': username,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<void> logout({String? refreshToken}) async {
    try {
      await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
    } catch (_) {}
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await _dio.get('/auth/me');
    return response.data as Map<String, dynamic>;
  }

  // ─── Task endpoints ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getTasks({
    int page = 1,
    int limit = 10,
    String? status,
    String? priority,
    String? search,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };
    if (status != null) params['status'] = status;
    if (priority != null) params['priority'] = priority;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final response = await _dio.get('/tasks', queryParameters: params);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getTaskById(String id) async {
    final response = await _dio.get('/tasks/$id');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createTask({
    required String title,
    String? description,
    String? status,
    String? priority,
    String? dueDate,
    List<String>? tags,
  }) async {
    final response = await _dio.post('/tasks', data: {
      'title': title,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (dueDate != null) 'dueDate': dueDate,
      if (tags != null) 'tags': tags,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateTask(
    String id, {
    String? title,
    String? description,
    String? status,
    String? priority,
    String? dueDate,
    List<String>? tags,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (status != null) data['status'] = status;
    if (priority != null) data['priority'] = priority;
    if (dueDate != null) data['dueDate'] = dueDate;
    if (tags != null) data['tags'] = tags;

    final response = await _dio.patch('/tasks/$id', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteTask(String id) async {
    await _dio.delete('/tasks/$id');
  }

  Future<Map<String, dynamic>> toggleTask(String id) async {
    final response = await _dio.post('/tasks/$id/toggle');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getTaskStats() async {
    final response = await _dio.get('/tasks/stats');
    return response.data as Map<String, dynamic>;
  }

  // ─── User endpoints ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> updateProfile({
    String? username,
    String? email,
  }) async {
    final response = await _dio.patch('/users/profile', data: {
      if (username != null) 'username': username,
      if (email != null) 'email': email,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.post('/users/change-password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }
}
