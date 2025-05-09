import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/friend_model.dart';

class SendMessageController {
  Future<String?> loadUserPet(String userId) async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return userSnapshot.data()?['currentPet'] ?? '';
    } catch (e) {
      log("Erro ao carregar pet: $e");
      return null;
    }
  }

  Future<List<FriendModel>> loadFriends(String userId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('friends')
          .get();

      final friendsData = await Future.wait(querySnapshot.docs.map((doc) async {
        final friendId = doc.id;
        final friendSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(friendId)
            .get();
        final friendData = friendSnapshot.data();
        final String userName = friendData?['userName'] ?? 'Desconhecido';
        return FriendModel(id: friendId, userName: userName, photoUrl: '');
      }));

      return friendsData;
    } catch (e) {
      log("Erro ao carregar amigos: $e");
      return [];
    }
  }

  Future<bool> sendMessage({
    required String senderId,
    required String recipientId,
    required String messageText,
  }) async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(senderId)
          .get();
      final userData = userSnapshot.data();
      if (userData == null) return false;

      final message = {
        "messageText": messageText,
        "senderUser": userData['userName'] ?? '',
        "senderUserAvatar": userData['currentAvatar'] ?? '',
        "senderUserPet": userData['currentPet'] ?? '',
        "recipientUser": recipientId,
        "sendingDate": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(recipientId)
          .collection('messages')
          .add(message);

      return true;
    } catch (e) {
      log('Erro ao enviar mensagem: $e');
      return false;
    }
  }
}