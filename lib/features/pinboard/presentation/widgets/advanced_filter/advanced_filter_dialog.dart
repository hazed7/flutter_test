import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/pin.dart';
import '../../providers/pin_providers.dart';
import 'filter_chip_group.dart';

/// Provider for advanced filter settings
final advancedFilterProvider = StateProvider<AdvancedFilterSettings>((ref) {
  return const AdvancedFilterSettings();
});

/// Settings for advanced filtering
class AdvancedFilterSettings {
  /// Constructor
  const AdvancedFilterSettings({
    this.dateRange,
    this.priorities = const {},
    this.types = const {},
    this.tags = const {},
    this.isActive = false,
  });

  /// Date range for filtering
  final DateTimeRange? dateRange;

  /// Selected priorities for filtering
  final Set<PinPriority> priorities;

  /// Selected types for filtering
  final Set<PinType> types;

  /// Selected tags for filtering
  final Set<String> tags;

  /// Whether the advanced filter is active
  final bool isActive;

  /// Create a copy with updated values
  AdvancedFilterSettings copyWith({
    DateTimeRange? dateRange,
    Set<PinPriority>? priorities,
    Set<PinType>? types,
    Set<String>? tags,
    bool? isActive,
  }) {
    return AdvancedFilterSettings(
      dateRange: dateRange ?? this.dateRange,
      priorities: priorities ?? this.priorities,
      types: types ?? this.types,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Clear all filters
  AdvancedFilterSettings clear() {
    return const AdvancedFilterSettings();
  }
}

/// Dialog for advanced filtering options
class AdvancedFilterDialog extends ConsumerStatefulWidget {
  /// Constructor
  const AdvancedFilterDialog({super.key});

  @override
  ConsumerState<AdvancedFilterDialog> createState() =>
      _AdvancedFilterDialogState();
}

class _AdvancedFilterDialogState extends ConsumerState<AdvancedFilterDialog> {
  late DateTimeRange? _selectedDateRange;
  late Set<PinPriority> _selectedPriorities;
  late Set<PinType> _selectedTypes;
  late Set<String> _selectedTags;

  @override
  void initState() {
    super.initState();
    final currentSettings = ref.read(advancedFilterProvider);
    _selectedDateRange = currentSettings.dateRange;
    _selectedPriorities = Set.from(currentSettings.priorities);
    _selectedTypes = Set.from(currentSettings.types);
    _selectedTags = Set.from(currentSettings.tags);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allTags = ref.watch(allTagsProvider);
    final dateFormat = DateFormat('MMM d, yyyy');

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.filter_list, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Text('Advanced Filters'),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset filters',
            onPressed: _resetFilters,
          ),
        ],
      ),
      content: SizedBox(
        width: 600,
        height: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date range filter
              _buildSectionHeader(theme, 'Date Range', Icons.calendar_today),
              const SizedBox(height: 8),

              InkWell(
                onTap: () => _selectDateRange(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.date_range,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedDateRange != null
                              ? '${dateFormat.format(_selectedDateRange!.start)} - ${dateFormat.format(_selectedDateRange!.end)}'
                              : 'Select date range',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      if (_selectedDateRange != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () =>
                              setState(() => _selectedDateRange = null),
                          tooltip: 'Clear date range',
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Priority filter
              _buildSectionHeader(theme, 'Priority', Icons.flag),
              const SizedBox(height: 8),

              FilterChipGroup<PinPriority>(
                items: PinPriority.values,
                selectedItems: _selectedPriorities,
                getLabel: (priority) => priority.displayName,
                getIcon: (priority) => Icons.flag,
                getColor: (priority) {
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
                },
                onSelectionChanged: (priorities) {
                  setState(() => _selectedPriorities = priorities);
                },
              ),

              const SizedBox(height: 24),

              // Type filter
              _buildSectionHeader(theme, 'Type', Icons.category),
              const SizedBox(height: 8),

              FilterChipGroup<PinType>(
                items: PinType.values,
                selectedItems: _selectedTypes,
                getLabel: (type) => type.displayName,
                getIcon: (type) {
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
                },
                getColor: (type) => theme.colorScheme.primary,
                onSelectionChanged: (types) {
                  setState(() => _selectedTypes = types);
                },
              ),

              const SizedBox(height: 24),

              // Tags filter
              _buildSectionHeader(theme, 'Tags', Icons.tag),
              const SizedBox(height: 8),

              if (allTags.isEmpty)
                Text(
                  'No tags available',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allTags.map((tag) {
                    final isSelected = _selectedTags.contains(tag);
                    return FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTags.add(tag);
                          } else {
                            _selectedTags.remove(tag);
                          }
                        });
                      },
                      selectedColor: theme.colorScheme.primaryContainer,
                      checkmarkColor: theme.colorScheme.primary,
                      avatar: Icon(
                        Icons.tag,
                        size: 16,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          icon: const Icon(Icons.filter_list),
          label: const Text('Apply Filters'),
          onPressed: _applyFilters,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
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

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = _selectedDateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        );

    final newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                  onPrimary: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (newDateRange != null) {
      setState(() => _selectedDateRange = newDateRange);
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedDateRange = null;
      _selectedPriorities = {};
      _selectedTypes = {};
      _selectedTags = {};
    });
  }

  void _applyFilters() {
    final hasActiveFilters = _selectedDateRange != null ||
        _selectedPriorities.isNotEmpty ||
        _selectedTypes.isNotEmpty ||
        _selectedTags.isNotEmpty;

    ref.read(advancedFilterProvider.notifier).state = AdvancedFilterSettings(
      dateRange: _selectedDateRange,
      priorities: _selectedPriorities,
      types: _selectedTypes,
      tags: _selectedTags,
      isActive: hasActiveFilters,
    );

    Navigator.of(context).pop();
  }
}
