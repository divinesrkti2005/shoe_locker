// lib/modules/auth/signup_controller.dart
import 'package:flutter/material.dart';
import 'login_controller.dart'; // to access the mockUserDatabase

class SignupController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  bool validateInputs(BuildContext context) {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      showMessage(context, 'Please fill in all fields');
      return false;
    }

    if (!email.contains('@')) {
      showMessage(context, 'Please enter a valid email');
      return false;
    }

    if (password.length < 6) {
      showMessage(context, 'Password must be at least 6 characters');
      return false;
    }

    if (password != confirmPassword) {
      showMessage(context, 'Passwords do not match');
      return false;
    }

    if (mockUserDatabase.containsKey(email)) {
      showMessage(context, 'Email already registered');
      return false;
    }

    return true;
  }

  void signup(BuildContext context) {
    if (validateInputs(context)) {
      final email = emailController.text.trim();
      final password = passwordController.text;

      // Add to mock "database"
      mockUserDatabase[email] = password;

      showMessage(context, 'Account created successfully');
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
