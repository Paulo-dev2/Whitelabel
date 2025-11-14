import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/app/providers/auth_provider.dart';

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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Campo Email
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira seu e-mail.';
              }
              final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
              if (!emailRegex.hasMatch(value)) {
                return 'Formato de e-mail inválido.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          // Campo Senha
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
          // Botão de Login
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