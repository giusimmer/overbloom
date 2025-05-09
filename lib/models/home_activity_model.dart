import 'package:cloud_firestore/cloud_firestore.dart';

class HomeActivityModel {
  final String id;
  final String title;
  final DateTime hour;
  final int colorValue;
  final bool completed;
  final bool archived;
  final String duration;
  final String frequency;
  final DateTime createdAt;

  HomeActivityModel({
    required this.id,
    required this.title,
    required this.hour,
    required this.colorValue,
    required this.completed,
    required this.archived,
    required this.duration,
    required this.frequency,
    required this.createdAt,
  });

  factory HomeActivityModel.fromFirestore(Map<String, dynamic> data, String id) {
    DateTime createdAt;
    var createdAtRaw = data['createdAt'];

    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is String) {
      createdAt = DateTime.parse(createdAtRaw);
    } else {
      createdAt = DateTime.now();
    }

    DateTime hour;
    var hourRaw = data['hour'];

    if (hourRaw is Timestamp) {
      hour = hourRaw.toDate();
    } else if (hourRaw is String) {
      hour = DateTime.tryParse(hourRaw) ?? DateTime.now();
    } else {
      hour = DateTime.now();
    }

    return HomeActivityModel(
      id: id,
      title: data['title'] ?? 'Sem título',
      hour: hour,
      colorValue: data['color'] ?? 0x9B7591CF,
      completed: data['completed'] ?? false,
      archived: data['archived'] ?? false,
      duration: data['duration'] ?? '30m',
      frequency: data['frequency'] ?? 'Único',
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'hour': Timestamp.fromDate(hour),
      'color': colorValue,
      'completed': completed,
      'archived': archived,
      'duration': duration,
      'frequency': frequency,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  HomeActivityModel copyWith({
    String? id,
    String? title,
    DateTime? hour,
    int? colorValue,
    bool? completed,
    bool? archived,
    String? duration,
    String? frequency,
    DateTime? createdAt,
  }) {
    return HomeActivityModel(
      id: id ?? this.id,
      title: title ?? this.title,
      hour: hour ?? this.hour,
      colorValue: colorValue ?? this.colorValue,
      completed: completed ?? this.completed,
      archived: archived ?? this.archived,
      duration: duration ?? this.duration,
      frequency: frequency ?? this.frequency,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
