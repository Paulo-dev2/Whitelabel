import 'package:flutter/material.dart';
import 'package:frontend/app/models/product_model.dart';

class ProductGridCard extends StatelessWidget {
  final ProductModel product;

  const ProductGridCard({super.key, required this.product});

  // Utilitário para ícone placeholder
  Widget _buildPlaceholderIcon(ThemeData theme) {
    return Center(
      child: Icon(
        Icons.shopping_bag_outlined,
        size: 50,
        color: theme.primaryColor.withOpacity(0.5),
      ),
    );
  }

  // Utilitário para Tag de Preço Dinâmico
  Widget _buildPriceTag(ThemeData theme, double price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        'R\$${price.toStringAsFixed(2)}',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // Utilitário para Capitalizar o Fornecedor (brazilian -> Brazilian)
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // Utilitário para formatar a exibição do ID
  String _formatProductId(String id) {
    if (id.length <= 8) {
      return 'ID: $id';
    }
    return 'ID: ${id.substring(0, 8)}...';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Área da Imagem e Preço em Stack
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.grey[100],
                  child: product.image != null && product.image!.isNotEmpty
                      ? Image.network(
                          product.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                            _buildPlaceholderIcon(theme),
                        )
                      : _buildPlaceholderIcon(theme),
                ),
                
                // Badge do fornecedor
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
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

                // Preço Destacado
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: _buildPriceTag(theme, product.price),
                ),
              ],
            ),
          ),
          
          // Área de Detalhes
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
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // ID
                  Text(
                    _formatProductId(product.id),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}