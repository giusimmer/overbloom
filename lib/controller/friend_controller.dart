import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:overbloom/models/friend_model.dart';
import '../models/friend_request_model.dart';
import '../repositories/friend_repository.dart';

class FriendController {
  final FriendRepository repository;

  List<FriendModel> friends = [];

  FriendController({required this.repository});

  Future<List<FriendModel>> searchFriends(String query, String currentUserId) async {
    if (query.isEmpty) {
      friends = [];
      return friends;
    }
    friends = await repository.searchFriends(query, currentUserId);
    return friends;
  }

  // Envia solicitação de amizade
  Future<void> sendRequest(String senderId, String receiverId) async {
    await repository.sendFriendRequest(senderId, receiverId);
  }

  // Retorna stream de solicitações pendentes para o usuário atual
  Stream<List<FriendRequest>> getPendingRequests(String receiverId) {
    return repository.getPendingRequests(receiverId);
  }

  Stream<List<FriendModel>> getFriends(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('friends')
        .snapshots()
        .asyncMap((snapshot) async {
      List<FriendModel> friends = [];
      for (var doc in snapshot.docs) {
        String friendId = doc.id;
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(friendId)
            .get();
        if (userDoc.exists) {
          var data = userDoc.data()!;
          friends.add(FriendModel(
            id: friendId,
            userName: data['userName'] ?? 'Nome não disponível',
            photoUrl: data['photoUrl'] ?? '',
          ));
        }
      }
      return friends;
    });
  }

  // Aceita a solicitação de amizade
  Future<void> acceptRequest(String requestId, String senderId, String receiverId) async {
    await repository.acceptFriendRequest(requestId, senderId, receiverId);
  }

  Future<void> rejectRequest(String requestId, String senderId, String receiverId) async {
    await repository.rejectRequest(requestId, senderId, receiverId);
  }
}
