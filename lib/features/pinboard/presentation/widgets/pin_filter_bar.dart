import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/pin.dart';
import '../providers/pin_providers.dart';
import 'advanced_filter/advanced_filter_dialog.dart';
import 'view_mode_toggle.dart';

/// Filter bar for filtering pins by type, priority, and other attributes
class PinFilterBar extends ConsumerWidget {
  /// Constructor
  const PinFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedFilterType = ref.watch(filterTypeProvider);
    final selectedFilterTag = ref.watch(filterTagProvider);
    final selectedFilterPriority = ref.watch(filterPriorityProvider);
    final showArchived = ref.watch(showArchivedProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Active filters
        if (selectedFilterType != null ||
            selectedFilterTag != null ||
            selectedFilterPriority != null ||
            showArchived)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Text(
                  'Active Filters:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),

                // Type filter chip
                if (selectedFilterType != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(selectedFilterType.displayName),
                      selected: true,
                      onSelected: (_) {
                        ref.read(filterTypeProvider.notifier).state = null;
                      },
                      avatar:
                          Icon(_getIconForType(selectedFilterType), size: 16),
                    ),
                  ),

                // Priority filter chip
                if (selectedFilterPriority != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(selectedFilterPriority.displayName),
                      selected: true,
                      onSelected: (_) {
                        ref.read(filterPriorityProvider.notifier).state = null;
                      },
                      avatar: const Icon(Icons.priority_high, size: 16),
                      backgroundColor:
                          _getColorForPriority(selectedFilterPriority, theme),
                    ),
                  ),

                // Tag filter chip
                if (selectedFilterTag != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text('#$selectedFilterTag'),
                      selected: true,
                      onSelected: (_) {
                        ref.read(filterTagProvider.notifier).state = null;
                      },
                      avatar: const Icon(Icons.tag, size: 16),
                    ),
                  ),

                // Archived filter chip
                if (showArchived)
                  FilterChip(
                    label: const Text('Archived'),
                    selected: true,
                    onSelected: (_) {
                      ref.read(showArchivedProvider.notifier).state = false;
                    },
                    avatar: const Icon(Icons.archive, size: 16),
                  ),
              ],
            ),
          ),

        // Filter options
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sort dropdown - Moved here from pinboard_page.dart
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Text(
                          'Sort by:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: ref.watch(pinSortTypeProvider),
                              icon: const Icon(Icons.sort),
                              isDense: true,
                              borderRadius: BorderRadius.circular(8),
                              items: const [
                                DropdownMenuItem(
                                  value: 'date_desc',
                                  child: Text('Newest first'),
                                ),
                                DropdownMenuItem(
                                  value: 'date_asc',
                                  child: Text('Oldest first'),
                                ),
                                DropdownMenuItem(
                                  value: 'priority_desc',
                                  child: Text('Highest priority'),
                                ),
                                DropdownMenuItem(
                                  value: 'priority_asc',
                                  child: Text('Lowest priority'),
                                ),
                                DropdownMenuItem(
                                  value: 'title_asc',
                                  child: Text('Title A-Z'),
                                ),
                                DropdownMenuItem(
                                  value: 'title_desc',
                                  child: Text('Title Z-A'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  ref.read(pinSortTypeProvider.notifier).state =
                                      value;
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Type filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // All types
                        FilterChip(
                          label: const Text('All Types'),
                          selected: selectedFilterType == null,
                          onSelected: (_) {
                            ref.read(filterTypeProvider.notifier).state = null;
                          },
                          avatar: const Icon(Icons.all_inclusive, size: 16),
                        ),
                        const SizedBox(width: 8),

                        // Type filters
                        ...PinType.values.map((type) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(type.displayName),
                              selected: selectedFilterType == type,
                              onSelected: (_) {
                                ref.read(filterTypeProvider.notifier).state =
                                    selectedFilterType == type ? null : type;
                              },
                              avatar: Icon(_getIconForType(type), size: 16),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Priority filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // All priorities
                        FilterChip(
                          label: const Text('All Priorities'),
                          selected: selectedFilterPriority == null,
                          onSelected: (_) {
                            ref.read(filterPriorityProvider.notifier).state =
                                null;
                          },
                          avatar: const Icon(Icons.all_inclusive, size: 16),
                        ),
                        const SizedBox(width: 8),

                        // Priority filters
                        ...PinPriority.values.map((priority) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(priority.displayName),
                              selected: selectedFilterPriority == priority,
                              onSelected: (_) {
                                ref
                                        .read(filterPriorityProvider.notifier)
                                        .state =
                                    selectedFilterPriority == priority
                                        ? null
                                        : priority;
                              },
                              avatar: const Icon(Icons.priority_high, size: 16),
                              backgroundColor:
                                  _getColorForPriority(priority, theme),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Advanced filter and analytics
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Advanced filter button
                        OutlinedButton.icon(
                          icon: const Icon(Icons.filter_list),
                          label: const Text('Advanced Filters'),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  const AdvancedFilterDialog(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // View options
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // View mode toggle
                const ViewModeToggle(),

                const SizedBox(height: 8),

                // Archive toggle
                FilterChip(
                  label: const Text('Show Archived'),
                  selected: showArchived,
                  onSelected: (value) {
                    ref.read(showArchivedProvider.notifier).state = value;
                  },
                  avatar: const Icon(Icons.archive, size: 16),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  IconData _getIconForType(PinType type) {
    switch (type) {
      case PinType.note:
        return Icons.note;
      case PinType.task:
        return Icons.task_alt;
      case PinType.image:
        return Icons.image;
      case PinType.link:
        return Icons.link;
    }
  }

  Color _getColorForPriority(PinPriority priority, ThemeData theme) {
    switch (priority) {
      case PinPriority.low:
        return Colors.blue.withOpacity(0.2);
      case PinPriority.medium:
        return Colors.green.withOpacity(0.2);
      case PinPriority.high:
        return Colors.orange.withOpacity(0.2);
      case PinPriority.urgent:
        return Colors.red.withOpacity(0.2);
    }
  }
}
