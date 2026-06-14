import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_service.dart';
import '../data/auth_models.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final FlutterSecureStorage _storage;

  AuthNotifier(this._apiService, this._storage) : super(AuthState()) {
    // We'll trigger auth check from SplashScreen instead
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final token = await _storage.read(key: 'auth_token');
      
      if (token != null) {
        // Try to get current user to validate token
        final userData = await _apiService.getMe();
        final user = User.fromJson(userData);
        
        // Save updated user data
        await _storage.write(key: 'user_data', jsonEncode(user.toJson()));
        
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      // If any error (invalid token, etc.), clear storage and set to unauthenticated
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'user_data');
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    
    try {
      final response = await _apiService.login(email, password);
      
      final user = User.fromJson(response['user']);
      final token = response['token'];
      
      // Save token and user data
      await _storage.write(key: 'auth_token', token);
      await _storage.write(key: 'user_data', jsonEncode(user.toJson()));
      
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    
    try {
      final response = await _apiService.register(name, email, password);
      
      final user = User.fromJson(response['user']);
      final token = response['token'];
      
      // Save token and user data
      await _storage.write(key: 'auth_token', token);
      await _storage.write(key: 'user_data', jsonEncode(user.toJson()));
      
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      // Ignore logout errors
    }
    
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_data');
    
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
    );
  }

  String? getUserRole() {
    return state.user?.role;
  }

  bool get isAdmin => state.user?.isAdmin ?? false;
  bool get isUser => state.user?.isUser ?? false;
  bool get isAuthenticated => state.status == AuthStatus.authenticated;
}

// Providers
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(apiServiceProvider),
    const FlutterSecureStorage(),
  );
});
