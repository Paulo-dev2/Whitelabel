import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:frontend/app/models/client_model.dart';
import 'package:frontend/service/client_service.dart'; 

final dioProvider = Provider((ref) => Dio());

final clientProvider = StateNotifierProvider<ClientNotifier, AsyncValue<ClientModel>>((ref) {
  return ClientNotifier(ref.read(clientServiceProvider));
});

class ClientNotifier extends StateNotifier<AsyncValue<ClientModel>> {
  final ClientService _clientService;

  ClientNotifier(this._clientService) : super(const AsyncValue.loading()) {
    identifyClient();
  }

  Future<void> identifyClient() async {
    state = const AsyncValue.loading();

    try {
      final client = await _clientService.fetchClientConfig();
      state = AsyncValue.data(client);

    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      state = AsyncValue.error('Falha na identificação Whitelabel: $statusCode', StackTrace.current);
    } catch (e) {
      state = AsyncValue.error('Erro desconhecido: $e', StackTrace.current);
    }
  }
}