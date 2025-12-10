import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/themes/colors.dart';
import '../../data/models/habit_model.dart';

/// Reusable habit card widget with check-in functionality
class HabitCard extends StatelessWidget {
  final HabitModel habit;
  final bool isCompleted;
  final int? completedCount;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const HabitCard({
    super.key,
    required this.habit,
    required this.isCompleted,
    this.completedCount,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habitColor = Color(habit.color);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isCompleted ? habitColor.withAlpha(25) : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted ? habitColor : theme.dividerColor,
            width: isCompleted ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Checkbox
              _buildCheckbox(habitColor),
              const SizedBox(width: 16),

              // Habit Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(habit.emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            habit.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                              color: isCompleted ? theme.textTheme.bodySmall?.color : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Streak
                        if (habit.currentStreak > 0) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentYellow.withAlpha(50),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🔥', style: TextStyle(fontSize: 12)),
                                const SizedBox(width: 4),
                                Text(
                                  '${habit.currentStreak} day${habit.currentStreak > 1 ? 's' : ''}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.accentYellow.withAlpha(200),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],

                        // Target progress for countable habits
                        if (habit.targetCount != null) ...[
                          Text(
                            '${completedCount ?? 0}/${habit.targetCount}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],

                        // Reminder time
                        if (habit.reminderTime != null && habit.reminderEnabled) ...[
                          const Spacer(),
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 4),
                          Text(habit.reminderTime!, style: theme.textTheme.bodySmall),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Chevron
              Icon(Icons.chevron_right, color: theme.textTheme.bodySmall?.color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isCompleted ? color : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: isCompleted ? color : color.withAlpha(100), width: 2),
      ),
      child: isCompleted
          ? const Icon(
              Icons.check,
              size: 18,
              color: Colors.white,
            ).animate().scale(duration: const Duration(milliseconds: 200), curve: Curves.elasticOut)
          : null,
    );
  }
}
