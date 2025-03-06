import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/pin.dart';
import '../../providers/pin_providers.dart';

/// Component for displaying pin tags
class PinDetailTags extends ConsumerWidget {
  /// Constructor
  const PinDetailTags({
    super.key,
    required this.pin,
    required this.theme,
  });

  /// The pin to display
  final Pin pin;

  /// The current theme
  final ThemeData theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (pin.tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),

        // Section header with animation
        Row(
          children: [
            Icon(
              Icons.tag,
              size: 18,
              color: theme.colorScheme.primary.withOpacity(0.8),
            ),
            const SizedBox(width: 8),
            Text(
              'Tags',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),

            // Add tag button
            _buildAddTagButton(context, ref),
          ],
        ),

        const SizedBox(height: 12),

        // Tags with interactive elements
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              pin.tags.map((tag) => _buildTagChip(context, ref, tag)).toList(),
        ),
      ],
    );
  }

  Widget _buildTagChip(BuildContext context, WidgetRef ref, String tag) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 150),
        child: ActionChip(
          label: Text('#$tag'),
          backgroundColor:
              theme.colorScheme.secondaryContainer.withOpacity(0.4),
          labelStyle: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.w500,
          ),
          side: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
          elevation: 0,
          pressElevation: 2,
          shadowColor: theme.colorScheme.shadow.withOpacity(0.2),
          avatar: Icon(
            Icons.tag,
            size: 16,
            color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7),
          ),
          onPressed: () {
            // Filter by this tag
            ref.read(filterTagProvider.notifier).state = tag;

            // Close the detail view
            ref.read(selectedPinIdProvider.notifier).state = null;
          },
          tooltip: 'Filter by tag: $tag',
        ),
      ),
    );
  }

  Widget _buildAddTagButton(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: 'Add or remove tags',
      child: TextButton.icon(
        icon: Icon(Icons.edit, size: 16, color: theme.colorScheme.primary),
        label: Text(
          'Manage Tags',
          style: TextStyle(color: theme.colorScheme.primary),
        ),
        style: TextButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          visualDensity: VisualDensity.compact,
          textStyle: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        onPressed: () {
          // Show tag management dialog
          showDialog(
            context: context,
            builder: (context) => _TagManagementDialog(pin: pin),
          );
        },
      ),
    );
  }
}

/// Dialog for managing tags
class _TagManagementDialog extends ConsumerStatefulWidget {
  const _TagManagementDialog({required this.pin});

  final Pin pin;

  @override
  ConsumerState<_TagManagementDialog> createState() =>
      _TagManagementDialogState();
}

class _TagManagementDialogState extends ConsumerState<_TagManagementDialog> {
  late List<String> _selectedTags;
  final _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedTags = List.from(widget.pin.tags);
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allTags = ref.watch(allTagsProvider);

    return AlertDialog(
      title: const Text('Manage Tags'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add new tag field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: InputDecoration(
                      labelText: 'New Tag',
                      hintText: 'Enter a new tag',
                      prefixIcon:
                          Icon(Icons.add, color: theme.colorScheme.primary),
                    ),
                    onSubmitted: _addNewTag,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.add_circle,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  onPressed: () => _addNewTag(_tagController.text),
                  tooltip: 'Add Tag',
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              'Available Tags:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),

            // Available tags with selection
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
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          icon: Icon(
            Icons.save,
            color: theme.colorScheme.onPrimary,
          ),
          label: Text(
            'Save',
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: _saveTags,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: 2,
          ),
        ),
      ],
    );
  }

  void _addNewTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && !_selectedTags.contains(trimmedTag)) {
      setState(() {
        _selectedTags.add(trimmedTag);
        _tagController.clear();
      });

      // Add to repository if it's a new tag
      if (!ref.read(allTagsProvider).contains(trimmedTag)) {
        final tagRepository = ref.read(tagRepositoryProvider);
        tagRepository.createTag(trimmedTag);
      }
    }
  }

  void _saveTags() {
    // Update the pin with new tags
    final repository = ref.read(pinRepositoryProvider);
    repository.updatePin(widget.pin.copyWith(
      tags: _selectedTags,
      updatedAt: DateTime.now(),
    ));

    Navigator.of(context).pop();
  }
}
