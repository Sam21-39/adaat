import 'package:get/get.dart';
import '../../../data/models/habit_model.dart';
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

  // Chart data
  final weeklyData = <int, double>{}.obs; // Day of week (0-6) -> completion rate
  final monthlyTrend = <double>[].obs; // Last 4 weeks
  final topHabits = <HabitModel>[].obs;

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

      // Calculate weekly data
      await _calculateWeeklyData();

      // Calculate monthly trend
      await _calculateMonthlyTrend();

      // Get top habits (sorted by success rate)
      final sortedHabits = List<HabitModel>.from(habits);
      sortedHabits.sort((a, b) => b.successRate.compareTo(a.successRate));
      topHabits.value = sortedHabits.take(5).toList();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _calculateWeeklyData() async {
    final Map<int, double> weekly = {};
    final Map<int, int> weeklyCounts = {};

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));

    // Get data for current week
    for (int i = 0; i < 7; i++) {
      final date = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day + i);
      final dateKey = DateTime(date.year, date.month, date.day);

      if (date.isAfter(now)) {
        weekly[i] = 0;
      } else {
        final value = heatmapData[dateKey] ?? 0.0;
        weekly[i] = value;
      }
    }

    weeklyData.value = weekly;
  }

  Future<void> _calculateMonthlyTrend() async {
    final List<double> trend = [];
    final now = DateTime.now();

    // Calculate completion rate for each of the last 4 weeks
    for (int week = 3; week >= 0; week--) {
      double weekTotal = 0;
      int weekDays = 0;

      for (int day = 0; day < 7; day++) {
        final date = now.subtract(Duration(days: (week * 7) + day));
        final dateKey = DateTime(date.year, date.month, date.day);

        final value = heatmapData[dateKey] ?? 0.0;
        weekTotal += value;
        weekDays++;
      }

      trend.add(weekDays > 0 ? weekTotal / weekDays : 0);
    }

    monthlyTrend.value = trend;
  }
}
