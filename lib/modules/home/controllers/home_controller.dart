import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/habit_model.dart';
import '../../../data/models/checkin_model.dart';
import '../../../data/repositories/habit_repository.dart';
import '../../../core/utils/constants.dart';

/// Controller for home dashboard
class HomeController extends GetxController {
  final HabitRepository _repository = HabitRepository();

  final habits = <HabitModel>[].obs;
  final todaysCheckIns = <String>[].obs; // List of habit IDs completed today
  final isLoading = true.obs;
  final todayProgress = 0.0.obs;

  // User greeting
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get greetingEmoji {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️';
    if (hour < 17) return '🌤️';
    return '🌙';
  }

  @override
  void onInit() {
    super.onInit();
    loadHabits();
  }

  /// Load habits for today
  Future<void> loadHabits() async {
    isLoading.value = true;
    try {
      // Get habits with stats
      final allHabits = await _repository.getAllHabitsWithStats();

      // Filter for today
      final today = DateTime.now();
      final dayOfWeek = today.weekday % 7;
      final todaysHabits = allHabits.where((h) => h.isScheduledFor(dayOfWeek)).toList();

      habits.value = todaysHabits;

      // Load today's check-ins
      final checkIns = await _repository.getCheckInsForDate(today);
      todaysCheckIns.value = checkIns.map((c) => c.habitId).toList();

      _updateProgress();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load habits: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Check if habit is completed today
  bool isCompletedToday(String habitId) {
    return todaysCheckIns.contains(habitId);
  }

  /// Toggle habit check-in
  Future<void> toggleCheckIn(HabitModel habit) async {
    final today = DateTime.now();

    if (isCompletedToday(habit.id)) {
      // Undo check-in
      await _repository.removeCheckIn(habit.id, today);
      todaysCheckIns.remove(habit.id);

      // Update habit streak
      final index = habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        final updatedHabit = await _repository.getHabitWithStats(habit.id);
        habits[index] = updatedHabit;
      }
    } else {
      // Create check-in
      final checkIn = CheckInModel(habitId: habit.id, date: today);
      await _repository.checkIn(checkIn);
      todaysCheckIns.add(habit.id);

      // Update habit streak
      final index = habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        final updatedHabit = await _repository.getHabitWithStats(habit.id);
        habits[index] = updatedHabit;
      }

      // Check for milestone
      final updatedHabit = await _repository.getHabitWithStats(habit.id);
      _checkMilestone(updatedHabit);
    }

    _updateProgress();
  }

  /// Update today's progress percentage
  void _updateProgress() {
    if (habits.isEmpty) {
      todayProgress.value = 0.0;
      return;
    }
    todayProgress.value = todaysCheckIns.length / habits.length;
  }

  /// Check if streak is a milestone
  void _checkMilestone(HabitModel habit) {
    if (AppConstants.streakMilestones.contains(habit.currentStreak)) {
      // Show celebration
      Get.dialog(_buildMilestoneDialog(habit), barrierDismissible: true);
    }
  }

  Widget _buildMilestoneDialog(HabitModel habit) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            '${habit.currentStreak} Day Streak!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('You\'re on fire with ${habit.emoji} ${habit.name}!', textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close),
                label: const Text('Close'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                  // TODO: Implement share
                },
                icon: const Icon(Icons.share),
                label: const Text('Share'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Create a new habit
  Future<void> createHabit(HabitModel habit) async {
    await _repository.createHabit(habit);
    await loadHabits();
  }

  /// Delete a habit
  Future<void> deleteHabit(String habitId) async {
    await _repository.archiveHabit(habitId);
    await loadHabits();
  }
}
