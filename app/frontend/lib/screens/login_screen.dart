import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/client_provider.dart';
import 'package:frontend/providers/auth_provider.dart'; 

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientAsyncValue = ref.watch(clientProvider);

    return clientAsyncValue.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => const Scaffold(
        body: Center(child: Text("Erro de cliente")),
      ),
      data: (client) {
        final primaryColor = client.primaryColor;

        return Scaffold(
          appBar: AppBar(
            title: Text("Login - ${client.name}"),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LoginForm(
              clientId: client.id, 
              primaryColor: primaryColor,
            ),
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------

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
    if (_formKey.currentState?.validate() ?? false) {
      print('Tentando login com e-mail: ${_emailController.text} e Cliente ID: ${widget.clientId}');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value!.isEmpty ? 'Por favor, insira seu e-mail' : null,
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Senha'),
            obscureText: true,
            validator: (value) => value!.isEmpty ? 'Por favor, insira sua senha' : null,
          ),
          const SizedBox(height: 32.0),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Entrar',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}