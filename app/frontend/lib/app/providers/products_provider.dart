import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:frontend/app/models/product_model.dart';
import 'package:frontend/app/providers/auth_provider.dart';
import 'package:frontend/service/products_service.dart'; 

final productsProvider = StateNotifierProvider<ProductsNotifier, AsyncValue<List<ProductModel>>>((ref) {
  final token = ref.watch(authProvider.select((state) => state.accessToken));
  
  final productsService = ref.watch(productsServiceProvider(token));

  return ProductsNotifier(productsService, token);
});

class ProductsNotifier extends StateNotifier<AsyncValue<List<ProductModel>>> {
  final ProductsService _productsService;
  final String? _token;

  ProductsNotifier(this._productsService, this._token) : super(const AsyncValue.loading()) {
    if (_token != null) {
      fetchProducts();
    } else {
      state = AsyncValue.error('User not authenticated.', StackTrace.current);
    }
  }

  Future<void> fetchProducts() async {
    state = const AsyncValue.loading();

    try {
      final products = await _productsService.fetchProducts();
      
      state = AsyncValue.data(products);

    } on DioException catch (e) {
      final errorMsg = e.response?.data['message'] ?? 'Failed to load products.';
      state = AsyncValue.error(errorMsg, StackTrace.current);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }
  
  void filterByProvider(String? provider) {
    // ... Implementação de filtro ...
  }
}