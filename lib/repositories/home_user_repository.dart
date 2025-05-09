import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/home_user_model.dart';

class HomeUserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<HomeUserModel> getUserStream() {
    if (currentUserId == null) {
      throw Exception("No authenticated user found");
    }

    return _firestore.collection('users').doc(currentUserId).snapshots().map(
          (snapshot) => HomeUserModel.fromFirestore(
        snapshot.data() ?? {},
        currentUserId!,
      ),
    );
  }

  Future<HomeUserModel> getUserInfo() async {
    if (currentUserId == null) {
      throw Exception("No authenticated user found");
    }

    DocumentSnapshot doc = await _firestore.collection('users').doc(currentUserId).get();
    return HomeUserModel.fromFirestore(doc.data() as Map<String, dynamic>, currentUserId!);
  }

  Future<void> updateCoins(int amount) async {
    if (currentUserId == null) {
      throw Exception("No authenticated user found");
    }

    final userRef = _firestore.collection('users').doc(currentUserId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final currentCoins = snapshot.get('numCoins') ?? 0;
      final newCoins = (currentCoins + amount) < 0 ? 0 : currentCoins + amount;

      transaction.update(userRef, {'numCoins': newCoins});

      // Also update ranking
      final rankingRef = _firestore.collection('usersRanking').doc(currentUserId);
      final userData = snapshot.data() ?? {};
      transaction.set(rankingRef, {
        'userName': userData['userName'] ?? 'Sem nome',
        'avatarUser': userData['currentAvatar'] ?? 'assets/images/perfil/defaut.png',
        'numCoins': newCoins,
        'numStars': userData['numStars'] ?? 0,
      });
    });
  }
}