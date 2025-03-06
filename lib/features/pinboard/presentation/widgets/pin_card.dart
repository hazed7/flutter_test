import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/models/pin.dart';
import '../providers/pin_providers.dart';
import 'action_button.dart';
import 'pin_protection_dialog.dart';
import 'tag_management_dialog.dart';
import 'version_history_dialog.dart';

/// Provider to track unlocked pins
final unlockedPinsProvider = StateProvider<Set<String>>((ref) => {});

/// Card widget for displaying a pin
class PinCard extends ConsumerWidget {
  /// Constructor
  const PinCard({
    super.key,
    required this.pin,
    this.inCollection = false,
    this.onAddToCollection,
    this.onRemoveFromCollection,
  });

  /// The pin to display
  final Pin pin;

  /// Whether this pin is being displayed in a collection
  final bool inCollection;

  /// Callback when adding to collection
  final VoidCallback? onAddToCollection;

  /// Callback when removing from collection
  final VoidCallback? onRemoveFromCollection;

  bool _isPinUnlocked(WidgetRef ref) {
    final unlockedPins = ref.watch(unlockedPinsProvider);
    return unlockedPins.contains(pin.id);
  }

  void _unlockPin(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => PinProtectionDialog(
        pin: pin,
        isUnlocking: true,
        onUnlocked: () {
          ref.read(unlockedPinsProvider.notifier).update((state) {
            return {...state, pin.id};
          });
        },
      ),
    );
  }

  void _togglePinProtection(BuildContext context, WidgetRef ref, Pin pin) {
    if (pin.isProtected) {
      showDialog(
        context: context,
        builder: (context) => RemovePinProtectionDialog(pin: pin),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => PinProtectionDialog(pin: pin),
      );
    }
  }

  void _toggleArchivePin(WidgetRef ref, Pin pin) {
    final repository = ref.read(pinRepositoryProvider);
    repository.updatePin(pin.copyWith(isArchived: !pin.isArchived));
  }

  void _togglePinToTop(WidgetRef ref, Pin pin) {
    final repository = ref.read(pinRepositoryProvider);
    repository.updatePin(pin.copyWith(isPinned: !pin.isPinned));
  }

  void _showEditPinDialog(BuildContext context, WidgetRef ref, Pin pin) {
    final titleController = TextEditingController(text: pin.title);
    final contentController = TextEditingController(text: pin.content);
    final tagController = TextEditingController();
    PinType selectedType = pin.type;
    PinPriority selectedPriority = pin.priority;
    List<String> selectedTags = List.from(pin.tags);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final allTags = ref.watch(allTagsProvider);

            return AlertDialog(
              title: const Text('Edit Pin'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title field
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'Enter pin title',
                      ),
                      maxLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                    ),

                    const SizedBox(height: 16),

                    // Content field
                    TextField(
                      controller: contentController,
                      decoration: const InputDecoration(
                        labelText: 'Content',
                        hintText: 'Enter pin content',
                      ),
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                    ),

                    const SizedBox(height: 16),

                    // Pin type selector
                    DropdownButtonFormField<PinType>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Pin Type',
                      ),
                      items: PinType.values.map((type) {
                        return DropdownMenuItem<PinType>(
                          value: type,
                          child: Text(type.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedType = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Priority selector
                    DropdownButtonFormField<PinPriority>(
                      value: selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                      ),
                      items: PinPriority.values.map((priority) {
                        return DropdownMenuItem<PinPriority>(
                          value: priority,
                          child: Text(priority.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedPriority = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Tags section
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Tags',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            // Show dialog to create a new tag
                            _showCreateTagDialog(context, ref, (newTag) {
                              setState(() {
                                if (!selectedTags.contains(newTag)) {
                                  selectedTags.add(newTag);
                                }
                              });
                            });
                          },
                          tooltip: 'Create new tag',
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Tag selection chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...allTags.map((tag) {
                          final isSelected = selectedTags.contains(tag);
                          return FilterChip(
                            label: Text(tag),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  selectedTags.add(tag);
                                } else {
                                  selectedTags.remove(tag);
                                }
                              });
                            },
                          );
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
                    final title = titleController.text.trim();
                    final content = contentController.text.trim();

                    if (title.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Title cannot be empty'),
                        ),
                      );
                      return;
                    }

                    // Create updated pin
                    final updatedPin = pin.copyWith(
                      title: title,
                      content: content,
                      type: selectedType,
                      priority: selectedPriority,
                      tags: selectedTags,
                      updatedAt: DateTime.now(),
                    );

                    // Save the pin
                    final repository = ref.read(pinRepositoryProvider);
                    repository.updatePin(updatedPin);

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

  void _showCreateTagDialog(
      BuildContext context, WidgetRef ref, Function(String) onTagCreated) {
    final tagController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Tag'),
          content: TextField(
            controller: tagController,
            decoration: const InputDecoration(
              labelText: 'Tag Name',
              hintText: 'Enter tag name',
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final tagName = tagController.text.trim();
                if (tagName.isNotEmpty) {
                  // Add tag to repository
                  final tagRepository = ref.read(tagRepositoryProvider);
                  tagRepository.createTag(tagName);

                  // Call callback
                  onTagCreated(tagName);

                  Navigator.of(context).pop();
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showTagManagementDialog(BuildContext context, WidgetRef ref, Pin pin) {
    showDialog(
      context: context,
      builder: (context) => TagManagementDialog(pin: pin),
    );
  }

  void _showVersionHistoryDialog(BuildContext context, WidgetRef ref, Pin pin) {
    showDialog(
      context: context,
      builder: (context) => VersionHistoryDialog(pin: pin),
    );
  }

  void _showDeletePinDialog(BuildContext context, WidgetRef ref, Pin pin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pin'),
        content: const Text('Are you sure you want to delete this pin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final repository = ref.read(pinRepositoryProvider);
              repository.deletePin(pin.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(BuildContext context, WidgetRef ref, String tag) {
    final theme = Theme.of(context);
    return ActionChip(
      label: Text('#$tag'),
      onPressed: () {
        ref.read(filterTagProvider.notifier).state = tag;
      },
      backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(0.4),
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSecondaryContainer,
        fontWeight: FontWeight.w500,
        fontSize: 10,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }

  Color _getPriorityColor(PinPriority priority, ThemeData theme) {
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

  Widget _buildButtonGroup(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    IconData groupIcon,
    String tooltip,
    List<ActionButton> actions,
  ) {
    return PopupMenuButton<VoidCallback>(
      icon: Icon(groupIcon, size: 16),
      tooltip: tooltip,
      itemBuilder: (context) {
        return actions.map((action) {
          return PopupMenuItem<VoidCallback>(
            value: action.onPressed,
            child: Row(
              children: [
                Icon(action.icon, size: 16),
                const SizedBox(width: 8),
                Text(action.label),
              ],
            ),
          );
        }).toList();
      },
      onSelected: (callback) => callback(),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, WidgetRef ref, ThemeData theme) {
    return MouseRegion(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Wrap(
                spacing: 4,
                runSpacing: 4,
                alignment: WrapAlignment.end,
                children: [
                  // Edit group
                  _buildButtonGroup(
                    context,
                    ref,
                    theme,
                    Icons.edit,
                    'Edit Options',
                    [
                      ActionButton(
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        onPressed: () => _showEditPinDialog(context, ref, pin),
                      ),
                      ActionButton(
                        icon: Icons.tag,
                        label: 'Manage Tags',
                        onPressed: () =>
                            _showTagManagementDialog(context, ref, pin),
                      ),
                      ActionButton(
                        icon: Icons.history,
                        label: 'Version History',
                        onPressed: () =>
                            _showVersionHistoryDialog(context, ref, pin),
                      ),
                    ],
                  ),
                  // Status group
                  _buildButtonGroup(
                    context,
                    ref,
                    theme,
                    Icons.settings,
                    'Status Options',
                    [
                      ActionButton(
                        icon: pin.isProtected ? Icons.lock : Icons.lock_open,
                        label:
                            pin.isProtected ? 'Remove Protection' : 'Protect',
                        onPressed: () =>
                            _togglePinProtection(context, ref, pin),
                      ),
                      ActionButton(
                        icon: pin.isArchived ? Icons.unarchive : Icons.archive,
                        label: pin.isArchived ? 'Unarchive' : 'Archive',
                        onPressed: () => _toggleArchivePin(ref, pin),
                      ),
                      ActionButton(
                        icon: pin.isPinned
                            ? Icons.push_pin
                            : Icons.push_pin_outlined,
                        label: pin.isPinned ? 'Unpin' : 'Pin to Top',
                        onPressed: () => _togglePinToTop(ref, pin),
                      ),
                    ],
                  ),
                  // Collection group
                  if (onAddToCollection != null ||
                      onRemoveFromCollection != null)
                    _buildButtonGroup(
                      context,
                      ref,
                      theme,
                      Icons.folder,
                      'Collection Options',
                      [
                        if (onAddToCollection != null)
                          ActionButton(
                            icon: Icons.folder_outlined,
                            label: 'Add to Collection',
                            onPressed: onAddToCollection!,
                          ),
                        if (onRemoveFromCollection != null)
                          ActionButton(
                            icon: Icons.folder_off_outlined,
                            label: 'Remove from Collection',
                            onPressed: onRemoveFromCollection!,
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(width: 4),
              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outlined, size: 16),
                onPressed: () => _showDeletePinDialog(context, ref, pin),
                visualDensity: VisualDensity.compact,
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: theme.colorScheme.error,
                  padding: const EdgeInsets.all(6),
                  minimumSize: const Size(32, 32),
                ),
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');

    // Determine card color based on pin color or use default
    Color cardColor = theme.colorScheme.surface;
    if (pin.color.isNotEmpty) {
      try {
        cardColor = Color(int.parse(pin.color, radix: 16) | 0xFF000000);
      } catch (_) {
        // Use default color if parsing fails
      }
    }

    // If pin is protected and not unlocked, show protected view
    if (pin.isProtected && !_isPinUnlocked(ref)) {
      return _buildProtectedCard(context, ref, theme, cardColor);
    }

    // Handle potential null values in pin data
    final title = pin.title.isNotEmpty ? pin.title : 'Untitled';
    final content = pin.content.isNotEmpty ? pin.content : 'No content';
    final tags = pin.tags.isNotEmpty ? pin.tags : [];
    final updatedAt = pin.updatedAt ?? DateTime.now();

    return Tooltip(
      message: 'Click to open detailed view',
      waitDuration: const Duration(milliseconds: 500),
      child: Card(
        elevation: 0,
        color: cardColor,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            // Set the selected pin ID to show the detail view
            ref.read(selectedPinIdProvider.notifier).state = pin.id;
          },
          // Ensure the ink splash covers the entire card
          splashFactory: InkRipple.splashFactory,
          highlightColor: theme.colorScheme.onSurface.withOpacity(0.1),
          child: SizedBox(
            height: 300, // Fixed height for all cards
            width: 280, // Fixed width for all cards
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with title and icons
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          if (pin.isPinned)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Icon(
                                Icons.push_pin,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          if (pin.isArchived)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Icon(
                                Icons.archive,
                                size: 16,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          if (pin.isProtected)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Icon(
                                Icons.lock,
                                size: 16,
                                color: theme.colorScheme.tertiary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Content with subtle background
                  Expanded(
                    child: Container(
                      width: double.infinity, // Full width of parent
                      height: 140, // Fixed height for content
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        content,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.9),
                          height: 1.4,
                        ),
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Footer with metadata
                  Container(
                    padding: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Pin type with enhanced styling
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(pin.priority, theme),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            pin.type.name.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        // Tags
                        if (tags.isNotEmpty)
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: tags
                                .map((tag) => _buildTagChip(context, ref, tag))
                                .toList(),
                          ),

                        // Updated date
                        Text(
                          'Updated ${dateFormat.format(updatedAt)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Action buttons
                  _buildActionButtons(context, ref, theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a protected card view when pin is locked
  Widget _buildProtectedCard(
      BuildContext context, WidgetRef ref, ThemeData theme, Color cardColor) {
    return Card(
      elevation: 0,
      color: cardColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _unlockPin(context, ref),
        child: SizedBox(
          height: 300, // Fixed height for all cards
          width: 280, // Fixed width for all cards
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock,
                  size: 48,
                  color: theme.colorScheme.tertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Protected Content',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to unlock',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
