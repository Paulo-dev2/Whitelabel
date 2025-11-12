import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:frontend/models/client_model.dart';

// URL base da API do Backend NestJS
const String _baseUrl = 'http://localhost:3000';

// Provedor de Injeção de Dependência para o Cliente HTTP (Dio)
final dioProvider = Provider((ref) => Dio());

// Provedor que expõe o estado de carregamento do Cliente (tema e ID)
final clientProvider = StateNotifierProvider<ClientNotifier, AsyncValue<ClientModel>>((ref) {
  // Passa a instância do Dio para o Notifier
  return ClientNotifier(ref.read(dioProvider));
});

class ClientNotifier extends StateNotifier<AsyncValue<ClientModel>> {
  final Dio _dio;

  ClientNotifier(this._dio) : super(const AsyncValue.loading()) {
    // Inicia a identificação Whitelabel assim que o Notifier é criado
    identifyClient();
  }

  // 1. Simulação da leitura do Host
  // Em um ambiente Web real, usaríamos o `dart:html` para ler o window.location.host.
  // Em Mobile/Desktop, podemos simular a leitura do host através de variáveis de ambiente.
  String getHostSimulated() {
    // Para teste, altere esta string para 'beta.local' para ver a troca de tema
    return 'alpha.local'; 
  }

  // 2. Lógica de Chamada à API Whitelabel
  Future<void> identifyClient() async {
    state = const AsyncValue.loading();

    try {
      final hostUrl = getHostSimulated();
      
      final response = await _dio.get(
        '$_baseUrl/clients/config',
        options: Options(
          headers: {'Domain': hostUrl}, 
        ),
      );

      final client = ClientModel.fromJson(response.data);
      state = AsyncValue.data(client);

    } on DioException catch (e) {
      state = AsyncValue.error('Falha na identificação Whitelabel: ${e.response?.statusCode}', StackTrace.current);
    } catch (e) {
      state = AsyncValue.error('Erro desconhecido: $e', StackTrace.current);
    }
  }
}