import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/learning_service.dart';
import '../services/firebase_service.dart';

class LearningProgress {
  final int totalPoints;
  final int currentStreak;
  final int totalStreakDays;
  final DateTime? lastCompletedDate;
  final List<String> completedLessons;
  final List<String> badges;
  final List<int> weekdaysCompleted;

  const LearningProgress({
    this.totalPoints = 0,
    this.currentStreak = 0,
    this.totalStreakDays = 0,
    this.lastCompletedDate,
    this.completedLessons = const [],
    this.badges = const [],
    this.weekdaysCompleted = const [],
  });

  factory LearningProgress.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) return const LearningProgress();
    return LearningProgress(
      totalPoints: (data['totalPoints'] as num?)?.toInt() ?? 0,
      currentStreak: (data['currentStreak'] as num?)?.toInt() ?? 0,
      totalStreakDays: (data['totalStreakDays'] as num?)?.toInt() ?? 0,
      lastCompletedDate: data['lastCompletedDate'] != null
          ? DateTime.tryParse(data['lastCompletedDate'] as String)
          : null,
      completedLessons: List<String>.from(data['completedLessons'] ?? []),
      badges: List<String>.from(data['badges'] ?? []),
      weekdaysCompleted: List<int>.from(data['weekdaysCompleted'] ?? []),
    );
  }

  double get progressPercentage {
    const totalLessons = 18;
    return completedLessons.length / totalLessons;
  }

  int get completedCount => completedLessons.length;
  int get totalLessons => 18;

  bool isLessonCompleted(String lessonId) =>
      completedLessons.contains(lessonId);

  bool hasBadge(String badgeId) => badges.contains(badgeId);
}

class LearningProvider extends ChangeNotifier {
  LearningProgress _progress = const LearningProgress();
  bool _isLoading = true;
  String? _error;
  StreamSubscription? _progressSub;

  LearningProgress get progress => _progress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get progressPercentage => _progress.progressPercentage;
  int get totalPoints => _progress.totalPoints;
  int get currentStreak => _progress.currentStreak;
  int get totalStreakDays => _progress.totalStreakDays;
  int get completedLessonsCount => _progress.completedCount;
  int get totalLessonsCount => _progress.totalLessons;

  bool isLessonCompleted(String lessonId) =>
      _progress.isLessonCompleted(lessonId);
  bool hasBadge(String badgeId) => _progress.hasBadge(badgeId);

  List<int> get weekdaysCompleted => _progress.weekdaysCompleted;

  void loadProgress(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await LearningService.initializeProgress(userId);

      _progressSub?.cancel();
      _progressSub = LearningService.watchProgress(userId).listen(
        (snapshot) {
          _progress = LearningProgress.fromFirestore(snapshot.data());
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          _error = e.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeLesson(
    String lessonId,
    int points, {
    String? badgeId,
  }) async {
    final userId = FirebaseService.currentUserId;
    if (userId == null) return;

    try {
      await LearningService.completeLesson(
        userId,
        lessonId,
        points,
        badgeId: badgeId,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearProgress() {
    _progressSub?.cancel();
    _progress = const LearningProgress();
    _isLoading = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _progressSub?.cancel();
    super.dispose();
  }
}
