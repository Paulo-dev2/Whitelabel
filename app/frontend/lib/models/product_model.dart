import 'package:flutter/foundation.dart';

@immutable
class ProductModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String provider;
  final String? image;

  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.provider,
    this.image,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(), 
      provider: json['provider'] as String,
      image: json['image'] as String?,
    );
  }
}