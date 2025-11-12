import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/models/product_model.dart';
import 'package:frontend/app/providers/client_provider.dart'; 

const String _baseUrl = 'http://localhost:3000';

final productsServiceProvider = Provider.family<ProductsService, String?>((ref, token) {
  return ProductsService(ref.read(dioProvider), token);
});


class ProductsService {
  final Dio _dio;
  final String? _token;

  ProductsService(this._dio, this._token);

  Future<List<ProductModel>> fetchProducts() async {
    if (_token == null) {
      throw Exception("Authentication token is missing.");
    }
    
    try {
      final response = await _dio.get(
        '$_baseUrl/products',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_token', 
          },
        ),
      );

      final List data = response.data['data'] as List;
      final products = data.map((item) => ProductModel.fromJson(item)).toList();

      return products;

    } on DioException catch (e) {
      throw e; 
    } catch (e) {
      throw Exception('Erro desconhecido ao carregar produtos: ${e.toString()}');
    }
  }
}