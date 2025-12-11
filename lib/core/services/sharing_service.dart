import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/habit_model.dart';
import '../../app/themes/colors.dart';

/// Service for social sharing functionality
class SharingService extends GetxService {
  static SharingService get to => Get.find<SharingService>();

  /// Share streak achievement
  Future<void> shareStreak(HabitModel habit) async {
    final text = _buildStreakShareText(habit);
    await Share.share(text, subject: 'My Habit Streak 🔥');
  }

  /// Share daily progress
  Future<void> shareDailyProgress({
    required int completed,
    required int total,
    required double percentage,
  }) async {
    final text = _buildDailyProgressText(completed, total, percentage);
    await Share.share(text, subject: 'My Daily Progress');
  }

  /// Share milestone achievement
  Future<void> shareMilestone(HabitModel habit, int milestone) async {
    final text = _buildMilestoneText(habit, milestone);
    await Share.share(text, subject: 'Milestone Achieved! 🏆');
  }

  /// Build streak share text
  String _buildStreakShareText(HabitModel habit) {
    return '''
🔥 I'm on a ${habit.currentStreak} day streak!

${habit.emoji} ${habit.name}

Building habits that stick with Adaat! 💪

#Adaat #HabitTracker #${habit.currentStreak}DayStreak #ConsistencyIsKey
''';
  }

  /// Build daily progress text
  String _buildDailyProgressText(int completed, int total, double percentage) {
    String emoji;
    String message;

    if (percentage >= 1.0) {
      emoji = '🏆';
      message = 'Perfect day achieved!';
    } else if (percentage >= 0.75) {
      emoji = '🔥';
      message = 'Almost there!';
    } else if (percentage >= 0.5) {
      emoji = '💪';
      message = 'Making progress!';
    } else {
      emoji = '🌱';
      message = 'Building habits!';
    }

    return '''
$emoji $message

Today's Progress: $completed/$total habits completed (${(percentage * 100).toInt()}%)

Track your habits with Adaat! ✨

#Adaat #DailyProgress #HabitBuilding
''';
  }

  /// Build milestone text
  String _buildMilestoneText(HabitModel habit, int milestone) {
    String badge;
    String achievement;

    if (milestone >= 100) {
      badge = '💎';
      achievement = 'Diamond Achiever';
    } else if (milestone >= 66) {
      badge = '🏆';
      achievement = 'Habit Master';
    } else if (milestone >= 30) {
      badge = '🥇';
      achievement = 'Consistency Champion';
    } else if (milestone >= 21) {
      badge = '🌟';
      achievement = 'Habit Builder';
    } else if (milestone >= 7) {
      badge = '🔥';
      achievement = 'Week Warrior';
    } else {
      badge = '✨';
      achievement = 'Getting Started';
    }

    return '''
$badge MILESTONE UNLOCKED! $badge

$milestone Days of ${habit.emoji} ${habit.name}!

Achievement: $achievement

Join me on Adaat and build habits that stick! 🚀

#Adaat #$milestone DayStreak #$achievement
''';
  }

  /// Show share bottom sheet with options
  void showShareSheet(BuildContext context, HabitModel habit) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ShareBottomSheet(habit: habit),
    );
  }
}

class _ShareBottomSheet extends StatelessWidget {
  final HabitModel habit;

  const _ShareBottomSheet({required this.habit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Share Your Progress', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Celebrate your ${habit.currentStreak} day streak! 🎉',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 24),

          // Preview card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(habit.emoji, style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 8),
                Text(
                  habit.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '🔥 ${habit.currentStreak} Day Streak',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Share buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShareButton(
                context,
                emoji: '📸',
                label: 'Story',
                onTap: () {
                  Get.back();
                  SharingService.to.shareStreak(habit);
                },
              ),
              _buildShareButton(
                context,
                emoji: '💬',
                label: 'WhatsApp',
                onTap: () {
                  Get.back();
                  SharingService.to.shareStreak(habit);
                },
              ),
              _buildShareButton(
                context,
                emoji: '🐦',
                label: 'Twitter',
                onTap: () {
                  Get.back();
                  SharingService.to.shareStreak(habit);
                },
              ),
              _buildShareButton(
                context,
                emoji: '📋',
                label: 'Copy',
                onTap: () {
                  Get.back();
                  SharingService.to.shareStreak(habit);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildShareButton(
    BuildContext context, {
    required String emoji,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
