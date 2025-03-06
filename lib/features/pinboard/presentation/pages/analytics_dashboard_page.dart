import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/app_window_title_bar.dart';
import '../../domain/models/pin.dart';
import '../providers/pin_providers.dart';
import '../widgets/analytics/activity_heatmap.dart';
import '../widgets/analytics/pin_type_distribution.dart';
import '../widgets/analytics/priority_distribution.dart';
import '../widgets/analytics/tag_usage_chart.dart';

/// Analytics Dashboard Page
class AnalyticsDashboardPage extends ConsumerWidget {
  /// Constructor
  const AnalyticsDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pinsAsync = ref.watch(allPinsProvider);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App bar with back button
          AppWindowTitleBar(
            title: 'Analytics Dashboard',
            showBackButton: true,
            onBackPressed: () => context.go('/'),
          ),

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
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create some pins to see analytics',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Calculate analytics data
                final stats = _calculateStats(pins);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary cards
                      GridView.count(
                        crossAxisCount: 4,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap: true,
                        childAspectRatio: 2.0,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildSummaryCard(
                            theme,
                            'Total Pins',
                            '${stats.totalPins}',
                            Icons.push_pin,
                            theme.colorScheme.primary,
                          ),
                          _buildSummaryCard(
                            theme,
                            'Total Tags',
                            '${stats.uniqueTags.length}',
                            Icons.tag,
                            theme.colorScheme.secondary,
                          ),
                          _buildSummaryCard(
                            theme,
                            'Created This Month',
                            '${stats.createdThisMonth}',
                            Icons.calendar_today,
                            theme.colorScheme.tertiary,
                          ),
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

                      // Activity heatmap section
                      _buildSectionHeader(
                          theme, 'Activity Over Time', Icons.timeline),
                      const SizedBox(height: 16),
                      Container(
                        height: 80,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                            width: 1,
                          ),
                        ),
                        child: ActivityHeatmap(
                          pins: pins,
                          theme: theme,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Distribution charts section
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pin type distribution
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader(
                                    theme, 'Pin Types', Icons.category),
                                const SizedBox(height: 16),
                                Container(
                                  height: 300,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color:
                                        theme.colorScheme.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: theme.colorScheme.outlineVariant,
                                      width: 1,
                                    ),
                                  ),
                                  child: PinTypeDistribution(
                                    typeCounts: stats.typeCounts,
                                    theme: theme,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Priority distribution
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader(
                                    theme, 'Priority Distribution', Icons.flag),
                                const SizedBox(height: 16),
                                Container(
                                  height: 300,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color:
                                        theme.colorScheme.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: theme.colorScheme.outlineVariant,
                                      width: 1,
                                    ),
                                  ),
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

                      // Tag usage chart
                      _buildSectionHeader(theme, 'Tag Usage', Icons.tag),
                      const SizedBox(height: 16),
                      Container(
                        height: 300,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                            width: 1,
                          ),
                        ),
                        child: TagUsageChart(
                          tagCounts: stats.tagCounts,
                          theme: theme,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Most used tags
                      _buildSectionHeader(
                          theme, 'Most Used Tags', Icons.trending_up),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                            width: 1,
                          ),
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: stats.tagCounts.entries
                              .take(20)
                              .map((entry) =>
                                  _buildTagChip(theme, entry.key, entry.value))
                              .toList(),
                        ),
                      ),

                      const SizedBox(height: 32),
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
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(ThemeData theme, String title, String value,
      IconData icon, Color iconColor) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                fontSize: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(ThemeData theme, String tag, int count) {
    return Chip(
      label: Text('#$tag ($count)'),
      backgroundColor: theme.colorScheme.secondaryContainer,
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSecondaryContainer,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }

  /// Calculate statistics from pins
  AnalyticsStats _calculateStats(List<Pin> pins) {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);

    // Count pins created this month
    final createdThisMonth = pins.where((pin) {
      final createdDate = DateTime(
        pin.createdAt.year,
        pin.createdAt.month,
      );
      return createdDate.isAtSameMomentAs(thisMonth);
    }).length;

    // Count pins by type
    final typeCounts = <PinType, int>{};
    for (final type in PinType.values) {
      typeCounts[type] = pins.where((pin) => pin.type == type).length;
    }

    // Count pins by priority
    final priorityCounts = <PinPriority, int>{};
    for (final priority in PinPriority.values) {
      priorityCounts[priority] =
          pins.where((pin) => pin.priority == priority).length;
    }

    // Count tag usage
    final tagCounts = <String, int>{};
    final allTags = <String>[];
    for (final pin in pins) {
      for (final tag in pin.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
        allTags.add(tag);
      }
    }

    // Sort tag counts by frequency (descending)
    final sortedTagCounts = Map.fromEntries(
      tagCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );

    // Calculate average tags per pin
    final avgTagsPerPin =
        pins.isEmpty ? 0.0 : allTags.length / pins.length.toDouble();

    return AnalyticsStats(
      totalPins: pins.length,
      createdThisMonth: createdThisMonth,
      typeCounts: typeCounts,
      priorityCounts: priorityCounts,
      tagCounts: sortedTagCounts,
      uniqueTags: tagCounts.keys.toSet(),
      avgTagsPerPin: avgTagsPerPin,
    );
  }
}

/// Class to hold analytics statistics
class AnalyticsStats {
  /// Constructor
  AnalyticsStats({
    required this.totalPins,
    required this.createdThisMonth,
    required this.typeCounts,
    required this.priorityCounts,
    required this.tagCounts,
    required this.uniqueTags,
    required this.avgTagsPerPin,
  });

  /// Total number of pins
  final int totalPins;

  /// Number of pins created this month
  final int createdThisMonth;

  /// Count of pins by type
  final Map<PinType, int> typeCounts;

  /// Count of pins by priority
  final Map<PinPriority, int> priorityCounts;

  /// Count of tag usage
  final Map<String, int> tagCounts;

  /// Set of unique tags
  final Set<String> uniqueTags;

  /// Average number of tags per pin
  final double avgTagsPerPin;
}
