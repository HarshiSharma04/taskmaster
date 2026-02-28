import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthException implements Exception {
  final String message;
  final int? statusCode;
  const AuthException(this.message, {this.statusCode});
}

class AuthRepository {
  final ApiService _api;
  final StorageService _storage;

  AuthRepository(this._api, this._storage);

  Future<UserModel> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final data = await _api.register(
        email: email,
        username: username,
        password: password,
      );
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final tokens = AuthTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
      await _storage.saveTokens(tokens);
      await _storage.saveUser(user);
      return user;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = await _api.login(email: email, password: password);
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final tokens = AuthTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
      await _storage.saveTokens(tokens);
      await _storage.saveUser(user);
      return user;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      final tokens = await _storage.getTokens();
      await _api.logout(refreshToken: tokens?.refreshToken);
    } catch (_) {}
    await _storage.clearAll();
  }

  Future<UserModel?> getCurrentUser() async {
    return _storage.getUser();
  }

  Future<bool> isLoggedIn() async {
    return _storage.isLoggedIn();
  }

  Future<UserModel> refreshUser() async {
    try {
      final data = await _api.getMe();
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await _storage.saveUser(user);
      return user;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AuthException _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final message = (e.response?.data as Map<String, dynamic>?)?['message'] as String?;

    return AuthException(
      message ?? _defaultMessage(statusCode),
      statusCode: statusCode,
    );
  }

  String _defaultMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid input. Please check your details.';
      case 401:
        return 'Invalid credentials. Please try again.';
      case 409:
        return 'This email or username is already taken.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
