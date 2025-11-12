import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/client_provider.dart';
import 'package:frontend/providers/auth_provider.dart';

// Tela que será o destino após o login
import 'package:frontend/screens/products_screen.dart'; 

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Redirecionamento (Se já estiver logado, vá para a Home)
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        // Navega para a tela de Produtos
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
        final primaryColor = client.primaryColor;

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
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Acesso à Loja ${client.name}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        LoginForm(
                          clientId: client.id,
                          primaryColor: primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class LoginForm extends ConsumerStatefulWidget {
  final int clientId;
  final Color primaryColor;

  const LoginForm({
    super.key,
    required this.clientId,
    required this.primaryColor,
  });

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin.alpha@teste.com');
  final _passwordController = TextEditingController(text: '123456');

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      final notifier = ref.read(authProvider.notifier);

      await notifier.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        clientId: widget.clientId,
      );
      
      if (notifier.state.errorMessage != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(notifier.state.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: widget.primaryColor, width: 2),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value!.isEmpty ? 'Por favor, insira seu e-mail' : null,
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Senha',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: widget.primaryColor, width: 2),
              ),
            ),
            obscureText: true,
            validator: (value) => value!.isEmpty ? 'Por favor, insira sua senha' : null,
          ),
          const SizedBox(height: 32.0),
          ElevatedButton(
            onPressed: authState.isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: authState.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'Entrar',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }
}