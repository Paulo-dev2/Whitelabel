import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/providers/client_provider.dart';

const String _baseUrl = 'http://localhost:3000';

final authServiceProvider = Provider((ref) {
  return AuthService(ref.read(dioProvider));
});

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<String> login({
    required String email,
    required String password,
    required int clientId,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/login',
        data: {
          'email': email,
          'password': password,
          'clientId': clientId,
        },
      );

      final token = response.data['access_token'] as String;
      return token;

    } on DioException catch (e) {
      throw e; 
    } catch (e) {
      throw Exception('Erro desconhecido na API de login.');
    }
  }
}