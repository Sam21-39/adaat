import 'package:flutter/material.dart';
import '../../../../app/themes/colors.dart';

/// GitHub-style heatmap calendar widget
class HeatmapCalendar extends StatelessWidget {
  final Map<DateTime, double> data; // Date -> completion rate (0.0 to 1.0)
  final int weeks;
  final double cellSize;
  final double cellSpacing;
  final Function(DateTime)? onDayTap;

  const HeatmapCalendar({
    super.key,
    required this.data,
    this.weeks = 52,
    this.cellSize = 12,
    this.cellSpacing = 3,
    this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month labels
        _buildMonthLabels(context),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day labels
            _buildDayLabels(context),
            const SizedBox(width: 8),
            // Heatmap grid
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: _buildHeatmapGrid(isDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Legend
        _buildLegend(context, isDark),
      ],
    );
  }

  Widget _buildMonthLabels(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final months = <String>[];
    final monthPositions = <int>[];

    DateTime current = now;
    String? lastMonth;

    for (int week = 0; week < weeks; week++) {
      final weekStart = current.subtract(Duration(days: current.weekday % 7));
      final monthName = _monthName(weekStart.month);
      if (monthName != lastMonth) {
        months.add(monthName);
        monthPositions.add(weeks - week - 1);
        lastMonth = monthName;
      }
      current = current.subtract(const Duration(days: 7));
    }

    return SizedBox(
      height: 16,
      child: Row(
        children: [
          const SizedBox(width: 28), // Space for day labels
          Expanded(
            child: Stack(
              children: [
                for (int i = 0; i < months.length && i < 12; i++)
                  Positioned(
                    left: monthPositions[i] * (cellSize + cellSpacing),
                    child: Text(months[i], style: theme.textTheme.labelSmall),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayLabels(BuildContext context) {
    final theme = Theme.of(context);
    const days = ['', 'M', '', 'W', '', 'F', ''];

    return Column(
      children: days
          .map(
            (d) => SizedBox(
              height: cellSize + cellSpacing,
              child: Text(d, style: theme.textTheme.labelSmall?.copyWith(fontSize: 10)),
            ),
          )
          .toList(),
    );
  }

  Widget _buildHeatmapGrid(bool isDark) {
    final now = DateTime.now();
    final List<Widget> weekColumns = [];

    for (int week = 0; week < weeks; week++) {
      final List<Widget> dayCells = [];
      for (int day = 0; day < 7; day++) {
        final daysAgo = week * 7 + (6 - now.weekday % 7) + day - 6;
        final date = now.subtract(Duration(days: -daysAgo));

        if (date.isAfter(now)) {
          dayCells.add(SizedBox(width: cellSize, height: cellSize));
        } else {
          final dateKey = DateTime(date.year, date.month, date.day);
          final value = data[dateKey] ?? 0.0;

          dayCells.add(
            GestureDetector(
              onTap: onDayTap != null ? () => onDayTap!(dateKey) : null,
              child: Tooltip(
                message: '${date.day}/${date.month}/${date.year}: ${(value * 100).toInt()}%',
                child: Container(
                  width: cellSize,
                  height: cellSize,
                  margin: EdgeInsets.all(cellSpacing / 2),
                  decoration: BoxDecoration(
                    color: _getColorForValue(value, isDark),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          );
        }
      }
      weekColumns.add(Column(children: dayCells.reversed.toList()));
    }

    return Row(children: weekColumns.reversed.toList());
  }

  Widget _buildLegend(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final colors = [
      _getColorForValue(0.0, isDark),
      _getColorForValue(0.25, isDark),
      _getColorForValue(0.5, isDark),
      _getColorForValue(0.75, isDark),
      _getColorForValue(1.0, isDark),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Less', style: theme.textTheme.labelSmall),
        const SizedBox(width: 4),
        ...colors.map(
          (color) => Container(
            width: cellSize,
            height: cellSize,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
        ),
        const SizedBox(width: 4),
        Text('More', style: theme.textTheme.labelSmall),
      ],
    );
  }

  Color _getColorForValue(double value, bool isDark) {
    if (value == 0) {
      return isDark ? const Color(0xFF2D3748) : AppColors.heatmapEmpty;
    } else if (value < 0.25) {
      return AppColors.heatmapLevel1;
    } else if (value < 0.50) {
      return AppColors.heatmapLevel2;
    } else if (value < 0.75) {
      return AppColors.heatmapLevel3;
    } else {
      return AppColors.heatmapLevel4;
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
