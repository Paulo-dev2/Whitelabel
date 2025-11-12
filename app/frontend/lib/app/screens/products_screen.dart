import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/providers/auth_provider.dart';
import 'package:frontend/app/providers/products_provider.dart';
import 'package:frontend/app/widgets/filter_dropdown.dart'; 
import 'package:frontend/app/widgets/product_grid_card.dart'; 

final selectedProviderFilter = StateProvider<String?>((ref) => null);

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsyncValue = ref.watch(productsProvider);
    final filter = ref.watch(selectedProviderFilter);
    final theme = Theme.of(context);
    
    void handleLogout() {
      ref.read(authProvider.notifier).logout();
    }

    final filteredProducts = productsAsyncValue.when(
      data: (products) {
        if (filter == null || filter == 'Todos') {
          return products;
        }
        return products.where((p) => p.provider == filter!.toLowerCase()).toList();
      },
      loading: () => const [],
      error: (e, st) => const [],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Produtos'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: theme.colorScheme.onSurface),
            onPressed: handleLogout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header com filtro
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const FilterDropdown(), // Chama o widget dedicado
          ),
          
          // Contador de produtos
          if (filteredProducts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    '${filteredProducts.length} produto${filteredProducts.length != 1 ? 's' : ''} encontrado${filteredProducts.length != 1 ? 's' : ''}',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          
          // Lista de produtos
          Expanded(
            child: productsAsyncValue.when(
              // Estado de Loading
              loading: () => const Center(child: CircularProgressIndicator()),
              
              // Estado de Erro
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text(
                      error.toString().contains('Unauthorized') 
                          ? 'Sessão expirada. Faça login novamente.'
                          : 'Erro ao carregar produtos.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Estado de Dados
              data: (products) {
                if (filteredProducts.isEmpty && products.isNotEmpty) {
                   return Center(child: Text('Nenhum produto corresponde ao filtro.', style: TextStyle(color: Colors.grey[500])));
                }
                if (filteredProducts.isEmpty && products.isEmpty) {
                   return Center(child: Text('Nenhum produto disponível.', style: TextStyle(color: Colors.grey[500])));
                }
                
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredProducts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return ProductGridCard(product: product); // Chama o widget dedicado
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}