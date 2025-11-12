import 'package:flutter/material.dart';

class ClientModel {
  final int id;
  final String name;
  final String hostUrl;
  final Map<String, dynamic> themeConfig;
  
  ClientModel({
    required this.id,
    required this.name,
    required this.hostUrl,
    required this.themeConfig,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as int,
      name: json['name'] as String,
      hostUrl: json['hostUrl'] as String,
      themeConfig: json['themeConfig'] as Map<String, dynamic>,
    );
  }

  Color get primaryColor {
    final hexCode = themeConfig['primaryColor'] as String;
    return Color(int.parse(hexCode.replaceFirst('#', '0xFF')));
  }
}