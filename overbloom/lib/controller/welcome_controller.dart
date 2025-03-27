import 'package:flutter/material.dart';
import '../views/Auth/auth_screen.dart';

class WelcomeController {
  void goToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthScreen(isLogin: true),
      ),
    );
  }

  void goToRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthScreen(isLogin: false),
      ),
    );
  }
}
