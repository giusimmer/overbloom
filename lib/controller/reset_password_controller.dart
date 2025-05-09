import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPasswordController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _timer;
  int _secondsRemaining = 0;

  /// Método para iniciar a recuperação de senha
  Future<void> resetPassword({
    required BuildContext context,
    required TextEditingController emailController,
    required Function(String) updateMessage,
    required Function(bool, int) updateButtonState,
  }) async {
    String email = emailController.text.trim();

    if (email.isEmpty) {
      updateMessage("Por favor, insira um e-mail.");
      return;
    }

    bool emailExists = await _checkIfEmailExists(email);
    if (!emailExists) {
      updateMessage("Este e-mail não está cadastrado.");
      return;
    }

    updateMessage(""); // Limpa mensagens anteriores
    _secondsRemaining = 180; // 3 minutos
    updateButtonState(true, _secondsRemaining);

    _startTimer(updateButtonState);

    try {
      await _auth.sendPasswordResetEmail(email: email);
      updateMessage(
          "E-mail de recuperação enviado! Verifique sua caixa de entrada.");
    } on FirebaseAuthException catch (e) {
      updateMessage(e.message ?? "Erro ao enviar e-mail.");
      _stopTimer(updateButtonState);
    }
  }

  bool _isValidEmail(String email) {
    String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(emailPattern);
    return regex.hasMatch(email);
  }

  Future<bool> _checkIfEmailExists(String email) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Erro ao verificar e-mail: $e");
      return false;
    }
  }

  /// Método para iniciar o contador regressivo
  void _startTimer(Function(bool, int) updateButtonState) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        updateButtonState(true, _secondsRemaining);
      } else {
        _stopTimer(updateButtonState);
      }
    });
  }

  /// Método para parar o timer e reabilitar o botão
  void _stopTimer(Function(bool, int) updateButtonState) {
    updateButtonState(false, 0);
    _timer?.cancel();
  }

  /// Método para limpar o timer ao sair da tela
  void dispose() {
    _timer?.cancel();
  }
}
