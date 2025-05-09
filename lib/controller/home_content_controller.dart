import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:overbloom/models/home_user_model.dart';
import '../models/home_activity_model.dart';
import '../repositories/home_activity_repository.dart';
import '../repositories/home_user_repository.dart';

class HomeContentController {
  final HomeUserRepository homeUserRepository;
  final HomeActivityRepository homeActivityRepository;

  HomeContentController({
    required this.homeUserRepository,
    required this.homeActivityRepository,
  });

  Stream<HomeUserModel> getUserStream() {
    return homeUserRepository.getUserStream();
  }

  Future<HomeUserModel> getUserInfo() async {
    return await homeUserRepository.getUserInfo();
  }

  Stream<List<HomeActivityModel>> getActivitiesStream() {
    return homeActivityRepository.getActivitiesStream();
  }

  Future<List<HomeActivityModel>> getTodayActivities() async {
    List<HomeActivityModel> allActivities =
        await homeActivityRepository.getTodayActivities();
    allActivities.sort((a, b) => a.hour.compareTo(b.hour));
    return allActivities;
  }

  Future<void> toggleActivityCompletion(
      HomeActivityModel activity, bool isCompleted) async {
    await homeActivityRepository.toggleActivityCompletion(
        activity.id, isCompleted);

    // Update user coins
    final coinChange = isCompleted ? 1 : -1;
    await homeUserRepository.updateCoins(coinChange);
  }

  Duration parseDuration(String durationStr) {
    if (durationStr.endsWith('m')) {
      final minutes = int.tryParse(durationStr.replaceAll('m', '')) ?? 0;
      return Duration(minutes: minutes);
    } else if (durationStr.endsWith('h')) {
      final hours = int.tryParse(durationStr.replaceAll('h', '')) ?? 0;
      return Duration(hours: hours);
    } else {
      return Duration.zero;
    }
  }

  bool isActivityExpired(HomeActivityModel activity) {
    final now = DateTime.now();
    final endTime = activity.hour.add(parseDuration(activity.duration)); // '30m', '1h' etc.
    return now.isAfter(endTime);
  }


  Future<void> deleteActivity(String activityId) async {
    final activity = await homeActivityRepository.getActivity(activityId);

    if (activity != null && activity.completed) {
      await homeUserRepository.updateCoins(-1);
    }

    await homeActivityRepository.deleteActivity(activityId);
  }

  Future<void> checkAndCreateRecurringActivities() async {
    final now = DateTime.now();

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(homeUserRepository.currentUserId)
        .collection('activities')
        .where('archived', isEqualTo: false)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final frequency = data['frequency'] ?? 'Único';
      final lastCreatedAt = (data['createdAt'] as Timestamp).toDate();
      final completed = data['completed'] ?? false;

      bool shouldCreate = false;

      if (completed) continue;

      if (frequency == 'Diário') {
        if (!_isSameDay(lastCreatedAt, now)) {
          shouldCreate = true;
        }
      } else if (frequency == 'Semanal') {
        if (!_isSameWeek(lastCreatedAt, now)) {
          shouldCreate = true;
        }
      } else if (frequency == 'Mensal') {
        if (!_isSameMonth(lastCreatedAt, now)) {
          shouldCreate = true;
        }
      }

      if (shouldCreate) {
        final activityModel = HomeActivityModel.fromFirestore(data, doc.id);

        // Create new activity
        final newActivityModel = activityModel.copyWith(
          id: FirebaseFirestore.instance
              .collection('users')
              .doc(homeUserRepository.currentUserId)
              .collection('activities')
              .doc()
              .id,
          completed: false,
          archived: false,
          createdAt: DateTime.now(),
        );

        await homeActivityRepository.createActivity(newActivityModel);

        // Archive old activity
        await homeActivityRepository.archiveActivity(doc.id);
      }
    }
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
