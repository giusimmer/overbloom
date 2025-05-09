class FriendModel {
  final String id;
  final String userName;
  final String photoUrl;

  FriendModel({
    required this.id,
    required this.userName,
    required this.photoUrl,
  });

  factory FriendModel.fromMap(Map<String, dynamic> data, String id) {
    return FriendModel(
      id: id,
      userName: data['userName'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
    );
  }
}
