import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/pin.dart';
import '../providers/collection_providers.dart';
import '../providers/pin_providers.dart';
import 'collection_list.dart';

/// Sidebar for the pinboard app
class PinSidebar extends ConsumerStatefulWidget {
  /// Constructor
  const PinSidebar({super.key});

  @override
  ConsumerState<PinSidebar> createState() => _PinSidebarState();
}

class _PinSidebarState extends ConsumerState<PinSidebar> {
  bool _isTypesExpanded = true;
  bool _isTagsExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedFilterType = ref.watch(filterTypeProvider);
    final selectedFilterTag = ref.watch(filterTagProvider);
    final selectedCollectionId = ref.watch(selectedCollectionIdProvider);
    final allTags = ref.watch(allTagsProvider);
    final showArchived = ref.watch(showArchivedProvider);

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Pinboard',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const Divider(height: 1),

          // Navigation items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // All pins with archive toggle
                ListTile(
                  leading: const Icon(Icons.dashboard_outlined),
                  title: const Text('All Pins'),
                  selected: selectedFilterType == null &&
                      selectedFilterTag == null &&
                      selectedCollectionId == null,
                  selectedTileColor:
                      theme.colorScheme.primaryContainer.withOpacity(0.2),
                  onTap: () {
                    ref.read(filterTypeProvider.notifier).state = null;
                    ref.read(filterTagProvider.notifier).state = null;
                    ref.read(selectedCollectionIdProvider.notifier).state =
                        null;
                  },
                  trailing: IconButton(
                    icon: Icon(
                      showArchived ? Icons.visibility : Icons.visibility_off,
                      size: 18,
                    ),
                    tooltip: showArchived ? 'Hide Archived' : 'Show Archived',
                    onPressed: () {
                      ref.read(showArchivedProvider.notifier).state =
                          !showArchived;
                    },
                  ),
                  dense: true,
                  visualDensity: VisualDensity.compact,
                ),

                // Analytics dashboard
                ListTile(
                  leading: const Icon(Icons.analytics_outlined),
                  title: const Text('Analytics'),
                  onTap: () {
                    context.go('/analytics');
                  },
                  dense: true,
                  visualDensity: VisualDensity.compact,
                ),

                const Divider(),

                // Pin types section
                _buildSectionHeader(
                  context,
                  'TYPES',
                  _isTypesExpanded,
                  () => setState(() => _isTypesExpanded = !_isTypesExpanded),
                ),

                if (_isTypesExpanded) ...[
                  // Notes
                  _buildNavItem(
                    context,
                    ref,
                    icon: Icons.note_outlined,
                    label: 'Notes',
                    isSelected: selectedFilterType == PinType.note &&
                        selectedCollectionId == null,
                    onTap: () {
                      ref.read(selectedCollectionIdProvider.notifier).state =
                          null;
                      ref.read(filterTypeProvider.notifier).state =
                          selectedFilterType == PinType.note
                              ? null
                              : PinType.note;
                    },
                  ),

                  // Tasks
                  _buildNavItem(
                    context,
                    ref,
                    icon: Icons.task_alt_outlined,
                    label: 'Tasks',
                    isSelected: selectedFilterType == PinType.task &&
                        selectedCollectionId == null,
                    onTap: () {
                      ref.read(selectedCollectionIdProvider.notifier).state =
                          null;
                      ref.read(filterTypeProvider.notifier).state =
                          selectedFilterType == PinType.task
                              ? null
                              : PinType.task;
                    },
                  ),

                  // Images
                  _buildNavItem(
                    context,
                    ref,
                    icon: Icons.image_outlined,
                    label: 'Images',
                    isSelected: selectedFilterType == PinType.image &&
                        selectedCollectionId == null,
                    onTap: () {
                      ref.read(selectedCollectionIdProvider.notifier).state =
                          null;
                      ref.read(filterTypeProvider.notifier).state =
                          selectedFilterType == PinType.image
                              ? null
                              : PinType.image;
                    },
                  ),

                  // Links
                  _buildNavItem(
                    context,
                    ref,
                    icon: Icons.link_outlined,
                    label: 'Links',
                    isSelected: selectedFilterType == PinType.link &&
                        selectedCollectionId == null,
                    onTap: () {
                      ref.read(selectedCollectionIdProvider.notifier).state =
                          null;
                      ref.read(filterTypeProvider.notifier).state =
                          selectedFilterType == PinType.link
                              ? null
                              : PinType.link;
                    },
                  ),
                ],

                const Divider(),

                // Collections section - use the existing CollectionList
                const CollectionList(),

                const Divider(),

                // Tags section
                _buildSectionHeader(
                  context,
                  'TAGS',
                  _isTagsExpanded,
                  () => setState(() => _isTagsExpanded = !_isTagsExpanded),
                  hasAddButton: true,
                  onAddPressed: () {
                    // Show create tag dialog
                    _showCreateTagDialog(context, ref);
                  },
                ),

