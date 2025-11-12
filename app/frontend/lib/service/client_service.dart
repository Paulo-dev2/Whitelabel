import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/models/client_model.dart';
import 'package:frontend/app/providers/client_provider.dart'; 

const String _baseUrl = 'http://localhost:3000';

final clientServiceProvider = Provider((ref) {
  return ClientService(ref.read(dioProvider));
});

class ClientService {
  final Dio _dio;

  ClientService(this._dio);
  
  String getHostSimulated() {
    return 'alpha.local'; 
  }

  Future<ClientModel> fetchClientConfig() async {
    final hostUrl = getHostSimulated();
    
    try {
      final response = await _dio.get(
        '$_baseUrl/clients/config',
         options: Options(
          headers: {'Domain': hostUrl}, 
        ),
      );

      return ClientModel.fromJson(response.data);

    } on DioException catch (e) {
      throw e; 
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar cliente.');
    }
  }
}