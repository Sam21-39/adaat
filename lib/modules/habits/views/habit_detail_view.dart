import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../data/models/habit_model.dart';
import '../../../data/repositories/habit_repository.dart';
import '../../home/controllers/home_controller.dart';
import '../../statistics/views/widgets/heatmap_widget.dart';

/// Habit detail view with stats
class HabitDetailView extends StatefulWidget {
  const HabitDetailView({super.key});

  @override
  State<HabitDetailView> createState() => _HabitDetailViewState();
}

class _HabitDetailViewState extends State<HabitDetailView> {
  final HabitRepository _repository = HabitRepository();

  HabitModel? habit;
  Map<DateTime, double> heatmapData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabit();
  }

  Future<void> _loadHabit() async {
    final habitId = Get.arguments as String?;
    if (habitId == null) {
      Get.back();
      return;
    }

    setState(() => isLoading = true);

    try {
      final loadedHabit = await _repository.getHabitWithStats(habitId);
      final checkIns = await _repository.getCheckInsForHabit(habitId);

      // Build heatmap data for this habit
      final Map<DateTime, double> data = {};
      for (int i = 0; i < 365; i++) {
        final date = DateTime.now().subtract(Duration(days: i));
        final dateOnly = DateTime(date.year, date.month, date.day);

        if (loadedHabit.isScheduledFor(dateOnly.weekday % 7)) {
          final hasCheckIn = checkIns.any(
            (c) =>
                c.date.year == dateOnly.year &&
                c.date.month == dateOnly.month &&
                c.date.day == dateOnly.day,
          );
          data[dateOnly] = hasCheckIn ? 1.0 : 0.0;
        }
      }

      setState(() {
        habit = loadedHabit;
        heatmapData = data;
        isLoading = false;
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to load habit');
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (habit == null) {
      return const Scaffold(body: Center(child: Text('Habit not found')));
    }

    final habitColor = Color(habit!.color);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(habit!.emoji),
            const SizedBox(width: 8),
            Flexible(child: Text(habit!.name, overflow: TextOverflow.ellipsis)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit') {
                // TODO: Navigate to edit
              } else if (value == 'delete') {
                _showDeleteConfirmation();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: AppColors.accentRed)),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHabit,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats grid
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Current Streak',
                      value: '${habit!.currentStreak}',
                      icon: Icons.local_fire_department,
                      color: AppColors.accentYellow,
                      subtitle: 'days',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Longest Streak',
                      value: '${habit!.longestStreak}',
                      icon: Icons.emoji_events,
                      color: AppColors.primaryOrange,
                      subtitle: 'days',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Total Check-ins',
                      value: '${habit!.totalCheckIns}',
                      icon: Icons.check_circle,
                      color: AppColors.accentGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Success Rate',
                      value: '${habit!.successRate.toInt()}%',
                      icon: Icons.trending_up,
                      color: habitColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Heatmap
              Text('Activity', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: HeatmapCalendar(
                  data: heatmapData,
                  weeks: 26, // 6 months
                  onDayTap: (date) {
                    // Show date info
                    final value = heatmapData[date] ?? 0;
                    Get.snackbar(
                      '${date.day}/${date.month}/${date.year}',
                      value > 0 ? 'Completed ✅' : 'Missed ❌',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Details
              Text('Details', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      context,
                      'Category',
                      '${habit!.category.emoji} ${habit!.category.label}',
                    ),
                    const Divider(),
                    _buildDetailRow(context, 'Frequency', habit!.frequency.label),
                    if (habit!.reminderTime != null) ...[
                      const Divider(),
                      _buildDetailRow(context, 'Reminder', habit!.reminderTime!),
                    ],
                    if (habit!.targetCount != null) ...[
                      const Divider(),
                      _buildDetailRow(context, 'Target', '${habit!.targetCount} per day'),
                    ],
                    const Divider(),
                    _buildDetailRow(
                      context,
                      'Created',
                      '${habit!.createdAt.day}/${habit!.createdAt.month}/${habit!.createdAt.year}',
                    ),
                  ],
                ),
              ),

              if (habit!.notes != null && habit!.notes!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Notes', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Text(habit!.notes!, style: theme.textTheme.bodyMedium),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Habit'),
        content: Text(
          'Are you sure you want to delete "${habit!.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentRed),
            onPressed: () async {
              await _repository.archiveHabit(habit!.id);
              if (Get.isRegistered<HomeController>()) {
                Get.find<HomeController>().loadHabits();
              }
              Get.back(); // Close dialog
              Get.back(); // Go back to home
              Get.snackbar('Deleted', 'Habit deleted successfully');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
