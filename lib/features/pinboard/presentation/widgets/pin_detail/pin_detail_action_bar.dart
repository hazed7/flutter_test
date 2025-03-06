import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/pin.dart';
import '../../providers/pin_providers.dart';
import '../pin_protection_dialog.dart';

/// Component for the pin detail action bar
class PinDetailActionBar extends ConsumerWidget {
  /// Constructor
  const PinDetailActionBar({
    super.key,
    required this.pin,
    required this.theme,
    required this.onClose,
  });

  /// The pin to display
  final Pin pin;

  /// The current theme
  final ThemeData theme;

  /// Callback when the detail view is closed
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side actions
          Row(
            children: [
              // Close button with animation
              _buildActionButton(
                icon: Icons.arrow_back,
                label: 'Back',
                onPressed: onClose,
                isPrimary: false,
              ),
            ],
          ),

          // Right side actions
          Row(
            children: [
              // Edit button
              _buildActionButton(
                icon: Icons.edit,
                label: 'Edit',
                onPressed: () => _showEditPinDialog(context, ref),
                isPrimary: true,
              ),
              const SizedBox(width: 12),

              // Archive/Unarchive button
              _buildActionButton(
                icon: pin.isArchived ? Icons.unarchive : Icons.archive,
                label: pin.isArchived ? 'Unarchive' : 'Archive',
                onPressed: () => _toggleArchivePin(ref),
                isPrimary: false,
              ),
              const SizedBox(width: 12),

              // Pin/Unpin button
              _buildActionButton(
                icon: pin.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                label: pin.isPinned ? 'Unpin' : 'Pin to Top',
                onPressed: () => _togglePinToTop(ref),
                isPrimary: false,
              ),
              const SizedBox(width: 12),

              // Protect/Unprotect button
              _buildActionButton(
                icon: pin.isProtected ? Icons.lock_open : Icons.lock,
                label: pin.isProtected ? 'Remove Protection' : 'Protect',
                onPressed: () => _togglePinProtection(context, ref),
                isPrimary: false,
              ),
              const SizedBox(width: 12),

              // Delete button
              _buildActionButton(
                icon: Icons.delete,
                label: 'Delete',
                onPressed: () => _showDeletePinDialog(context, ref),
                isPrimary: false,
                isDestructive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
    bool isDestructive = false,
  }) {
    if (isPrimary) {
      return FilledButton.icon(
        icon: Icon(icon, size: 18),
        label: Text(label),
        onPressed: onPressed,
      );
    } else {
      return OutlinedButton.icon(
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: isDestructive
            ? OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              )
            : null,
        onPressed: onPressed,
      );
    }
  }

  void _togglePinProtection(BuildContext context, WidgetRef ref) {
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

  void _toggleArchivePin(WidgetRef ref) {
    final repository = ref.read(pinRepositoryProvider);
    repository.updatePin(pin.copyWith(isArchived: !pin.isArchived));
  }

  void _togglePinToTop(WidgetRef ref) {
    final repository = ref.read(pinRepositoryProvider);
    repository.updatePin(pin.copyWith(isPinned: !pin.isPinned));
  }

  void _showEditPinDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController(text: pin.title);
    final contentController = TextEditingController(text: pin.content);
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
                            style: theme.textTheme.titleMedium,
                          ),
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

  void _showDeletePinDialog(BuildContext context, WidgetRef ref) {
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
              onClose();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
