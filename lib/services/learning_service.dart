import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class LearningService {
  static CollectionReference<Map<String, dynamic>> learningRef(String uid) =>
      FirebaseService.userDoc(uid).collection('learning');

  static DocumentReference<Map<String, dynamic>> progressDoc(String uid) =>
      learningRef(uid).doc('progress');

  static Future<void> initializeProgress(String uid) async {
    final doc = progressDoc(uid);
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      await doc.set({
        'totalPoints': 0,
        'currentStreak': 0,
        'totalStreakDays': 0,
        'lastCompletedDate': null,
        'lastStreakDate': null,
        'completedLessons': <String>[],
        'badges': <String>[],
        'weekdaysCompleted': <int>[],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> watchProgress(
    String uid,
  ) {
    return progressDoc(uid).snapshots();
  }

  static Future<Map<String, dynamic>?> getProgress(String uid) async {
    final doc = await progressDoc(uid).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  static Future<void> completeLesson(
    String uid,
    String lessonId,
    int points,
  ) async {
    final docRef = progressDoc(uid);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekday = now.weekday;

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        final data = snapshot.data() ?? {};

        final completedLessons = List<String>.from(
          data['completedLessons'] ?? [],
        );
        final badges = List<String>.from(data['badges'] ?? []);
        final weekdaysCompleted = List<int>.from(
          data['weekdaysCompleted'] ?? [],
        );
        final currentStreak = (data['currentStreak'] as num?)?.toInt() ?? 0;
        final lastStreakDateStr = data['lastStreakDate'] as String?;

        if (!completedLessons.contains(lessonId)) {
          completedLessons.add(lessonId);

          final newPoints = (data['totalPoints'] as num?)?.toInt() ?? 0;
          final newBadges = _checkAndAwardBadges(
            completedLessons.length,
            currentStreak,
            badges,
          );

          if (!weekdaysCompleted.contains(weekday)) {
            weekdaysCompleted.add(weekday);
          }

          final newStreak = _calculateStreak(weekdaysCompleted, currentStreak);
          final totalStreakDays = _calculateTotalStreak(
            lastStreakDateStr,
            today,
            (data['totalStreakDays'] as num?)?.toInt() ?? 0,
          );

          transaction.update(docRef, {
            'totalPoints': newPoints + points,
            'completedLessons': completedLessons,
            'badges': newBadges,
            'currentStreak': newStreak,
            'totalStreakDays': totalStreakDays,
            'weekdaysCompleted': weekdaysCompleted,
            'lastCompletedDate': today.toIso8601String(),
            'lastStreakDate': today.toIso8601String(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print('Error completing lesson: $e');
    }
  }

  static List<String> _checkAndAwardBadges(
    int completedCount,
    int streak,
    List<String> currentBadges,
  ) {
    final newBadges = List<String>.from(currentBadges);

    if (completedCount >= 1 && !newBadges.contains('first_lesson')) {
      newBadges.add('first_lesson');
    }
    if (completedCount >= 5 && !newBadges.contains('five_lessons')) {
      newBadges.add('five_lessons');
    }
    if (streak >= 7 && !newBadges.contains('week_streak')) {
      newBadges.add('week_streak');
    }
    if (streak >= 30 && !newBadges.contains('month_streak')) {
      newBadges.add('month_streak');
    }
    if (streak >= 365 && !newBadges.contains('year_streak')) {
      newBadges.add('year_streak');
    }

    return newBadges;
  }

  static int _calculateStreak(List<int> weekdaysCompleted, int currentStreak) {
    final now = DateTime.now();
    final currentWeekday = now.weekday;

    final hasToday = weekdaysCompleted.contains(currentWeekday);
    final hasYesterday = weekdaysCompleted.contains(
      currentWeekday == 1 ? 7 : currentWeekday - 1,
    );

    if (!hasToday && !hasYesterday) {
      return 0;
    }

    return currentStreak + (hasToday && !hasYesterday ? 1 : 0);
  }

  static int _calculateTotalStreak(
    String? lastStreakDateStr,
    DateTime today,
    int currentTotalStreak,
  ) {
    if (lastStreakDateStr == null) {
      return 1;
    }

    final lastDate = DateTime.tryParse(lastStreakDateStr);
    if (lastDate == null) {
      return 1;
    }

    final diff = today.difference(lastDate).inDays;

    if (diff == 0) {
      return currentTotalStreak;
    } else if (diff == 1) {
      return currentTotalStreak + 1;
    } else {
      return 1;
    }
  }

  static Future<void> addPoints(String uid, int points) async {
    final docRef = progressDoc(uid);
    await docRef.update({
      'totalPoints': FieldValue.increment(points),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> resetWeek() async {
    // Note: This would be called by a scheduled job or checked client-side
  }
}
