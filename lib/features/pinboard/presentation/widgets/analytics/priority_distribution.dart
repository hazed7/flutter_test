import 'package:flutter/material.dart';

import '../../../domain/models/pin.dart';

/// A chart showing the distribution of pin priorities
class PriorityDistribution extends StatelessWidget {
  /// Constructor
  const PriorityDistribution({
    super.key,
    required this.priorityCounts,
    required this.theme,
  });

  /// Map of pin priorities to counts
  final Map<PinPriority, int> priorityCounts;

  /// The current theme
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    if (priorityCounts.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    // Calculate total pins
    final totalPins =
        priorityCounts.values.fold<int>(0, (sum, count) => sum + count);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart title
            Text(
              'Priority Distribution',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Horizontal bar chart
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: PinPriority.values.map((priority) {
                  final count = priorityCounts[priority] ?? 0;
                  final percentage =
                      totalPins > 0 ? (count / totalPins).toDouble() : 0.0;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _buildPriorityBar(
                        priority: priority,
                        count: count,
                        percentage: percentage,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPriorityBar({
    required PinPriority priority,
    required int count,
    required double percentage,
  }) {
    return Column(
      children: [
        // Bar
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxHeight =
                  constraints.maxHeight - 40; // Reserve space for labels
              final barHeight = percentage * maxHeight;

              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Background
                  Container(
                    width: double.infinity,
                    height: maxHeight,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),

                  // Bar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutQuad,
                    width: double.infinity,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: _getColorForPriority(priority),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Count
        Text(
          '$count',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: _getColorForPriority(priority),
          ),
        ),

        const SizedBox(height: 4),

        // Label
        Text(
          priority.displayName,
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Get a color for a priority
  Color _getColorForPriority(PinPriority priority) {
    switch (priority) {
      case PinPriority.low:
        return Colors.blue;
      case PinPriority.medium:
        return Colors.green;
      case PinPriority.high:
        return Colors.orange;
      case PinPriority.urgent:
        return Colors.red;
    }
  }
}
