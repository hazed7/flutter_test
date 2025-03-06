import 'package:flutter/material.dart';

/// A reusable widget for displaying a group of filter chips
class FilterChipGroup<T> extends StatelessWidget {
  /// Constructor
  const FilterChipGroup({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.getLabel,
    required this.getIcon,
    required this.getColor,
    required this.onSelectionChanged,
  });

  /// The items to display
  final List<T> items;

  /// The currently selected items
  final Set<T> selectedItems;

  /// Function to get the label for an item
  final String Function(T item) getLabel;

  /// Function to get the icon for an item
  final IconData Function(T item) getIcon;

  /// Function to get the color for an item
  final Color Function(T item) getColor;

  /// Callback when the selection changes
  final void Function(Set<T> selectedItems) onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = selectedItems.contains(item);
        final color = getColor(item);

        return FilterChip(
          label: Text(getLabel(item)),
          selected: isSelected,
          onSelected: (selected) {
            final newSelection = Set<T>.from(selectedItems);
            if (selected) {
              newSelection.add(item);
            } else {
              newSelection.remove(item);
            }
            onSelectionChanged(newSelection);
          },
          selectedColor: color.withOpacity(0.2),
          checkmarkColor: color,
          avatar: Icon(
            getIcon(item),
            size: 16,
            color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
          ),
          labelStyle: theme.textTheme.labelMedium?.copyWith(
            color: isSelected ? color : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}
