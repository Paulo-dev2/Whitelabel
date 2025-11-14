import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/models/client_model.dart';
import 'package:frontend/app/providers/client_provider.dart';

import 'dart:html' if (dart.library.html) 'dart:html' as html;
import 'package:flutter/foundation.dart';

const String _baseUrl = 'http://localhost:3000';

final clientServiceProvider = Provider((ref) {
  return ClientService(ref.read(dioProvider));
});

class ClientService {
  final Dio _dio;

  ClientService(this._dio);
  
  String getHostFromEnvironment() {
    if (kIsWeb) {
      return html.window.location.host; 
    }
    
    return 'alpha.local'; 
  }

  Future<ClientModel> fetchClientConfig() async {
    final fullHost = getHostFromEnvironment(); 
    final hostUrl = fullHost.split(':')[0]; 

    try {
      final response = await _dio.get(
        '$_baseUrl/clients/config',
        queryParameters: {'domain': hostUrl},
      );

      return ClientModel.fromJson(response.data);

    } on DioException catch (e) {
      throw e; 
    } catch (e) {
      throw Exception('Erro desconhecido ao buscar cliente.');
    }
  }
}