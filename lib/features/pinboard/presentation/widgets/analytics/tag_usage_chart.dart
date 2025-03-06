import 'package:flutter/material.dart';

/// A chart showing tag usage frequency
class TagUsageChart extends StatelessWidget {
  /// Constructor
  const TagUsageChart({
    super.key,
    required this.tagCounts,
    required this.theme,
  });

  /// Map of tag names to usage counts
  final Map<String, int> tagCounts;

  /// The current theme
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    if (tagCounts.isEmpty) {
      return Center(
        child: Text(
          'No tags available',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    // Get top tags (limited to 10)
    final topTags = tagCounts.entries.take(10).toList();

    // Find the maximum count for scaling
    final maxCount =
        topTags.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final barHeight = 24.0;
        final spacing = 16.0;
        final maxBarWidth =
            availableWidth * 0.7; // 70% of available width for bars

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart title
            Text(
              'Most Used Tags',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Chart bars
            Expanded(
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topTags.length,
                separatorBuilder: (_, __) => SizedBox(height: spacing),
                itemBuilder: (context, index) {
                  final entry = topTags[index];
                  final tag = entry.key;
                  final count = entry.value;

                  // Calculate bar width based on count
                  final barWidth = (count / maxCount) * maxBarWidth;

                  return Row(
                    children: [
                      // Tag name
                      SizedBox(
                        width: availableWidth * 0.25, // 25% for tag name
                        child: Text(
                          tag,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Bar
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutQuad,
                        height: barHeight,
                        width: barWidth,
                        decoration: BoxDecoration(
                          color: _getColorForIndex(index),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Count
                      Text(
                        '$count',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Get a color for the bar based on its index
  Color _getColorForIndex(int index) {
    final baseColor = theme.colorScheme.primary;

    // Create a gradient of colors based on index
    final hslColor = HSLColor.fromColor(baseColor);
    final adjustedColor = hslColor
        .withLightness(
          (hslColor.lightness - 0.05 * (index % 3)).clamp(0.3, 0.7),
        )
        .withSaturation(
          (hslColor.saturation - 0.05 * (index ~/ 3)).clamp(0.4, 0.8),
        )
        .toColor();

    return adjustedColor;
  }
}
