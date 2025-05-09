import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> isUsernameTaken(String userName) async {
    final result = await _firestore
        .collection('users')
        .where('userName', isEqualTo: userName)
        .get();
    return result.docs.isNotEmpty;
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _translateFirebaseError(e.code);
    }
  }

  Future<String?> signUp(String userName, String email, String password) async {
    try {
      bool userNameExists = await isUsernameTaken(userName);
      if (userNameExists) return "Esse nome de usuário já está em uso!";

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      UserModel newUser = UserModel(
          uid: userCredential.user!.uid, userName: userName, email: email);

      await _firestore
          .collection('users')
          .doc(newUser.uid)
          .set(newUser.toMap());

      return null;
    } on FirebaseAuthException catch (e) {
      return _translateFirebaseError(e.code);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      log("Usuário deslogado com sucesso.");
    } catch (e) {
      log("Erro ao deslogar usuário: $e");
    }
  }

  String _translateFirebaseError(String errorCode) {
    log("Código de erro Firebase: $errorCode");
    switch (errorCode) {
      case 'invalid-email':
        return "O e-mail informado é inválido.";
      case 'user-disabled':
        return "Essa conta foi desativada.";
      case 'user-not-found':
        return "Usuário não encontrado.";
      case 'wrong-password':
        return "Senha incorreta. Tente novamente.";
      case 'email-already-in-use':
        return "Este e-mail já está cadastrado.";
      case 'weak-password':
        return "A senha é muito fraca. Escolha uma mais segura.";
      case 'invalid-credential':
        return "Credenciais inválidas. Verifique seu e-mail e senha.";
      default:
        return "Erro inesperado: $errorCode";
    }
  }
}
