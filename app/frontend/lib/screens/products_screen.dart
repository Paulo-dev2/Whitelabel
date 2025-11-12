import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/product_model.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/products_provider.dart';

final selectedProviderFilter = StateProvider<String?>((ref) => null);

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsyncValue = ref.watch(productsProvider);
    final filter = ref.watch(selectedProviderFilter);
    
    // Botão de Logout
    void handleLogout() {
      ref.read(authProvider.notifier).logout();
    }

    final filteredProducts = productsAsyncValue.when(
      data: (products) {
        if (filter == null || filter == 'Todos') {
          return products;
        }
        return products.where((p) => p.provider == filter.toLowerCase()).toList();
      },
      loading: () => [],
      error: (e, st) => [],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Produtos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: handleLogout,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterDropdown(ref, filter),
          
          Expanded(
            child: productsAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Erro ao carregar produtos. Token expirado? ${e.toString()}'),
                ),
              ),
              // 3. Listagem de Produtos
              data: (_) => ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return ProductCard(product: product);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(WidgetRef ref, String? currentFilter) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Filtrar por Fornecedor',
          border: OutlineInputBorder(),
        ),
        value: currentFilter ?? 'Todos',
        items: const [
          'Todos',
          'brazilian',
          'european',
        ].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (newValue) {
          ref.read(selectedProviderFilter.notifier).state = newValue;
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: product.image != null
            ? Image.network(product.image!, width: 50, height: 50, fit: BoxFit.cover,
                errorBuilder: (c, o, s) => const Icon(Icons.shopping_bag))
            : const Icon(Icons.shopping_bag),
        title: Text(product.title ?? 'Produto Sem Nome'),
        subtitle: Text('${product.provider.toUpperCase()} | \$${product.price.toStringAsFixed(2)}'),
        trailing: Text(product.id, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}