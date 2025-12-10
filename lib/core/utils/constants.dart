/// Habit categories with icons and colors
enum HabitCategory {
  health('💪', 'Health & Fitness', 0xFFEF4444),
  learning('📚', 'Learning', 0xFF3B82F6),
  money('💰', 'Money', 0xFF22C55E),
  productivity('🎯', 'Productivity', 0xFFF59E0B),
  wellness('🧘', 'Wellness', 0xFF8B5CF6),
  creative('🎨', 'Creative', 0xFFEC4899),
  spiritual('🙏', 'Spiritual', 0xFF6366F1);

  final String emoji;
  final String label;
  final int color;

  const HabitCategory(this.emoji, this.label, this.color);
}

/// Habit frequency options
enum HabitFrequency {
  daily('Daily'),
  weekly('Weekly'),
  custom('Custom Days');

  final String label;

  const HabitFrequency(this.label);
}

/// Time of day for habits (renamed to avoid Flutter conflict)
enum HabitTimeOfDay {
  morning('Morning', '🌅'),
  afternoon('Afternoon', '☀️'),
  evening('Evening', '🌙'),
  anytime('Anytime', '⏰');

  final String label;
  final String emoji;

  const HabitTimeOfDay(this.label, this.emoji);
}

/// Mood options for check-ins
enum CheckInMood {
  great('Great', '😄'),
  good('Good', '🙂'),
  okay('Okay', '😐'),
  tough('Tough', '😓');

  final String label;
  final String emoji;

  const CheckInMood(this.label, this.emoji);
}

/// App constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Adaat';
  static const String appTagline = 'Badlo Apni Aadat, Badlo Apni Zindagi';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'adaat.db';
  static const int databaseVersion = 1;

  // Tables
  static const String tableHabits = 'habits';
  static const String tableCheckIns = 'check_ins';
  static const String tableUsers = 'users';

  // Streak Milestones
  static const List<int> streakMilestones = [5, 7, 10, 14, 21, 30, 50, 66, 100, 365];

  // Habit Limits
  static const int maxHabitsForFree = 10;
  static const int maxRemindersPerHabit = 3;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Days of Week (for custom frequency)
  static const List<String> daysShort = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const List<String> daysLong = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];
}
