import 'package:get/get.dart';
import '../../../data/repositories/habit_repository.dart';

/// Controller for statistics screen
class StatsController extends GetxController {
  final HabitRepository _repository = HabitRepository();

  final heatmapData = <DateTime, double>{}.obs;
  final isLoading = true.obs;

  // Stats
  final totalHabits = 0.obs;
  final totalCheckIns = 0.obs;
  final currentLongestStreak = 0.obs;
  final overallSuccessRate = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  Future<void> loadStats() async {
    isLoading.value = true;
    try {
      // Load heatmap data
      heatmapData.value = await _repository.getHeatmapData(days: 365);

      // Load habits with stats
      final habits = await _repository.getAllHabitsWithStats();

      totalHabits.value = habits.length;

      // Calculate totals
      int checkIns = 0;
      int longestStreak = 0;
      double totalSuccessRate = 0;

      for (final habit in habits) {
        checkIns += habit.totalCheckIns;
        if (habit.currentStreak > longestStreak) {
          longestStreak = habit.currentStreak;
        }
        totalSuccessRate += habit.successRate;
      }

      totalCheckIns.value = checkIns;
      currentLongestStreak.value = longestStreak;
      overallSuccessRate.value = habits.isNotEmpty ? totalSuccessRate / habits.length : 0;
    } finally {
      isLoading.value = false;
    }
  }
}
