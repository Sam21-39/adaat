import 'package:uuid/uuid.dart';
import '../../core/utils/constants.dart';

/// Check-in model representing a habit completion
class CheckInModel {
  final String id;
  final String habitId;
  final DateTime date;
  final DateTime time;
  final int count; // For countable habits
  final String? notes;
  final CheckInMood? mood;
  final DateTime createdAt;

  CheckInModel({
    String? id,
    required this.habitId,
    required this.date,
    DateTime? time,
    this.count = 1,
    this.notes,
    this.mood,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       time = time ?? DateTime.now(),
       createdAt = createdAt ?? DateTime.now();

  /// Create from database map
  factory CheckInModel.fromMap(Map<String, dynamic> map) {
    return CheckInModel(
      id: map['id'] as String,
      habitId: map['habit_id'] as String,
      date: DateTime.parse(map['check_in_date'] as String),
      time: DateTime.parse(map['check_in_time'] as String),
      count: map['count'] as int? ?? 1,
      notes: map['notes'] as String?,
      mood: map['mood'] != null
          ? CheckInMood.values.firstWhere(
              (m) => m.name == map['mood'],
              orElse: () => CheckInMood.good,
            )
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'check_in_date': _dateOnly(date),
      'check_in_time': time.toIso8601String(),
      'count': count,
      'notes': notes,
      'mood': mood?.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Get date-only string (YYYY-MM-DD)
  static String _dateOnly(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  /// Copy with modifications
  CheckInModel copyWith({int? count, String? notes, CheckInMood? mood}) {
    return CheckInModel(
      id: id,
      habitId: habitId,
      date: date,
      time: time,
      count: count ?? this.count,
      notes: notes ?? this.notes,
      mood: mood ?? this.mood,
      createdAt: createdAt,
    );
  }

  @override
  String toString() {
    return 'CheckInModel(id: $id, habitId: $habitId, date: ${_dateOnly(date)}, count: $count)';
  }
}
