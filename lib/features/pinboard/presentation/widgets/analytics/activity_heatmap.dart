import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/pin.dart';

/// A heatmap showing pin activity over time
class ActivityHeatmap extends StatelessWidget {
  /// Constructor
  const ActivityHeatmap({
    super.key,
    required this.pins,
    required this.theme,
  });

  /// The pins to display activity for
  final List<Pin> pins;

  /// The current theme
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    // Calculate activity data
    final activityData = _calculateActivityData();
    final maxActivity = activityData.values
        .fold<int>(0, (max, count) => count > max ? count : max);

    // Get date range - show last week only
    final now = DateTime.now();
    final startDate =
        now.subtract(const Duration(days: 6)); // Last 7 days including today

    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _buildDayLabels(startDate),
          ),
          const SizedBox(height: 4),

          // Heatmap grid
          Expanded(
            child: _buildHeatmapGrid(startDate, activityData, maxActivity),
          ),

          const SizedBox(height: 8),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Less', style: TextStyle(fontSize: 9)),
              const SizedBox(width: 8),
              ..._buildLegendCells(maxActivity),
              const SizedBox(width: 8),
              const Text('More', style: TextStyle(fontSize: 9)),
            ],
          ),
        ],
      );
    });
  }

  List<Widget> _buildDayLabels(DateTime startDate) {
    final dayFormat = DateFormat('E'); // Short day name
    final days = <Widget>[];

    // Show 7 days
    for (int i = 0; i < 7; i++) {
      final date = startDate.add(Duration(days: i));
      days.add(
        Text(
          dayFormat.format(date),
          style: TextStyle(fontSize: 8),
          textAlign: TextAlign.center,
        ),
      );
    }

    return days;
  }

  Widget _buildHeatmapGrid(
    DateTime startDate,
    Map<DateTime, int> activityData,
    int maxActivity,
  ) {
    // Fixed cell size
    const cellSize = 12.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        // Calculate the date for this cell
        final date = startDate.add(Duration(days: index));

        // Get activity count for this date
        final count = activityData[_normalizeDate(date)] ?? 0;

        // Calculate color intensity based on activity
        final color = _getColorForActivity(count, maxActivity);

        return Tooltip(
          message:
              '${DateFormat('MMM d, yyyy').format(date)}: $count ${count == 1 ? 'pin' : 'pins'}',
          child: Container(
            width: cellSize,
            height: cellSize,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  List<Widget> _buildLegendCells(int maxActivity) {
    final cells = <Widget>[];

    // Create 5 legend cells with increasing intensity
    for (int i = 0; i < 5; i++) {
      final intensity = i / 4.0; // 0 to 1
      final count = (maxActivity * intensity).round();

      cells.add(
        Container(
          width: 8, // Smaller legend cells
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: _getColorForActivity(count, maxActivity),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      );
    }

    return cells;
  }

  Color _getColorForActivity(int count, int maxActivity) {
    if (count == 0) {
      return theme.colorScheme.surfaceContainerHighest;
    }

    // Calculate intensity (0 to 1)
    final intensity = maxActivity > 0 ? (count / maxActivity).toDouble() : 0.0;

    // Use primary color with varying opacity based on intensity
    return Color.lerp(
      theme.colorScheme.primary.withOpacity(0.2),
      theme.colorScheme.primary,
      intensity,
    )!;
  }

  Map<DateTime, int> _calculateActivityData() {
    final activityData = <DateTime, int>{};

    for (final pin in pins) {
      // Count pin creation
      final createdDate = _normalizeDate(pin.createdAt);
      activityData[createdDate] = (activityData[createdDate] ?? 0) + 1;

      // Count pin updates
      final updatedDate = _normalizeDate(pin.updatedAt);
      if (updatedDate != createdDate) {
        activityData[updatedDate] = (activityData[updatedDate] ?? 0) + 1;
      }

      // Count version history updates
      for (final version in pin.versionHistory) {
        final versionDate = _normalizeDate(version.timestamp);
        if (versionDate != createdDate && versionDate != updatedDate) {
          activityData[versionDate] = (activityData[versionDate] ?? 0) + 1;
        }
      }
    }

    return activityData;
  }

  /// Normalize date to start of day for consistent comparison
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
