import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/pin.dart';
import '../../providers/pin_providers.dart';
import 'activity_heatmap.dart';
import 'pin_type_distribution.dart';
import 'priority_distribution.dart';
import 'tag_usage_chart.dart';

/// Dialog for displaying analytics dashboard
class AnalyticsDashboard extends ConsumerWidget {
  /// Constructor
  const AnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pinsAsync = ref.watch(allPinsProvider);

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      elevation: 8,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 1000,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Text(
                  'Analytics Dashboard',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Dashboard content
            Expanded(
              child: pinsAsync.when(
                data: (pins) {
                  if (pins.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No data available',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create some pins to see analytics',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Calculate analytics data
                  final stats = _calculateStats(pins);

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary cards
                        Row(
                          children: [
                            _buildSummaryCard(
                              theme,
                              'Total Pins',
                              '${stats.totalPins}',
                              Icons.push_pin,
                              theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 16),
                            _buildSummaryCard(
                              theme,
                              'Total Tags',
                              '${stats.uniqueTags.length}',
                              Icons.tag,
                              theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 16),
                            _buildSummaryCard(
                              theme,
                              'Created This Month',
                              '${stats.createdThisMonth}',
                              Icons.calendar_today,
                              theme.colorScheme.tertiary,
                            ),
                            const SizedBox(width: 16),
                            _buildSummaryCard(
                              theme,
                              'Avg. Tags Per Pin',
                              stats.avgTagsPerPin.toStringAsFixed(1),
                              Icons.analytics,
                              theme.colorScheme.error,
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Charts section
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left column
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionHeader(theme,
                                      'Activity Over Time', Icons.timeline),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 200,
                                    child: ActivityHeatmap(
                                      pins: pins,
                                      theme: theme,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  _buildSectionHeader(
                                      theme, 'Tag Usage', Icons.tag),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 200,
                                    child: TagUsageChart(
                                      tagCounts: stats.tagCounts,
                                      theme: theme,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 24),

                            // Right column
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionHeader(
                                      theme, 'Pin Types', Icons.category),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 200,
                                    child: PinTypeDistribution(
                                      typeCounts: stats.typeCounts,
                                      theme: theme,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  _buildSectionHeader(theme,
                                      'Priority Distribution', Icons.flag),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 200,
                                    child: PriorityDistribution(
                                      priorityCounts: stats.priorityCounts,
                                      theme: theme,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Most used tags
                        _buildSectionHeader(
                            theme, 'Most Used Tags', Icons.trending_up),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: stats.tagCounts.entries
                              .take(15)
                              .map((entry) =>
                                  _buildTagChip(theme, entry.key, entry.value))
                              .toList(),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (_, __) => Center(
                  child: Text(
                    'Error loading analytics data',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: color,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(ThemeData theme, String tag, int count) {
    return Chip(
      label: Text('#$tag'),
      avatar: CircleAvatar(
        backgroundColor: theme.colorScheme.primary,
        radius: 12,
        child: Text(
          '$count',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(0.4),
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.onSecondaryContainer,
        fontWeight: FontWeight.w500,
      ),
      side: BorderSide(
        color: theme.colorScheme.outline.withOpacity(0.2),
        width: 1,
      ),
    );
  }

  _AnalyticsStats _calculateStats(List<Pin> pins) {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);

    // Count pins created this month
    final createdThisMonth = pins.where((pin) {
      final created = pin.createdAt;
      return created.year == thisMonth.year && created.month == thisMonth.month;
    }).length;

    // Count tags
    final tagCounts = <String, int>{};
    final typeCounts = <PinType, int>{};
    final priorityCounts = <PinPriority, int>{};

    for (final pin in pins) {
      // Count tags
      for (final tag in pin.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }

      // Count types
      typeCounts[pin.type] = (typeCounts[pin.type] ?? 0) + 1;

      // Count priorities
      priorityCounts[pin.priority] = (priorityCounts[pin.priority] ?? 0) + 1;
    }

    // Sort tag counts by frequency (descending)
    final sortedTagCounts = Map.fromEntries(
      tagCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );

    // Calculate average tags per pin
    final totalTags = pins.fold<int>(0, (sum, pin) => sum + pin.tags.length);
    final avgTagsPerPin = pins.isEmpty ? 0.0 : totalTags / pins.length;

    return _AnalyticsStats(
      totalPins: pins.length,
      createdThisMonth: createdThisMonth,
      uniqueTags: tagCounts.keys.toSet(),
      tagCounts: sortedTagCounts,
      typeCounts: typeCounts,
      priorityCounts: priorityCounts,
      avgTagsPerPin: avgTagsPerPin,
    );
  }
}

class _AnalyticsStats {
  final int totalPins;
  final int createdThisMonth;
  final Set<String> uniqueTags;
  final Map<String, int> tagCounts;
  final Map<PinType, int> typeCounts;
  final Map<PinPriority, int> priorityCounts;
  final double avgTagsPerPin;

  _AnalyticsStats({
    required this.totalPins,
    required this.createdThisMonth,
    required this.uniqueTags,
    required this.tagCounts,
    required this.typeCounts,
    required this.priorityCounts,
    required this.avgTagsPerPin,
  });
}
