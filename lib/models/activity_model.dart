import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel {
  String id;
  String title;
  int colorValue;
  DateTime hour;
  String duration;
  String frequency;
  bool completed;
  bool archived;
  DateTime createdAt;

  ActivityModel({
    this.id = '',
    required this.title,
    required this.colorValue,
    required this.hour,
    required this.duration,
    required this.frequency,
    this.completed = false,
    this.archived = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'color': colorValue,
      'hour': hour,
      'duration': duration,
      'frequency': frequency,
      'completed': completed,
      'archived': archived,
      'createdAt': createdAt,
    };
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map, String id) {
    return ActivityModel(
      id: id,
      title: map['title'] ?? '',
      colorValue: map['color'] ?? 0xFF9563BD,
      hour: parseDate(map['hour']),
      duration: map['duration'] ?? '1m',
      frequency: map['frequency'] ?? 'Único',
      completed: map['completed'] ?? false,
      archived: map['archived'] ?? false,
      createdAt: map['createdAt'] != null
          ? parseDate(map['createdAt'])
          : DateTime.now(),
    );
  }
}

DateTime parseDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is DateTime) return value;
  throw Exception("Data em formato inválido: $value");
}
