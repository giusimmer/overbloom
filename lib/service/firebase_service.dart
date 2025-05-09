import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../models/activity_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  Future<void> addActivity(String userId, Map<String, dynamic> activity) async {
    try {
      if (activity['time'] is DateTime) {
        activity['time'] = formatTime(activity['time']);
      }

      await _firestore
          .collection('users') // Vai na coleção "users"
          .doc(userId) // Acessa o documento do usuário específico
          .collection('activities') // Acessa a subcoleção "activities"
          .add(activity); // Adiciona a atividade
    } catch (e) {
      print("Erro ao adicionar atividade: $e");
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserDocStream(String userId) {
    return FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
  }

  Stream<List<Map<String, dynamic>>> getUserActivitiesStream(String userId) {
    return _firestore
        .collection('users') // Acessa a coleção "users"
        .doc(userId) // Documento do usuário específico
        .snapshots() // Usamos snapshots para escutar em tempo real
        .asyncMap((userSnapshot) async {
      try {
        // Obter dados do usuário, como avatar e moedas
        var userData = userSnapshot.data();
        String avatarPath = userData?['avatar'] ??
            'assets/images/perfil/defaut.png'; // Caminho do avatar
        int moedas = userData?['numCoins'] ?? 0; // Moedas do usuário

        // Buscar as atividades do usuário
        var activitiesSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('activities')
            .get();

        List<Map<String, dynamic>> activities = [];
        for (var activityDoc in activitiesSnapshot.docs) {
          Map<String, dynamic> data = activityDoc.data();
          data['id'] = activityDoc.id;
          // Adiciona o avatar e o número de moedas às atividades
          data['avatar'] = avatarPath;
          data['numCoins'] = moedas;
          activities.add(data);
        }

        print('Atividades encontradas: ${activities.length}');
        return activities;
      } catch (e) {
        print("Erro ao buscar atividades ou dados do usuário: $e");
        return [];
      }
    });
  }

  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(userId).get();
      return snapshot.data() as Map<String, dynamic>?;
    } catch (e) {
      print("Erro ao pegar informações do usuário: $e");
      return null;
    }
  }

  Future<List<ActivityModel>> getUserActivities(String userId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('activities')
        .get();

    return snapshot.docs.map((doc) {
      return ActivityModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }


  Future<void> updateActivityStatus(String userId, String activityId, bool status) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('activities')
        .doc(activityId)
        .update({'completed': status});
  }

  Future<bool> hasConflict(String userId, DateTime newStartTime) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('activities')
        .where('hour', isEqualTo: newStartTime)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> deleteActivity(String userId, String activityId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('activities')
          .doc(activityId)
          .delete();
    } catch (e) {
      log("Erro ao excluir a atividade: $e");
    }
  }
}
