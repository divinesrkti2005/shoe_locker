// lib/modules/auth/login_controller.dart
import 'package:flutter/material.dart';

// Simulating a registered user database (for demonstration only)
final Map<String, String> mockUserDatabase = {
  'test@example.com': 'password123',
};

class LoginController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }

  bool validateInputs(BuildContext context) {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showMessage(context, 'Please fill in all fields');
      return false;
    }

    return true;
  }

  void login(BuildContext context) {
    if (validateInputs(context)) {
      final email = emailController.text.trim();
      final password = passwordController.text;

      if (mockUserDatabase.containsKey(email) &&
          mockUserDatabase[email] == password) {
        Navigator.pushNamed(context, '/dashboard');
      } else {
        showMessage(context, 'Invalid email or password');
      }
    }
  }

  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
