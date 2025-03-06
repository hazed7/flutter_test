import 'package:flutter/material.dart';

import '../../../domain/models/pin.dart';

/// A chart showing the distribution of pin types
class PinTypeDistribution extends StatelessWidget {
  /// Constructor
  const PinTypeDistribution({
    super.key,
    required this.typeCounts,
    required this.theme,
  });

  /// Map of pin types to counts
  final Map<PinType, int> typeCounts;

  /// The current theme
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    if (typeCounts.isEmpty) {
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
        typeCounts.values.fold<int>(0, (sum, count) => sum + count);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart title
        Text(
          'Pin Types',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Pie chart
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.maxHeight < constraints.maxWidth
                  ? constraints.maxHeight
                  : constraints.maxWidth;

              return Row(
                children: [
                  // Pie chart
                  SizedBox(
                    width: size,
                    height: size,
                    child: CustomPaint(
                      painter: _PieChartPainter(
                        typeCounts: typeCounts,
                        totalPins: totalPins,
                        theme: theme,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Legend
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: PinType.values.map((type) {
                        final count = typeCounts[type] ?? 0;
                        final percentage = totalPins > 0
                            ? (count / totalPins * 100).toStringAsFixed(1)
                            : '0.0';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getColorForType(type),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  type.displayName,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              Text(
                                '$percentage%',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  /// Get a color for a pin type
  Color _getColorForType(PinType type) {
    switch (type) {
      case PinType.note:
        return Colors.blue;
      case PinType.task:
        return Colors.green;
      case PinType.image:
        return Colors.purple;
      case PinType.link:
        return Colors.orange;
    }
  }
}

/// Custom painter for the pie chart
class _PieChartPainter extends CustomPainter {
  _PieChartPainter({
    required this.typeCounts,
    required this.totalPins,
    required this.theme,
  });

  final Map<PinType, int> typeCounts;
  final int totalPins;
  final ThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width < size.height ? size.width / 2 : size.height / 2;

    // Draw background circle if empty
    if (totalPins == 0) {
      final paint = Paint()
        ..color = theme.colorScheme.surfaceContainerHighest
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, paint);
      return;
    }

    // Draw pie segments
    var startAngle = -90 * (3.14159 / 180); // Start from top (in radians)

    for (final type in PinType.values) {
      final count = typeCounts[type] ?? 0;
      if (count == 0) continue;

      final sweepAngle = (count / totalPins) * 2 * 3.14159;

      final paint = Paint()
        ..color = _getColorForType(type)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Draw center circle for donut effect
    final centerPaint = Paint()
      ..color = theme.colorScheme.surface
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.6, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  /// Get a color for a pin type
  Color _getColorForType(PinType type) {
    switch (type) {
      case PinType.note:
        return Colors.blue;
      case PinType.task:
        return Colors.green;
      case PinType.image:
        return Colors.purple;
      case PinType.link:
        return Colors.orange;
    }
  }
}
