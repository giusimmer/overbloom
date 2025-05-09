class HomeUserModel {
  final String id;
  final String avatarPath;
  final int coins;
  final int stars;
  final String userName;

  HomeUserModel({
    required this.id,
    this.avatarPath = 'assets/images/perfil/defaut.png',
    this.coins = 0,
    this.stars = 0,
    this.userName = 'Sem nome',
  });

  factory HomeUserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return HomeUserModel(
      id: uid,
      avatarPath: data['currentAvatar'] ?? 'assets/images/perfil/defaut.png',
      coins: data['numCoins'] ?? 0,
      stars: data['numStars'] ?? 0,
      userName: data['userName'] ?? 'Sem nome',
    );
  }

  Map<String, dynamic> toRanking() {
    return {
      'userName': userName,
      'avatarUser': avatarPath,
      'numCoins': coins,
      'numStars': stars,
    };
  }
}