import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';

class StorageService {
  final FlutterSecureStorage _storage;

  StorageService(this._storage);

  Future<void> saveTokens(AuthTokens tokens) async {
    await Future.wait([
      _storage.write(key: AppConfig.accessTokenKey, value: tokens.accessToken),
      _storage.write(key: AppConfig.refreshTokenKey, value: tokens.refreshToken),
    ]);
  }

  Future<AuthTokens?> getTokens() async {
    final accessToken = await _storage.read(key: AppConfig.accessTokenKey);
    final refreshToken = await _storage.read(key: AppConfig.refreshTokenKey);
    if (accessToken == null || refreshToken == null) return null;
    return AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  Future<void> saveUser(UserModel user) async {
    await _storage.write(
      key: AppConfig.userDataKey,
      value: jsonEncode(user.toJson()),
    );
  }

  Future<UserModel?> getUser() async {
    final userData = await _storage.read(key: AppConfig.userDataKey);
    if (userData == null) return null;
    return UserModel.fromJson(jsonDecode(userData) as Map<String, dynamic>);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final tokens = await getTokens();
    return tokens != null;
  }
}
