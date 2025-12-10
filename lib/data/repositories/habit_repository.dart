import 'package:get/get.dart';
import '../models/habit_model.dart';
import '../models/checkin_model.dart';
import '../../core/services/database_service.dart';
import '../../core/utils/constants.dart';

/// Repository for habit and check-in operations
class HabitRepository {
  final DatabaseService _db = DatabaseService.to;

  // ============== HABITS ==============

  /// Get all active habits
  Future<List<HabitModel>> getAllHabits({bool activeOnly = true}) async {
    final maps = await _db.query(
      AppConstants.tableHabits,
      where: activeOnly ? 'is_active = ?' : null,
      whereArgs: activeOnly ? [1] : null,
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => HabitModel.fromMap(m)).toList();
  }

  /// Get habit by ID
  Future<HabitModel?> getHabitById(String id) async {
    final maps = await _db.query(
      AppConstants.tableHabits,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return HabitModel.fromMap(maps.first);
  }

  /// Get habits scheduled for a specific day
  Future<List<HabitModel>> getHabitsForDay(DateTime date) async {
    final dayOfWeek = date.weekday % 7; // 0-6, Sun-Sat
    final allHabits = await getAllHabits();

    return allHabits.where((habit) => habit.isScheduledFor(dayOfWeek)).toList();
  }

  /// Create a new habit
  Future<void> createHabit(HabitModel habit) async {
    await _db.insert(AppConstants.tableHabits, habit.toMap());
  }

  /// Update a habit
  Future<void> updateHabit(HabitModel habit) async {
    await _db.update(
      AppConstants.tableHabits,
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  /// Archive a habit (soft delete)
  Future<void> archiveHabit(String id) async {
    await _db.update(
      AppConstants.tableHabits,
      {'is_active': 0, 'archived_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete a habit permanently
  Future<void> deleteHabit(String id) async {
    await _db.delete(AppConstants.tableHabits, where: 'id = ?', whereArgs: [id]);
  }

  // ============== CHECK-INS ==============

  /// Get all check-ins for a habit
  Future<List<CheckInModel>> getCheckInsForHabit(String habitId) async {
    final maps = await _db.query(
      AppConstants.tableCheckIns,
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'check_in_date DESC',
    );
    return maps.map((m) => CheckInModel.fromMap(m)).toList();
  }

  /// Get check-in for a specific habit and date
  Future<CheckInModel?> getCheckIn(String habitId, DateTime date) async {
    final dateStr = _dateOnly(date);
    final maps = await _db.query(
      AppConstants.tableCheckIns,
      where: 'habit_id = ? AND check_in_date = ?',
      whereArgs: [habitId, dateStr],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return CheckInModel.fromMap(maps.first);
  }

  /// Get all check-ins for a date
  Future<List<CheckInModel>> getCheckInsForDate(DateTime date) async {
    final dateStr = _dateOnly(date);
    final maps = await _db.query(
      AppConstants.tableCheckIns,
      where: 'check_in_date = ?',
      whereArgs: [dateStr],
    );
    return maps.map((m) => CheckInModel.fromMap(m)).toList();
  }

  /// Get check-ins in a date range
  Future<List<CheckInModel>> getCheckInsInRange(DateTime start, DateTime end) async {
    final startStr = _dateOnly(start);
    final endStr = _dateOnly(end);
    final maps = await _db.query(
      AppConstants.tableCheckIns,
      where: 'check_in_date >= ? AND check_in_date <= ?',
      whereArgs: [startStr, endStr],
      orderBy: 'check_in_date ASC',
    );
    return maps.map((m) => CheckInModel.fromMap(m)).toList();
  }

  /// Create or update a check-in
  Future<void> checkIn(CheckInModel checkIn) async {
    await _db.insert(AppConstants.tableCheckIns, checkIn.toMap());
  }

  /// Remove a check-in (undo)
  Future<void> removeCheckIn(String habitId, DateTime date) async {
    final dateStr = _dateOnly(date);
    await _db.delete(
      AppConstants.tableCheckIns,
      where: 'habit_id = ? AND check_in_date = ?',
      whereArgs: [habitId, dateStr],
    );
  }

  // ============== STREAKS & STATS ==============

  /// Calculate current streak for a habit
  Future<int> calculateCurrentStreak(String habitId) async {
    final checkIns = await getCheckInsForHabit(habitId);
    if (checkIns.isEmpty) return 0;

    final habit = await getHabitById(habitId);
    if (habit == null) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();

    // Check if today is a scheduled day and completed
    final todayCheckIn = checkIns.firstWhereOrNull((c) => _isSameDay(c.date, currentDate));
    if (todayCheckIn != null) {
      streak = 1;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    // Go backwards and count consecutive completions
    while (true) {
      // Skip non-scheduled days
      while (!habit.isScheduledFor(currentDate.weekday % 7)) {
        currentDate = currentDate.subtract(const Duration(days: 1));
      }

      final checkIn = checkIns.firstWhereOrNull((c) => _isSameDay(c.date, currentDate));

      if (checkIn != null) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Calculate longest streak for a habit
  Future<int> calculateLongestStreak(String habitId) async {
    final checkIns = await getCheckInsForHabit(habitId);
    if (checkIns.isEmpty) return 0;

    final habit = await getHabitById(habitId);
    if (habit == null) return 0;

    // Sort by date ascending
    checkIns.sort((a, b) => a.date.compareTo(b.date));

    int longestStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;

    for (final checkIn in checkIns) {
      if (lastDate == null) {
        currentStreak = 1;
      } else {
        // Check if consecutive (accounting for non-scheduled days)
        DateTime expectedDate = lastDate.add(const Duration(days: 1));
        while (!habit.isScheduledFor(expectedDate.weekday % 7)) {
          expectedDate = expectedDate.add(const Duration(days: 1));
        }

        if (_isSameDay(checkIn.date, expectedDate)) {
          currentStreak++;
        } else {
          currentStreak = 1;
        }
      }

      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }
      lastDate = checkIn.date;
    }

    return longestStreak;
  }

  /// Get habit with computed stats
  Future<HabitModel> getHabitWithStats(String habitId) async {
    final habit = await getHabitById(habitId);
    if (habit == null) throw Exception('Habit not found');

    final checkIns = await getCheckInsForHabit(habitId);
    final currentStreak = await calculateCurrentStreak(habitId);
    final longestStreak = await calculateLongestStreak(habitId);

    // Calculate success rate (last 30 days)
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    int scheduledDays = 0;
    int completedDays = 0;

    for (int i = 0; i < 30; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      if (habit.isScheduledFor(date.weekday % 7)) {
        scheduledDays++;
        if (checkIns.any((c) => _isSameDay(c.date, date))) {
          completedDays++;
        }
      }
    }

    final successRate = scheduledDays > 0 ? (completedDays / scheduledDays) * 100 : 0.0;

    return habit.copyWith(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalCheckIns: checkIns.length,
      successRate: successRate,
      lastCheckIn: checkIns.isNotEmpty ? checkIns.first.date : null,
    );
  }

  /// Get all habits with stats
  Future<List<HabitModel>> getAllHabitsWithStats() async {
    final habits = await getAllHabits();
    final List<HabitModel> habitsWithStats = [];

    for (final habit in habits) {
      final habitWithStats = await getHabitWithStats(habit.id);
      habitsWithStats.add(habitWithStats);
    }

    return habitsWithStats;
  }

  /// Get heatmap data for last N days
  Future<Map<DateTime, double>> getHeatmapData({int days = 365}) async {
    final Map<DateTime, double> heatmap = {};
    final habits = await getAllHabits();
    if (habits.isEmpty) return heatmap;

    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    final checkIns = await getCheckInsInRange(startDate, endDate);

    for (int i = 0; i <= days; i++) {
      final date = startDate.add(Duration(days: i));
      final dateOnly = DateTime(date.year, date.month, date.day);

      // Count habits scheduled for this day
      int scheduled = 0;
      int completed = 0;

      for (final habit in habits) {
        if (habit.isScheduledFor(dateOnly.weekday % 7)) {
          // Only count if habit was created before this date
          if (habit.createdAt.isBefore(dateOnly.add(const Duration(days: 1)))) {
            scheduled++;
            if (checkIns.any((c) => c.habitId == habit.id && _isSameDay(c.date, dateOnly))) {
              completed++;
            }
          }
        }
      }

      heatmap[dateOnly] = scheduled > 0 ? completed / scheduled : 0.0;
    }

    return heatmap;
  }

  // ============== HELPERS ==============

  String _dateOnly(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
