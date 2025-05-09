import 'package:cloud_firestore/cloud_firestore.dart';

class StoreModel {
  String image;
  int price;
  String currencyIcon;
  bool purchased;
  bool selected;

  StoreModel({
    required this.image,
    required this.price,
    required this.currencyIcon,
    this.purchased = false,
    this.selected = false,
  });

  factory StoreModel.fromMap(Map<String, dynamic> map) {
    return StoreModel(
      image: map['image'],
      price: map['price'],
      currencyIcon: map['currencyIcon'],
      purchased: map['purchased'] ?? false,
      selected: map['selected'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'price': price,
      'currencyIcon': currencyIcon,
      'purchased': purchased,
      'selected': selected,
    };
  }
}

class UserModel {
  String currentAvatar;
  String currentPet;
  List<String> purchasedAvatars;
  List<String> purchasedPets;
  int numCoins;
  int numStars;
  DateTime? lastStarRewardDate;

  UserModel({
    this.currentAvatar = '',
    this.currentPet = '',
    this.purchasedAvatars = const [],
    this.purchasedPets = const [],
    this.numCoins = 0,
    this.numStars = 0,
    this.lastStarRewardDate,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      currentAvatar: data['currentAvatar'] ?? '',
      currentPet: data['currentPet'] ?? '',
      purchasedAvatars: List<String>.from(data['purchasedAvatars'] ?? []),
      purchasedPets: List<String>.from(data['purchasedPets'] ?? []),
      numCoins: data['numCoins'] ?? 0,
      numStars: data['numStars'] ?? 0,
      lastStarRewardDate: data['lastStarRewardDate'] != null
          ? (data['lastStarRewardDate'] as Timestamp).toDate()
          : null,
    );
  }
}
