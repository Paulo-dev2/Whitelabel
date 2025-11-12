import 'package:flutter/foundation.dart';

@immutable
class ProductModel {
  final String id;
  // Tornar title opcional, pois alguns itens BR não o possuem
  final String? title; 
  final String? description; // Assumindo que description também pode faltar
  final double price;
  final String provider;
  final String? image;

  const ProductModel({
    required this.id,
    this.title, // Já opcional
    this.description, // Já opcional
    required this.price,
    required this.provider,
    this.image,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Tratamento para o campo price (string para double)
    double parsedPrice = 0.0;
    final priceValue = json['price'];
    if (priceValue is num) {
      parsedPrice = priceValue.toDouble();
    } else if (priceValue is String) {
      parsedPrice = double.tryParse(priceValue) ?? 0.0;
    }
    
    // Tratamento para o campo image (String ou List<String>)
    String? imageUrl;
    final imageValue = json['image'];
    if (imageValue is String) {
      imageUrl = imageValue;
    } else if (imageValue is List && imageValue.isNotEmpty) {
      // Se for uma lista, pega apenas a primeira URL
      imageUrl = imageValue.first as String?; 
    }
    
    // NOTA: Para os produtos brasileiros que não tem title no mock, 
    // faremos um fallback para 'Produto Sem Nome' ou 'id'
    final productTitle = json['title'] as String?;
    
    return ProductModel(
      id: json['id'] as String,
      // Se title for null, use um valor padrão (fallback para id)
      title: productTitle ?? 'Produto ID: ${json['id']}',
      description: json['description'] as String?,
      price: parsedPrice,
      provider: json['provider'] as String,
      image: imageUrl,
    );
  }
}