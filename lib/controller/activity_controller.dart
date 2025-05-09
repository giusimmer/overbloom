import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/activity_model.dart';
import '../service/firebase_service.dart';

class ActivityController {
  final FirebaseService _firebaseService = FirebaseService();

  final List<Color> colorOptions = [
    Color(0xFF9563BD),
    Color(0xFF6080AF),
    Color(0xFF84AB66),
    Color(0xFFDC6666),
    Color(0xFFD9C143),
  ];

  final List<String> durationOptions = ["30m", "1h", "2h", "3h", "4h"];
  final List<String> frequencyOptions = [
    "Único",
    "Diário",
    "Semanal",
    "Mensal"
  ];

  Color selectedColor = Color(0xFF9563BD);
  int selectedHour = TimeOfDay.now().hour;
  int selectedMinute = 0;
  int selectedDurationIndex = 0;
  int selectedFrequencyIndex = 0;

  void setSelectedColor(Color color) {
    selectedColor = color;
  }

  void setSelectedHour(int hour) {
    selectedHour = hour;
  }

  void setSelectedMinute(int minute) {
    selectedMinute = minute;
  }

  void setSelectedDurationIndex(int index) {
    selectedDurationIndex = index;
  }

  void setSelectedFrequencyIndex(int index) {
    selectedFrequencyIndex = index;
  }

  Duration parseDuration(String durationStr) {
    switch (durationStr) {
      case "30m":
        return Duration(minutes: 30);
      case "1h":
        return Duration(hours: 1);
      case "2h":
        return Duration(hours: 2);
      case "3h":
        return Duration(hours: 3);
      case "4h":
        return Duration(hours: 4);
      default:
        return Duration(minutes: 30);
    }
  }

  Future<bool> addActivity(String title) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || title.isEmpty) return false;

    DateTime now = DateTime.now();
    DateTime start = DateTime(
      now.year,
      now.month,
      now.day,
      selectedHour,
      selectedMinute,
    );

    String selectedDuration = durationOptions[selectedDurationIndex];
    Duration duration = parseDuration(selectedDuration);
    DateTime end = start.add(duration);

    List<ActivityModel> existingActivities =
    await _firebaseService.getUserActivities(userId);

    for (var activity in existingActivities) {
      DateTime existingStart = activity.hour;
      Duration existingDuration = parseDuration(activity.duration);
      DateTime existingEnd = existingStart.add(existingDuration);

      if (start.isBefore(existingEnd) && end.isAfter(existingStart)) {
        debugPrint("Conflito detectado com a atividade: ${activity.title}");
        return false;
      }
    }

    ActivityModel newActivity = ActivityModel(
      title: title,
      colorValue: selectedColor.value,
      hour: start,
      duration: selectedDuration,
      frequency: frequencyOptions[selectedFrequencyIndex],
    );

    try {
      await _firebaseService.addActivity(userId, newActivity.toMap());
      return true;
    } catch (e) {
      debugPrint("Erro ao adicionar atividade: $e");
      return false;
    }
  }
}
