import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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

  Stream<List<Map<String, dynamic>>> getUserActivitiesStream(String userId) {
    return _firestore
        .collection('users') // Acessa a coleção "users"
        .doc(userId) // Documento do usuário específico
        .collection('activities') // Acessa a subcoleção "activities"
        .snapshots() // Usamos snapshots para escutar em tempo real
        .map((activitiesSnapshot) {
      try {
        List<Map<String, dynamic>> activities = [];

        for (var activityDoc in activitiesSnapshot.docs) {
          Map<String, dynamic> data = activityDoc.data();
          data['id'] = activityDoc.id;
          activities.add(data);
        }

        print('Atividades encontradas: ${activities.length}');
        return activities;
      } catch (e) {
        print("Erro ao buscar atividades: $e");
        return [];
      }
    });
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
