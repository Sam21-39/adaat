import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/themes/colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../controllers/stats_controller.dart';
import 'widgets/heatmap_widget.dart';

/// Full statistics view with charts and analytics
class StatsView extends GetView<StatsController> {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: controller.loadStats)],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.loadStats,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview stats
                _buildOverviewStats(context),
                const SizedBox(height: 24),

                // Weekly performance chart
                Text('Weekly Performance', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                _buildWeeklyChart(context),
                const SizedBox(height: 24),

                // Heatmap
                Text('Activity Heatmap', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: HeatmapCalendar(
                    data: controller.heatmapData,
                    weeks: 16, // 4 months
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                const SizedBox(height: 24),

                // Habit leaderboard
                Text('Top Habits', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                _buildHabitLeaderboard(context),
                const SizedBox(height: 24),

                // Monthly trend
                Text('Monthly Trend', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                _buildMonthlyTrendChart(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildOverviewStats(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Total Habits',
                value: '${controller.totalHabits.value}',
                icon: Icons.track_changes,
                color: AppColors.primaryOrange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Total Check-ins',
                value: '${controller.totalCheckIns.value}',
                icon: Icons.check_circle,
                color: AppColors.accentGreen,
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Current Streak',
                value: '${controller.currentLongestStreak.value}',
                icon: Icons.local_fire_department,
                color: AppColors.accentYellow,
                subtitle: 'days',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Success Rate',
                value: '${controller.overallSuccessRate.value.toInt()}%',
                icon: Icons.trending_up,
                color: AppColors.primaryPurple,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
      ],
    );
  }

  Widget _buildWeeklyChart(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Obx(() {
        final data = controller.weeklyData;
        if (data.isEmpty) {
          return const Center(child: Text('No data yet'));
        }

        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 100,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
                  return BarTooltipItem(
                    '${days[group.x.toInt()]}\n${rod.toY.toInt()}%',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(days[value.toInt() % 7], style: theme.textTheme.labelSmall),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    if (value == 0 || value == 50 || value == 100) {
                      return Text('${value.toInt()}%', style: theme.textTheme.labelSmall);
                    }
                    return const SizedBox();
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              horizontalInterval: 25,
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: theme.dividerColor, strokeWidth: 1),
              drawVerticalLine: false,
            ),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(7, (i) {
              final value = data[i] ?? 0.0;
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: value * 100,
                    color: _getBarColor(value),
                    width: 20,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              );
            }),
          ),
        );
      }),
    ).animate().fadeIn(delay: 150.ms, duration: 400.ms);
  }

  Color _getBarColor(double value) {
    if (value >= 0.8) return AppColors.accentGreen;
    if (value >= 0.5) return AppColors.accentYellow;
    if (value >= 0.25) return AppColors.primaryOrange;
    return AppColors.accentRed;
  }

  Widget _buildHabitLeaderboard(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final habits = controller.topHabits;
      if (habits.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
          ),
          child: const Center(child: Text('No habits yet')),
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          children: habits.asMap().entries.map((entry) {
            final index = entry.key;
            final habit = entry.value;
            final isLast = index == habits.length - 1;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Rank badge
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: index == 0
                              ? AppColors.accentYellow.withAlpha(50)
                              : index == 1
                              ? Colors.grey.withAlpha(100)
                              : AppColors.primaryOrange.withAlpha(50),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: index == 0
                                  ? AppColors.accentYellow
                                  : index == 1
                                  ? Colors.grey
                                  : AppColors.primaryOrange,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Habit info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(habit.emoji),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    habit.name,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${habit.currentStreak} day streak • ${habit.successRate.toInt()}% success',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      // Progress circle
                      ProgressCircle(
                        progress: habit.successRate / 100,
                        size: 40,
                        strokeWidth: 4,
                        color: Color(habit.color),
                        child: Text(
                          '${habit.successRate.toInt()}%',
                          style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast) Divider(height: 1, color: theme.dividerColor),
              ],
            );
          }).toList(),
        ),
      ).animate().fadeIn(delay: 250.ms, duration: 400.ms);
    });
  }

  Widget _buildMonthlyTrendChart(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Obx(() {
        final data = controller.monthlyTrend;
        if (data.isEmpty) {
          return const Center(child: Text('No data yet'));
        }

        return LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              horizontalInterval: 25,
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: theme.dividerColor, strokeWidth: 1),
              drawVerticalLine: false,
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final weekNum = value.toInt() + 1;
                    if (weekNum == 1 || weekNum == 2 || weekNum == 3 || weekNum == 4) {
                      return Text('W$weekNum', style: theme.textTheme.labelSmall);
                    }
                    return const SizedBox();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    if (value == 0 || value == 50 || value == 100) {
                      return Text('${value.toInt()}%', style: theme.textTheme.labelSmall);
                    }
                    return const SizedBox();
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: 3,
            minY: 0,
            maxY: 100,
            lineBarsData: [
              LineChartBarData(
                spots: data.asMap().entries.map((e) {
                  return FlSpot(e.key.toDouble(), e.value * 100);
                }).toList(),
                isCurved: true,
                color: AppColors.primaryOrange,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 5,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: AppColors.primaryOrange,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryOrange.withAlpha(100),
                      AppColors.primaryOrange.withAlpha(25),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }
}