                if (_isTagsExpanded) ...[
                  if (allTags.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Text(
                        'No tags yet. Create one by clicking the + button.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  else
                    ...allTags.map((tag) => _buildTagItem(context, ref, tag)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    bool isExpanded,
    VoidCallback onToggle, {
    bool hasAddButton = false,
    VoidCallback? onAddPressed,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding:
          const EdgeInsets.only(left: 16.0, right: 8.0, top: 8.0, bottom: 8.0),
      child: Row(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(4),
            child: Row(
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
          const Spacer(),
          if (hasAddButton)
            IconButton(
              icon: const Icon(Icons.add, size: 16),
              onPressed: onAddPressed,
              visualDensity: VisualDensity.compact,
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              tooltip:
                  'Add ${title.toLowerCase().substring(0, title.length - 1)}',
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(0.2),
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildTagItem(BuildContext context, WidgetRef ref, String tag) {
    final theme = Theme.of(context);
    final selectedFilterTag = ref.watch(filterTagProvider);
    final isSelected = selectedFilterTag == tag;

    return ListTile(
      leading: const Icon(Icons.tag, size: 18),
      title: Text(
        '#$tag',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(0.2),
      onTap: () {
        ref.read(filterTagProvider.notifier).state = isSelected ? null : tag;
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 16),
            onPressed: () => _showEditTagDialog(context, ref, tag),
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            tooltip: 'Edit tag',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 16),
            onPressed: () => _showDeleteTagConfirmation(context, ref, tag),
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            tooltip: 'Delete tag',
          ),
        ],
      ),
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  void _showCreateTagDialog(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();
    String selectedColor = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create New Tag'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      labelText: 'Tag Name',
                      hintText: 'Enter tag name',
                    ),
                    autofocus: true,
                  ),

                  const SizedBox(height: 16),

                  // Color selector
                  const Text('Color (optional)'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildColorOption(context, '', selectedColor, (color) {
                        setState(() => selectedColor = color);
                      }),
                      _buildColorOption(context, 'f44336', selectedColor,
                          (color) {
                        setState(() => selectedColor = color);
                      }),
                      _buildColorOption(context, '2196f3', selectedColor,
                          (color) {
                        setState(() => selectedColor = color);
                      }),
                      _buildColorOption(context, '4caf50', selectedColor,
                          (color) {
                        setState(() => selectedColor = color);
                      }),
                      _buildColorOption(context, 'ffeb3b', selectedColor,
                          (color) {
                        setState(() => selectedColor = color);
                      }),
                      _buildColorOption(context, '9c27b0', selectedColor,
                          (color) {
                        setState(() => selectedColor = color);
                      }),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final tagName = textController.text.trim();
                    if (tagName.isNotEmpty) {
                      // Create the tag using the tag repository
                      ref.read(tagRepositoryProvider).createTag(
                            tagName,
                            color: selectedColor,
                          );
                      Navigator.of(context).pop();

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Tag "$tagName" created successfully'),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditTagDialog(BuildContext context, WidgetRef ref, String tag) {
    final textController = TextEditingController(text: tag);
    String selectedColor = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Tag'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      labelText: 'Tag Name',
                      hintText: 'Enter tag name',
                    ),
                    autofocus: true,
                  ),

                  const SizedBox(height: 16),

                  // Color selector
                  const Text('Color (optional)'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildColorOption(context, '', selectedColor, (color) {
                        setState(() => selectedColor = color);
                      }),
                      _buildColorOption(context, 'f44336', selectedColor,
                          (color) {
                        setState(() => selectedColor = color);
                      }),
                      _buildColorOption(context, '2196f3', selectedColor,
                          (color) {
                        setState(() => selectedColor = color);
                      }),
                      _buildColorOption(context, '4caf50', selectedColor,
                          (color) {
                        setState(() => selectedColor = color);
                      }),
                      _buildColorOption(context, 'ffeb3b', selectedColor,
                          (color) {
                        setState(() => selectedColor = color);
                      }),
                      _buildColorOption(context, '9c27b0', selectedColor,
                          (color) {
                        setState(() => selectedColor = color);
                      }),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final newTagName = textController.text.trim();
                    if (newTagName.isNotEmpty && newTagName != tag) {
                      // Rename the tag using the tag repository
                      await ref
                          .read(tagRepositoryProvider)
                          .renameTag(tag, newTagName);
                      if (context.mounted) Navigator.of(context).pop();
                    } else if (selectedColor.isNotEmpty) {
                      // Just update the color
                      final pinsWithTag = await ref
                          .read(pinRepositoryProvider)
                          .getPinsByTag(tag);

                      // Update the color in each pin
                      for (final pin in pinsWithTag) {
                        final updatedPin = pin.copyWith(
                          color: selectedColor,
                        );
                        await ref
                            .read(pinRepositoryProvider)
                            .updatePin(updatedPin);
                      }

                      if (context.mounted) Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteTagConfirmation(
      BuildContext context, WidgetRef ref, String tag) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Tag'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to delete the tag "#$tag"?'),
              const SizedBox(height: 16),
              Text(
                'This will remove the tag from all pins.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Would you like to keep this tag in the system even if no pins are using it?',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Delete the tag using the tag repository
                await ref.read(tagRepositoryProvider).deleteTag(tag);

                // Remove from persistent tags
                ref.read(persistentTagsProvider.notifier).update((state) {
                  final newState = Set<String>.from(state);
                  newState.remove(tag);
                  return newState;
                });

                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Delete Completely'),
            ),
            FilledButton(
              onPressed: () async {
                // Remove tag from pins but keep it in the system
                await ref.read(tagRepositoryProvider).deleteTag(tag);

                // Keep in persistent tags
                ref.read(persistentTagsProvider.notifier).update((state) {
                  return {...state, tag};
                });

                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Keep Tag'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildColorOption(
    BuildContext context,
    String colorHex,
    String selectedColorHex,
    Function(String) onSelected,
  ) {
    final theme = Theme.of(context);
    final isSelected = colorHex == selectedColorHex;

    Color getColor() {
      if (colorHex.isEmpty) {
        return theme.colorScheme.surface;
      }
      return Color(int.parse(colorHex, radix: 16) | 0xFF000000);
    }

    return InkWell(
      onTap: () => onSelected(colorHex),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: getColor(),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                size: 16,
                color:
                    colorHex.isEmpty ? theme.colorScheme.primary : Colors.white,
              )
            : null,
      ),
    );
  }
}
