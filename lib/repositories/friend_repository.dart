import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:overbloom/models/friend_model.dart';
import '../models/friend_request_model.dart';

class FriendRepository {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference requestsCollection =
      FirebaseFirestore.instance.collection('friendRequests');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<FriendModel>> searchFriends(String query, String currentUserId) async {
    // Recupera a lista de IDs dos amigos do usuário atual
    QuerySnapshot friendsSnapshot = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .get();

    List<String> friendIds = friendsSnapshot.docs.map((doc) => doc.id).toList();

    // Busca usuários cujo nome de usuário contém a consulta e que não estão na lista de amigos
    QuerySnapshot usersSnapshot = await _firestore
        .collection('users')
        .where('userName', isGreaterThanOrEqualTo: query)
        .where('userName', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    List<FriendModel> users = usersSnapshot.docs
        .where((doc) => doc.id != currentUserId && !friendIds.contains(doc.id))
        .map((doc) => FriendModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    return users;
  }

// Envia solicitação de amizade: registra o pedido na coleção "friendRequests"
  Future<void> sendFriendRequest(String senderId, String receiverId) async {
    DocumentReference requestDoc = requestsCollection.doc();
    await requestDoc.set({
      'senderId': senderId,
      'receiverId': receiverId,
      'status': 'pending',
      'requestedAt': FieldValue.serverTimestamp(),
    });
  }

// Obtém stream das solicitações pendentes para o usuário logado
  Stream<List<FriendRequest>> getPendingRequests(String receiverId) {
    return requestsCollection
        .where('receiverId', isEqualTo: receiverId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FriendRequest.fromMap(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

// Aceita uma solicitação de amizade:
// 1. Atualiza o status da solicitação para "accepted"
// 2. Registra os dois usuários como amigos na subcoleção "friends" de cada um
  Future<void> acceptFriendRequest(String requestId, String senderId, String receiverId) async {
    WriteBatch batch = _firestore.batch();

    // Referência à solicitação de amizade original
    DocumentReference requestRef = _firestore.collection('friendRequests').doc(requestId);

    // Consulta por uma solicitação inversa (de receiverId para senderId)
    QuerySnapshot reverseRequestSnapshot = await _firestore
        .collection('friendRequests')
        .where('senderId', isEqualTo: receiverId)
        .where('receiverId', isEqualTo: senderId)
        .get();

    // Referências às coleções de amigos
    DocumentReference senderFriendRef = _firestore
        .collection('users')
        .doc(senderId)
        .collection('friends')
        .doc(receiverId);
    DocumentReference receiverFriendRef = _firestore
        .collection('users')
        .doc(receiverId)
        .collection('friends')
        .doc(senderId);

    // Adiciona ambos como amigos
    batch.set(senderFriendRef, {'friendId': receiverId});
    batch.set(receiverFriendRef, {'friendId': senderId});

    // Remove a solicitação original
    batch.delete(requestRef);

    // Remove a solicitação inversa, se existir
    if (reverseRequestSnapshot.docs.isNotEmpty) {
      batch.delete(reverseRequestSnapshot.docs.first.reference);
    }

    await batch.commit();
  }

  Future<void> rejectRequest(String requestId, String senderId, String receiverId) async {
    WriteBatch batch = _firestore.batch();

    // Referência à solicitação de amizade original
    DocumentReference requestRef = _firestore.collection('friendRequests').doc(requestId);

    // Consulta por uma solicitação inversa (de receiverId para senderId)
    QuerySnapshot reverseRequestSnapshot = await _firestore
        .collection('friendRequests')
        .where('senderId', isEqualTo: receiverId)
        .where('receiverId', isEqualTo: senderId)
        .get();

    // Remove a solicitação original
    batch.delete(requestRef);

    // Remove a solicitação inversa, se existir
    if (reverseRequestSnapshot.docs.isNotEmpty) {
      batch.delete(reverseRequestSnapshot.docs.first.reference);
    }

    await batch.commit();
  }

}
