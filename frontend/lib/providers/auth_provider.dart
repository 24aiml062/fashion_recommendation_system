import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  User? _user;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isOnboarded => _user?.onboardingComplete ?? false;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> init() async {
    final token = await _storage.read(key: 'token');
    if (token != null) {
      apiService.setToken(token);
      try {
        final data = await apiService.get('/auth/me');
        _user = User.fromJson(data);
        notifyListeners();
      } catch (_) {
        await _storage.delete(key: 'token');
        apiService.clearToken();
      }
    }
  }

  Future<bool> signup(String email, String fullName, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await apiService.post('/auth/signup', {
        'email': email,
        'full_name': fullName,
        'password': password,
      });
      await _saveToken(data['access_token']);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });
      await _saveToken(data['access_token']);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
    apiService.clearToken();
    _user = null;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    try {
      final data = await apiService.get('/auth/me');
      _user = User.fromJson(data);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
    apiService.setToken(token);
    final data = await apiService.get('/auth/me');
    _user = User.fromJson(data);
  }
}
