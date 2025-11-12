import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/service/auth_service.dart'; 

const String _accessTokenKey = 'access_token';

class AuthState {
  final String? accessToken;
  final bool isLoading;
  final String? errorMessage;

  AuthState({this.accessToken, this.isLoading = false, this.errorMessage});

  bool get isAuthenticated => accessToken != null;

  AuthState copyWith({
    String? accessToken,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      accessToken: accessToken ?? this.accessToken,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authServiceProvider), 
    SharedPreferences.getInstance(),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService; 
  final Future<SharedPreferences> _prefsFuture;

  AuthNotifier(this._authService, this._prefsFuture) : super(AuthState()) {
    _loadSavedToken();
  }

  Future<void> _loadSavedToken() async {
    final prefs = await _prefsFuture;
    final token = prefs.getString(_accessTokenKey);
    if (token != null) {
      state = AuthState(accessToken: token);
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await _prefsFuture;
    await prefs.setString(_accessTokenKey, token);
  }
  
  Future<void> login({
    required String email,
    required String password,
    required int clientId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final token = await _authService.login(
        email: email,
        password: password,
        clientId: clientId,
      );
      
      await _saveToken(token);
      state = AuthState(accessToken: token, isLoading: false);

    } on DioException catch (e) {
      final errorMsg = e.response?.data['message'] ?? 'Falha no login.';
      state = state.copyWith(isLoading: false, errorMessage: errorMsg);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erro desconhecido.');
    }
  }

  Future<void> logout() async {
    final prefs = await _prefsFuture;
    await prefs.remove(_accessTokenKey);
    state = AuthState();
  }
}