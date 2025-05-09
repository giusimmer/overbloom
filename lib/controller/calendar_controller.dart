import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CalendarController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  Map<DateTime, Color> dayColors = {};
  List<DateTime> months = [];

  CalendarController({required this.userId});

  void generateMonths() {
    DateTime now = DateTime.now();
    months = List.generate(12, (i) => DateTime(now.year, now.month - i, 1));
  }

  Future<void> loadActivities(VoidCallback onDataLoaded) async {
    final userActivitiesRef =
    _firestore.collection('users').doc(userId).collection('activities');

    DateTime now = DateTime.now();
    DateTime firstDayOfYear = DateTime(now.year, 1, 1);
    DateTime lastDayOfYear = DateTime(now.year, 12, 31);

    QuerySnapshot activitiesSnapshot = await userActivitiesRef
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfYear))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(lastDayOfYear))
        .get();

    Map<DateTime, List<bool>> dailyCompletion = {};

    for (var doc in activitiesSnapshot.docs) {
      Timestamp createdAt = doc['createdAt'];
      bool completed = doc['completed'] ?? false;
      DateTime day = DateTime(createdAt.toDate().year, createdAt.toDate().month, createdAt.toDate().day);

      dailyCompletion.putIfAbsent(day, () => []).add(completed);
    }

    dayColors = {};
    dailyCompletion.forEach((day, completions) {
      if (completions.every((c) => c)) {
        dayColors[day] = Colors.green;
      } else if (completions.any((c) => c)) {
        dayColors[day] = Colors.yellow;
      } else {
        dayColors[day] = Colors.red;
      }
    });

    onDataLoaded();
  }

  Future<List<Map<String, dynamic>>> getActivitiesForDay(DateTime selectedDate) async {
    final activitiesRef = _firestore.collection('users').doc(userId).collection('activities');

    final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await activitiesRef
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['hour'] = (data['hour'] as Timestamp).toDate();
      return data;
    }).toList();
  }
}
