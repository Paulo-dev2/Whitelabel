import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:frontend/providers/client_provider.dart'; // Para acessar o dioProvider
import 'package:shared_preferences/shared_preferences.dart';

// Constante para a chave do token no armazenamento local
const String _accessTokenKey = 'access_token';
const String _baseUrl = 'http://localhost:3000';

// Estado de Autenticação: Armazena o token e o status de login
class AuthState {
  final String? accessToken;
  final bool isLoading;
  final String? errorMessage;

  AuthState({this.accessToken, this.isLoading = false, this.errorMessage});

  // Conveniência: Se o token existir, o usuário está logado
  bool get isAuthenticated => accessToken != null;

  // Cria novas instâncias (imutabilidade exigida pelo StateNotifier)
  AuthState copyWith({
    String? accessToken,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      accessToken: accessToken,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// Provedor que gerencia o estado de autenticação (token, status)
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(dioProvider),
    SharedPreferences.getInstance(),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Dio _dio;
  final Future<SharedPreferences> _prefsFuture;

  AuthNotifier(this._dio, this._prefsFuture) : super(AuthState()) {
    // Tenta carregar o token salvo ao iniciar o aplicativo
    _loadSavedToken();
  }

  // --- Lógica de persistência ---
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
  
  // --- Lógica de Login ---
  Future<void> login({
    required String email,
    required String password,
    required int clientId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _dio.post(
        '$_baseUrl/auth/login',
        data: {
          'email': email,
          'password': password,
          'clientId': clientId, // ID do Cliente obtida no passo Whitelabel
        },
      );

      final token = response.data['access_token'] as String;
      
      await _saveToken(token); // Salva no Shared Preferences
      state = AuthState(accessToken: token); // Atualiza o estado do app

    } on DioException catch (e) {
      final errorMsg = e.response?.data['message'] ?? 'Falha no login.';
      state = state.copyWith(isLoading: false, errorMessage: errorMsg);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erro desconhecido.');
    }
  }

  // --- Lógica de Logout ---
  Future<void> logout() async {
    final prefs = await _prefsFuture;
    await prefs.remove(_accessTokenKey);
    state = AuthState();
  }
}