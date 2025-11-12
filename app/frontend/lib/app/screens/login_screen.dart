import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/providers/client_provider.dart';
import 'package:frontend/app/providers/auth_provider.dart';
import 'package:frontend/app/screens/products_screen.dart'; 
import 'package:frontend/app/widgets/login_card_view.dart'; 

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ProductsScreen()),
        );
      }
    });

    final clientAsyncValue = ref.watch(clientProvider);

    return clientAsyncValue.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => const Scaffold(body: Center(child: Text("Erro de cliente"))),
      
      data: (client) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Login - ${client.name}"),
            centerTitle: true,
            elevation: 0,
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: LoginCardView(client: client), 
              ),
            ),
          ),
        );
      },
    );
  }
}