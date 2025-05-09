import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/home_activity_model.dart';

class HomeActivityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  HomeActivityRepository({required this.userId});

  CollectionReference<Map<String, dynamic>> get _activitiesRef =>
      _firestore.collection('users').doc(userId).collection('activities');

  Stream<List<HomeActivityModel>> getActivitiesStream() {
    return _activitiesRef.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => HomeActivityModel.fromFirestore(doc.data(), doc.id))
        .toList());
  }

  Future<List<HomeActivityModel>> getTodayActivities() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await _activitiesRef.where('archived', isEqualTo: false).get();

    List<HomeActivityModel> activities = snapshot.docs
        .map((doc) => HomeActivityModel.fromFirestore(doc.data(), doc.id))
        .toList();

    DateTime now = DateTime.now();
    return activities.where((activity) {
      return activity.createdAt.year == now.year &&
          activity.createdAt.month == now.month &&
          activity.createdAt.day == now.day;
    }).toList();
  }

  Future<void> toggleActivityCompletion(
      String activityId, bool isCompleted) async {
    return _activitiesRef.doc(activityId).update({'completed': isCompleted});
  }

  Future<void> deleteActivity(String activityId) async {
    return _activitiesRef.doc(activityId).delete();
  }

  Future<HomeActivityModel?> getActivity(String activityId) async {
    DocumentSnapshot<Map<String, dynamic>> doc =
        await _activitiesRef.doc(activityId).get();
    if (!doc.exists) return null;
    return HomeActivityModel.fromFirestore(doc.data()!, doc.id);
  }

  Future<void> createActivity(HomeActivityModel activity) async {
    return _activitiesRef.doc(activity.id).set(activity.toFirestore());
  }

  Future<void> updateActivity(HomeActivityModel activity) async {
    return _activitiesRef.doc(activity.id).update(activity.toFirestore());
  }

  Future<void> archiveActivity(String activityId) async {
    return _activitiesRef.doc(activityId).update({'archived': true});
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  bool _isSameWeek(DateTime d1, DateTime d2) {
    DateTime monday1 = d1.subtract(Duration(days: d1.weekday - 1));
    DateTime monday2 = d2.subtract(Duration(days: d2.weekday - 1));
    return monday1.year == monday2.year &&
        monday1.month == monday2.month &&
        monday1.day == monday2.day;
  }

  bool _isSameMonth(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month;
  }
}
