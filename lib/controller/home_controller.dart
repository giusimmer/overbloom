import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../views/Welcome/welcome_screen.dart';

class HomeController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    } catch (e) {
      log("Erro ao deslogar: $e");
    }
  }
}
