import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequest {
  final String id;
  final String senderId;
  final String receiverId;
  final String status; // "pending", "accepted", "rejected"
  final DateTime? requestedAt;

  FriendRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    this.requestedAt,
  });

  factory FriendRequest.fromMap(Map<String, dynamic> data, String id) {
    return FriendRequest(
      id: id,
      senderId: data['senderId'],
      receiverId: data['receiverId'],
      status: data['status'],
      requestedAt: (data['requestedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status,
      'requestedAt': requestedAt != null ? Timestamp.fromDate(requestedAt!) : FieldValue.serverTimestamp(),
    };
  }
}
