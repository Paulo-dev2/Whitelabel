import 'package:flutter/material.dart';
import 'package:frontend/app/models/client_model.dart';
import 'package:frontend/app/widgets/login_form.dart';

class LoginCardView extends StatelessWidget {
  final ClientModel client;

  const LoginCardView({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    final primaryColor = client.primaryColor;

    return Card(
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
    );
  }
}