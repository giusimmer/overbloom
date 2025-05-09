class UserModel {
  final String uid;
  final String userName;
  final String email;

  UserModel({required this.uid, required this.userName, required this.email});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userName': userName,
      'email': email,
      'numCoins': 0,
      'numStars': 0,
      'currentAvatar': 'assets/images/perfil/defaut.png',
      'purchasedAvatars': ['assets/images/perfil/defaut.png'],
      'currentPet': 'assets/images/pets/defaut_pet.png',
      'purchasedPets': ['assets/images/pets/defaut_pet.png'],
    };
  }
}
