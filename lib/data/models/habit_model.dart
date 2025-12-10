import 'package:uuid/uuid.dart';
import '../../core/utils/constants.dart';

/// Habit model representing a user's habit
class HabitModel {
  final String id;
  final String name;
  final String emoji;
  final HabitCategory category;
  final HabitFrequency frequency;
  final List<int>? customDays; // 0-6 for Sun-Sat
  final int? targetCount; // For countable habits (e.g., 8 glasses)
  final String? reminderTime; // HH:mm format
  final bool reminderEnabled;
  final int color; // Hex color
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? archivedAt;

  // Computed from check-ins (not stored)
  int currentStreak;
  int longestStreak;
  int totalCheckIns;
  double successRate;
  DateTime? lastCheckIn;

  HabitModel({
    String? id,
    required this.name,
    required this.emoji,
    required this.category,
    this.frequency = HabitFrequency.daily,
    this.customDays,
    this.targetCount,
    this.reminderTime,
    this.reminderEnabled = true,
    int? color,
    this.notes,
    this.isActive = true,
    DateTime? createdAt,
    this.archivedAt,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalCheckIns = 0,
    this.successRate = 0.0,
    this.lastCheckIn,
  }) : id = id ?? const Uuid().v4(),
       color = color ?? category.color,
       createdAt = createdAt ?? DateTime.now();

  /// Create from database map
  factory HabitModel.fromMap(Map<String, dynamic> map) {
    return HabitModel(
      id: map['id'] as String,
      name: map['name'] as String,
      emoji: map['emoji'] as String,
      category: HabitCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => HabitCategory.productivity,
      ),
      frequency: HabitFrequency.values.firstWhere(
        (f) => f.name == map['frequency'],
        orElse: () => HabitFrequency.daily,
      ),
      customDays: map['custom_days'] != null
          ? (map['custom_days'] as String).split(',').map((e) => int.parse(e)).toList()
          : null,
      targetCount: map['target_count'] as int?,
      reminderTime: map['reminder_time'] as String?,
      reminderEnabled: (map['reminder_enabled'] as int?) == 1,
      color: map['color'] as int,
      notes: map['notes'] as String?,
      isActive: (map['is_active'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      archivedAt: map['archived_at'] != null ? DateTime.parse(map['archived_at'] as String) : null,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'category': category.name,
      'frequency': frequency.name,
      'custom_days': customDays?.join(','),
      'target_count': targetCount,
      'reminder_time': reminderTime,
      'reminder_enabled': reminderEnabled ? 1 : 0,
      'color': color,
      'notes': notes,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'archived_at': archivedAt?.toIso8601String(),
    };
  }

  /// Copy with modifications
  HabitModel copyWith({
    String? name,
    String? emoji,
    HabitCategory? category,
    HabitFrequency? frequency,
    List<int>? customDays,
    int? targetCount,
    String? reminderTime,
    bool? reminderEnabled,
    int? color,
    String? notes,
    bool? isActive,
    DateTime? archivedAt,
    int? currentStreak,
    int? longestStreak,
    int? totalCheckIns,
    double? successRate,
    DateTime? lastCheckIn,
  }) {
    return HabitModel(
      id: id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      customDays: customDays ?? this.customDays,
      targetCount: targetCount ?? this.targetCount,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      color: color ?? this.color,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      archivedAt: archivedAt ?? this.archivedAt,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalCheckIns: totalCheckIns ?? this.totalCheckIns,
      successRate: successRate ?? this.successRate,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
    );
  }

  /// Check if habit is scheduled for a given day (0-6, Sun-Sat)
  bool isScheduledFor(int dayOfWeek) {
    switch (frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.weekly:
        return dayOfWeek == 0; // Sundays only for weekly
      case HabitFrequency.custom:
        return customDays?.contains(dayOfWeek) ?? false;
    }
  }

  @override
  String toString() {
    return 'HabitModel(id: $id, name: $name, emoji: $emoji, category: ${category.name})';
  }
}
