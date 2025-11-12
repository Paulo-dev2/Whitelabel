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
    final theme = Theme.of(context);
    
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
      loading: () => <ProductModel>[],
      error: (e, st) => <ProductModel>[],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Catálogo de Produtos',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
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
            child: _buildFilterDropdown(ref, filter),
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
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Carregando produtos...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar produtos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString().contains('token') 
                            ? 'Sessão expirada. Faça login novamente.'
                            : 'Verifique sua conexão e tente novamente',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              data: (products) {
                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          filter == null || filter == 'Todos' 
                              ? 'Nenhum produto disponível'
                              : 'Nenhum produto do fornecedor $filter',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  );
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
                    return ProductGridCard(product: product);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(WidgetRef ref, String? currentFilter) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Filtrar por fornecedor',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(ref.context).primaryColor),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      borderRadius: BorderRadius.circular(12),
      value: currentFilter ?? 'Todos',
      items: const [
        'Todos',
        'brazilian',
        'european',
      ].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value == 'Todos' ? 'Todos os fornecedores' : value,
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        ref.read(selectedProviderFilter.notifier).state = newValue;
      },
    );
  }
}

class ProductGridCard extends StatelessWidget {
  final ProductModel product;

  const ProductGridCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagem do produto
            Expanded(
              flex: 6,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      theme.colorScheme.surfaceVariant.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    if (product.image != null && product.image!.isNotEmpty)
                      Image.network(
                        product.image!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / 
                                    loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => 
                            _buildPlaceholderIcon(theme),
                      )
                    else
                      _buildPlaceholderIcon(theme),
                    
                    // Badge do fornecedor
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _capitalizeFirstLetter(product.provider),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Informações do produto
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Título
                    Text(
                      product.title ?? 'Produto Sem Nome',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Preço e ID
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'R\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatProductId(product.id),
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon(ThemeData theme) {
    return Center(
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.shopping_bag,
          size: 32,
          color: theme.colorScheme.primary.withOpacity(0.6),
        ),
      ),
    );
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _formatProductId(String id) {
    if (id.length <= 8) {
      return 'ID: $id';
    }
    return 'ID: ${id.substring(0, 8)}...';
  }
}