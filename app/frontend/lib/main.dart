import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/models/client_model.dart';
import 'package:frontend/app/providers/client_provider.dart';
import 'package:frontend/app/screens/login_screen.dart'; 
import 'package:frontend/app/screens/products_screen.dart'; 

import 'package:frontend/app/providers/auth_provider.dart';
import 'package:frontend/app/screens/products_screen.dart';
import 'package:frontend/app/screens/login_screen.dart';

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : 255 - r) * ds).round(),
      g + ((ds < 0 ? g : 255 - g) * ds).round(),
      b + ((ds < 0 ? b : 255 - b) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}


void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientAsyncValue = ref.watch(clientProvider);
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'E-commerce',

      // Enquanto busca o client, mostra loading
      home: clientAsyncValue.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),

        error: (e, st) => Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Erro Fatal de Inicialização:\nAPI não encontrada.\n\n$e',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        ),

        // Quando tiver client → escolhe login ou produtos
        data: (client) {
          return authState.isAuthenticated
              ? const ProductsScreen()
              : LoginScreen();
        },
      ),

      theme: clientAsyncValue.maybeWhen(
        data: (client) => ThemeData(
          primarySwatch: createMaterialColor(client.primaryColor),
          primaryColor: client.primaryColor,
          useMaterial3: true,
        ),
        orElse: () => ThemeData.light(),
      ),

      routes: {
        '/products': (context) => const ProductsScreen(),
      },
    );
  }
}
