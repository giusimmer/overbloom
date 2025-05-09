import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/store_model.dart';

class StoreController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  List<StoreModel> products = [];
  UserModel? user;

  List<StoreModel> loadLocalProducts(String type) {
    List<StoreModel> items = [];

    if (type == 'avatar') {
      items = [
        StoreModel(
          image: 'assets/images/perfil/defaut.png',
          price: 10,
          currencyIcon: 'assets/images/icon/moeda.png',
        ),
        StoreModel(
          image: 'assets/images/perfil/menina.png',
          price: 20,
          currencyIcon: 'assets/images/icon/moeda.png',
        ),
        StoreModel(
          image: 'assets/images/perfil/cowboy.png',
          price: 25,
          currencyIcon: 'assets/images/icon/moeda.png',
        ),
        StoreModel(
          image: 'assets/images/perfil/bigode.png',
          price: 30,
          currencyIcon: 'assets/images/icon/moeda.png',
        ),
        StoreModel(
          image: 'assets/images/perfil/green.png',
          price: 70,
          currencyIcon: 'assets/images/icon/moeda.png',
        ),
        StoreModel(
          image: 'assets/images/perfil/elfa.png',
          price: 80,
          currencyIcon: 'assets/images/icon/moeda.png',
        ),
        StoreModel(
          image: 'assets/images/perfil/farmes.png',
          price: 85,
          currencyIcon: 'assets/images/icon/moeda.png',
        ),
        StoreModel(
          image: 'assets/images/perfil/bone.png',
          price: 95,
          currencyIcon: 'assets/images/icon/moeda.png',
        ),
        StoreModel(
          image: 'assets/images/perfil/bruxa.png',
          price: 115,
          currencyIcon: 'assets/images/icon/moeda.png',
        ),
        StoreModel(
          image: 'assets/images/perfil/giulia.png',
          price: 150,
          currencyIcon: 'assets/images/icon/moeda.png',
        ),
        StoreModel(
          image: 'assets/images/perfil/emanuel.png',
          price: 302,
          currencyIcon: 'assets/images/icon/moeda.png',
        ),
      ];
    } else if (type == 'pet') {
      items = [
        StoreModel(
          image: 'assets/images/pets/defaut_pet.png',
          price: 0,
          currencyIcon: 'assets/images/icon/estrela.png',
        ),
        StoreModel(
          image: 'assets/images/pets/azul.png',
          price: 5,
          currencyIcon: 'assets/images/icon/estrela.png',
        ),
        StoreModel(
          image: 'assets/images/pets/amarelo.png',
          price: 7,
          currencyIcon: 'assets/images/icon/estrela.png',
        ),
        StoreModel(
          image: 'assets/images/pets/espada.png',
          price: 13,
          currencyIcon: 'assets/images/icon/estrela.png',
        ),
        StoreModel(
          image: 'assets/images/pets/borboleta.png',
          price: 17,
          currencyIcon: 'assets/images/icon/estrela.png',
        ),
        StoreModel(
          image: 'assets/images/pets/oculos.png',
          price: 20,
          currencyIcon: 'assets/images/icon/estrela.png',
        ),
        StoreModel(
          image: 'assets/images/pets/cafezin.png',
          price: 27,
          currencyIcon: 'assets/images/icon/estrela.png',
        ),
        StoreModel(
          image: 'assets/images/pets/coracao.png',
          price: 30,
          currencyIcon: 'assets/images/icon/estrela.png',
        ),
        StoreModel(
          image: 'assets/images/pets/asas.png',
          price: 37,
          currencyIcon: 'assets/images/icon/estrela.png',
        ),
      ];
    }
    return items;
  }

  Future<UserModel> loadUserInfoFromFirebase() async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc.data()!);
      }
      return UserModel();
    } catch (e) {
      print("Error loading user data: $e");
      return UserModel();
    }
  }

  List<StoreModel> updateProductsStatus(
      List<StoreModel> products, UserModel user, String type) {
    String currentItem =
        type == 'avatar' ? user.currentAvatar : user.currentPet;
    List<String> purchasedItems =
        type == 'avatar' ? user.purchasedAvatars : user.purchasedPets;

    for (var product in products) {
      product.purchased = purchasedItems.contains(product.image);
      product.selected = product.image == currentItem;
    }

    return products;
  }

  Future<void> selectProduct(StoreModel product, UserModel user, String type,
      Function(UserModel) onUpdate, Function(String) showMessage) async {
    if (product.purchased) {
      await _selectExistingProduct(product, type, onUpdate);
    } else {
      await _purchaseNewProduct(product, user, type, onUpdate, showMessage);
    }
  }

  Future<void> _selectExistingProduct(
      StoreModel product, String type, Function(UserModel) onUpdate) async {
    try {
      final fieldToUpdate = type == 'avatar' ? 'currentAvatar' : 'currentPet';
      await _firestore.collection('users').doc(userId).update({
        fieldToUpdate: product.image,
      });

      await _updateRanking();

      final updatedUser = await loadUserInfoFromFirebase();
      onUpdate(updatedUser);
    } catch (e) {
      print("Error updating selection: $e");
    }
  }

  Future<void> _purchaseNewProduct(
      StoreModel product,
      UserModel user,
      String type,
      Function(UserModel) onUpdate,
      Function(String) showMessage) async {
    int currentBalance = type == 'avatar' ? user.numCoins : user.numStars;

    if (currentBalance < product.price) {
      showMessage("Você não tem saldo suficiente!");
      return;
    }

    int newBalance = currentBalance - product.price;

    try {
      final fieldToUpdate = type == 'avatar' ? 'currentAvatar' : 'currentPet';
      final balanceField = type == 'avatar' ? 'numCoins' : 'numStars';
      final purchasedField =
          type == 'avatar' ? 'purchasedAvatars' : 'purchasedPets';

      await _firestore.collection('users').doc(userId).update({
        balanceField: newBalance,
        fieldToUpdate: product.image,
        purchasedField: FieldValue.arrayUnion([product.image]),
      });

      await _updateRanking();

      final updatedUser = await loadUserInfoFromFirebase();
      onUpdate(updatedUser);
    } catch (e) {
      print('Error finalizing purchase: $e');
    }
  }

  Future<void> _updateRanking() async {
    final userRef = _firestore.collection('users').doc(userId);

    try {
      final snapshot = await userRef.get();
      if (!snapshot.exists) return;

      final userData = snapshot.data()!;
      final avatarAtual = userData['currentAvatar'] ?? '';
      final numMoedasAtual = userData['numCoins'] ?? 0;
      final numEstrelasAtual = userData['numStars'] ?? 0;

      final rankingRef = _firestore.collection('usersRanking').doc(userId);

      await rankingRef.update({
        'avatarUser': avatarAtual,
        'numCoins': numMoedasAtual,
        'numStars': numEstrelasAtual,
      });
    } catch (e) {
      print('Error updating ranking: $e');
    }
  }

  Future<void> checkAndRewardUser(Function showRewardMessage) async {
    DateTime now = DateTime.now();

    if (now.weekday != DateTime.monday) {
      return;
    }

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      Timestamp? lastRewardTimestamp = userData['lastStarRewardDate'];
      if (lastRewardTimestamp != null) {
        DateTime lastRewardDate = lastRewardTimestamp.toDate();
        if (lastRewardDate.year == now.year &&
            lastRewardDate.month == now.month &&
            lastRewardDate.day == now.day) {
          print('Usuário já foi premiado hoje.');
          return;
        }
      }

      DateTime lastMonday = now.subtract(Duration(days: now.weekday + 6));
      DateTime lastSunday = lastMonday.add(const Duration(days: 6));

      final userActivitiesRef =
          _firestore.collection('users').doc(userId).collection('activities');

      QuerySnapshot activitiesSnapshot = await userActivitiesRef
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(lastMonday))
          .where('createdAt',
              isLessThanOrEqualTo: Timestamp.fromDate(lastSunday))
          .get();

      List<DocumentSnapshot> activities = activitiesSnapshot.docs;

      bool allCompleted = activities.isNotEmpty &&
          activities.every((activity) => activity['completed'] == true);

      if (allCompleted) {
        await _addStar();
        await _firestore.collection('users').doc(userId).update({
          'lastStarRewardDate': Timestamp.fromDate(now),
        });
        showRewardMessage();
      }
    } catch (e) {
      print('Error checking activities: $e');
    }
  }

  Future<void> _addStar() async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'numStars': FieldValue.increment(1),
      });
      print('User rewarded with a star!');
      await _updateRanking();
    } catch (e) {
      print('Error adding star: $e');
    }
  }
}
