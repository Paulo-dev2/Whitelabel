import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/service/auth_service.dart'; // Importa o novo serviço

// Constante para a chave do token no armazenamento local
const String _accessTokenKey = 'access_token';

// --- AuthState (Permanece o mesmo) ---
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

// Provedor que gerencia o estado de autenticação (token, status)
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    // Injeta o AuthService (responsável pela API)
    ref.read(authServiceProvider), 
    SharedPreferences.getInstance(),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  // Agora injetamos o AuthService e não mais o Dio diretamente
  final AuthService _authService; 
  final Future<SharedPreferences> _prefsFuture;

  AuthNotifier(this._authService, this._prefsFuture) : super(AuthState()) {
    _loadSavedToken();
  }

  // --- Lógica de persistência (Permanece a mesma) ---
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
  
  // --- Lógica de Login (Agora delega a chamada ao serviço) ---
  Future<void> login({
    required String email,
    required String password,
    required int clientId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 💡 DELEGAÇÃO: Chama o serviço para fazer a requisição
      final token = await _authService.login(
        email: email,
        password: password,
        clientId: clientId,
      );
      
      await _saveToken(token);
      state = AuthState(accessToken: token, isLoading: false);

    } on DioException catch (e) {
      // Captura o erro do serviço e formata a mensagem para a UI
      final errorMsg = e.response?.data['message'] ?? 'Falha no login.';
      state = state.copyWith(isLoading: false, errorMessage: errorMsg);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erro desconhecido.');
    }
  }

  // --- Lógica de Logout (Permanece a mesma) ---
  Future<void> logout() async {
    final prefs = await _prefsFuture;
    await prefs.remove(_accessTokenKey);
    state = AuthState();
  }
}