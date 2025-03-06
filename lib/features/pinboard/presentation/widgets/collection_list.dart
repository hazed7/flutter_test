import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/collection.dart';
import '../providers/collection_providers.dart';

/// Widget to display and manage collections
class CollectionList extends ConsumerWidget {
  /// Constructor
  const CollectionList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final collectionsAsync = ref.watch(allCollectionsProvider);
    final selectedCollectionId = ref.watch(selectedCollectionIdProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with add button
        Padding(
          padding: const EdgeInsets.only(
              left: 16.0, right: 8.0, top: 8.0, bottom: 8.0),
          child: Row(
            children: [
              Text(
                'COLLECTIONS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                onPressed: () => _showCreateCollectionDialog(context, ref),
                tooltip: 'Create Collection',
                visualDensity: VisualDensity.compact,
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),

        // Collections list
        collectionsAsync.when(
          data: (collections) {
            if (collections.isEmpty) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'No collections yet',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: collections.length,
              itemBuilder: (context, index) {
                final collection = collections[index];
                final isSelected = collection.id == selectedCollectionId;

                return _CollectionListItem(
                  collection: collection,
                  isSelected: isSelected,
                  onTap: () {
                    ref.read(selectedCollectionIdProvider.notifier).state =
                        isSelected ? null : collection.id;
                  },
                  onEdit: () =>
                      _showEditCollectionDialog(context, ref, collection),
                  onDelete: () =>
                      _showDeleteCollectionDialog(context, ref, collection),
                );
              },
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error loading collections',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCreateCollectionDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedIcon = 'folder';
    String selectedColor = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create Collection'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name field
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        hintText: 'Enter collection name',
                      ),
                      maxLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                    ),

                    const SizedBox(height: 16),

                    // Description field
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        hintText: 'Enter collection description',
                      ),
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                    ),

                    const SizedBox(height: 16),

                    // Icon selector
                    const Text('Icon'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildIconOption(context, 'folder', selectedIcon,
                            (icon) {
                          setState(() => selectedIcon = icon);
                        }),
                        _buildIconOption(context, 'work', selectedIcon, (icon) {
                          setState(() => selectedIcon = icon);
                        }),
                        _buildIconOption(context, 'favorite', selectedIcon,
                            (icon) {
                          setState(() => selectedIcon = icon);
                        }),
                        _buildIconOption(context, 'star', selectedIcon, (icon) {
                          setState(() => selectedIcon = icon);
                        }),
                        _buildIconOption(context, 'bookmark', selectedIcon,
                            (icon) {
                          setState(() => selectedIcon = icon);
                        }),
                        _buildIconOption(context, 'label', selectedIcon,
                            (icon) {
                          setState(() => selectedIcon = icon);
                        }),
                      ],
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
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Name cannot be empty'),
                        ),
                      );
                      return;
                    }

                    // Create new collection
                    final newCollection = Collection.create(
                      name: nameController.text.trim(),
                      description: descriptionController.text.trim(),
                      icon: selectedIcon,
                      color: selectedColor,
                    );

                    // Save collection
                    ref
                        .read(collectionRepositoryProvider)
                        .createCollection(newCollection);

                    Navigator.of(context).pop();
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

  void _showEditCollectionDialog(
      BuildContext context, WidgetRef ref, Collection collection) {
    final nameController = TextEditingController(text: collection.name);
    final descriptionController =
        TextEditingController(text: collection.description);
    String selectedIcon = collection.icon;
    String selectedColor = collection.color;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Collection'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name field
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        hintText: 'Enter collection name',
                      ),
                      maxLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                    ),

                    const SizedBox(height: 16),

                    // Description field
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        hintText: 'Enter collection description',
                      ),
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                    ),

                    const SizedBox(height: 16),

                    // Icon selector
                    const Text('Icon'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildIconOption(context, 'folder', selectedIcon,
                            (icon) {
                          setState(() => selectedIcon = icon);
                        }),
                        _buildIconOption(context, 'work', selectedIcon, (icon) {
                          setState(() => selectedIcon = icon);
                        }),
                        _buildIconOption(context, 'favorite', selectedIcon,
                            (icon) {
                          setState(() => selectedIcon = icon);
                        }),
                        _buildIconOption(context, 'star', selectedIcon, (icon) {
                          setState(() => selectedIcon = icon);
                        }),
                        _buildIconOption(context, 'bookmark', selectedIcon,
                            (icon) {
                          setState(() => selectedIcon = icon);
                        }),
                        _buildIconOption(context, 'label', selectedIcon,
                            (icon) {
                          setState(() => selectedIcon = icon);
                        }),
                      ],
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
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Name cannot be empty'),
                        ),
                      );
                      return;
                    }

                    // Update collection
                    final updatedCollection = collection.copyWith(
                      name: nameController.text.trim(),
                      description: descriptionController.text.trim(),
                      icon: selectedIcon,
                      color: selectedColor,
                      updatedAt: DateTime.now(),
                    );

                    // Save collection
                    ref
                        .read(collectionRepositoryProvider)
                        .updateCollection(updatedCollection);

                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteCollectionDialog(
      BuildContext context, WidgetRef ref, Collection collection) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Collection'),
          content: Text(
              'Are you sure you want to delete "${collection.name}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                // Delete collection
                ref
                    .read(collectionRepositoryProvider)
                    .deleteCollection(collection.id);

                // Clear selection if this collection was selected
                if (ref.read(selectedCollectionIdProvider) == collection.id) {
                  ref.read(selectedCollectionIdProvider.notifier).state = null;
                }

                Navigator.of(context).pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIconOption(
    BuildContext context,
    String icon,
    String selectedIcon,
    Function(String) onSelected,
  ) {
    final theme = Theme.of(context);
    final isSelected = icon == selectedIcon;

    IconData iconData;
    switch (icon) {
      case 'folder':
        iconData = Icons.folder;
        break;
      case 'work':
        iconData = Icons.work;
        break;
      case 'favorite':
        iconData = Icons.favorite;
        break;
      case 'star':
        iconData = Icons.star;
        break;
      case 'bookmark':
        iconData = Icons.bookmark;
        break;
      case 'label':
        iconData = Icons.label;
        break;
      default:
        iconData = Icons.folder;
    }

    return InkWell(
      onTap: () => onSelected(icon),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Icon(
          iconData,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildColorOption(
    BuildContext context,
    String color,
    String selectedColor,
    Function(String) onSelected,
  ) {
    final theme = Theme.of(context);
    final isSelected = color == selectedColor;

    Color displayColor;
    if (color.isEmpty) {
      displayColor = theme.colorScheme.surface;
    } else {
      try {
        displayColor = Color(int.parse(color, radix: 16) | 0xFF000000);
      } catch (_) {
        displayColor = theme.colorScheme.surface;
      }
    }

    return InkWell(
      onTap: () => onSelected(color),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: displayColor,
          shape: BoxShape.circle,
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
                color: color.isEmpty
                    ? theme.colorScheme.primary
                    : _contrastColor(displayColor),
                size: 20,
              )
            : null,
      ),
    );
  }

  Color _contrastColor(Color color) {
    final brightness = color.computeLuminance();
    return brightness > 0.5 ? Colors.black : Colors.white;
  }
}

class _CollectionListItem extends StatelessWidget {
  const _CollectionListItem({
    required this.collection,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Collection collection;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine icon
    IconData iconData;
    switch (collection.icon) {
      case 'folder':
        iconData = Icons.folder;
        break;
      case 'work':
        iconData = Icons.work;
        break;
      case 'favorite':
        iconData = Icons.favorite;
        break;
      case 'star':
        iconData = Icons.star;
        break;
      case 'bookmark':
        iconData = Icons.bookmark;
        break;
      case 'label':
        iconData = Icons.label;
        break;
      default:
        iconData = Icons.folder;
    }

    // Determine color
    Color iconColor;
    if (collection.color.isEmpty) {
      iconColor = isSelected
          ? theme.colorScheme.primary
          : theme.colorScheme.onSurfaceVariant;
    } else {
      try {
        iconColor = Color(int.parse(collection.color, radix: 16) | 0xFF000000);
      } catch (_) {
        iconColor = isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant;
      }
    }

    return ListTile(
      leading: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
      title: Text(
        collection.name,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: collection.description.isNotEmpty
          ? Text(
              collection.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(0.2),
      dense: true,
      visualDensity: VisualDensity.compact,
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, size: 16),
            onPressed: onEdit,
            tooltip: 'Edit',
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 16),
            onPressed: onDelete,
            tooltip: 'Delete',
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
