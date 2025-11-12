import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:frontend/app/models/product_model.dart';
import 'package:frontend/app/providers/auth_provider.dart';
import 'package:frontend/app/providers/client_provider.dart';

const String _baseUrl = 'http://localhost:3000';

final productsProvider = StateNotifierProvider<ProductsNotifier, AsyncValue<List<ProductModel>>>((ref) {
  final token = ref.watch(authProvider.select((state) => state.accessToken));
  final dio = ref.read(dioProvider);

  return ProductsNotifier(dio, token);
});

class ProductsNotifier extends StateNotifier<AsyncValue<List<ProductModel>>> {
  final Dio _dio;
  final String? _token;

  ProductsNotifier(this._dio, this._token) : super(const AsyncValue.loading()) {
    if (_token != null) {
      fetchProducts();
    } else {
      state = AsyncValue.error('User not authenticated.', StackTrace.current);
    }
  }

  Future<void> fetchProducts() async {
    state = const AsyncValue.loading();

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
      
      state = AsyncValue.data(products);

    } on DioException catch (e) {
      state = AsyncValue.error(e.response?.data['message'] ?? 'Failed to load products.', StackTrace.current);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }
  
  void filterByProvider(String? provider) {
  }
}