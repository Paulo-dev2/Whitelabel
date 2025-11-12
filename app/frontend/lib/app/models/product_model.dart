import 'package:flutter/foundation.dart';

@immutable
class ProductModel {
  final String id;
  final String? title; 
  final String? description; 
  final double price;
  final String provider;
  final String? image;
  final String? sku;

  const ProductModel({
    required this.id,
    this.title, 
    this.description, 
    required this.price,
    required this.provider,
    this.image,
    this.sku,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    double parsedPrice = 0.0;
    final priceValue = json['price'];
    if (priceValue is num) {
      parsedPrice = priceValue.toDouble();
    } else if (priceValue is String) {
      parsedPrice = double.tryParse(priceValue) ?? 0.0;
    }
    
    String? imageUrl;
    final imageValue = json['image'];
    if (imageValue is String) {
      imageUrl = imageValue;
    } else if (imageValue is List && imageValue.isNotEmpty) {
      imageUrl = imageValue.first as String?; 
    }
    
    final productTitle = json['title'] as String?;
    
    return ProductModel(
      id: json['id'] as String,
      title: productTitle ?? 'Produto ID: ${json['id']}',
      description: json['description'] as String?,
      price: parsedPrice,
      provider: json['provider'] as String,
      image: imageUrl,
      sku: json['sku'] as String?,
    );
  }
}