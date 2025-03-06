import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/pin.dart';
import '../providers/pin_providers.dart';
import '../providers/collection_providers.dart';

/// Floating action button for creating new pins
class PinCreateFab extends ConsumerWidget {
  /// Constructor
  const PinCreateFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return FloatingActionButton(
      onPressed: () => _showCreatePinDialog(context, ref),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      tooltip: 'Create Pin',
      child: const Icon(Icons.add),
    );
  }

  void _showCreatePinDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final tagController = TextEditingController();
    PinType selectedType = PinType.note;
    PinPriority selectedPriority = PinPriority.medium;
    List<String> selectedTags = [];
    String? selectedCollectionId;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final allTags = ref.watch(allTagsProvider);
            final collectionsAsync = ref.watch(allCollectionsProvider);

            return AlertDialog(
              title: const Text('Create New Pin'),
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

                    // Collection selector
                    collectionsAsync.when(
                      data: (collections) {
                        if (collections.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Collection (optional)',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String?>(
                              value: selectedCollectionId,
                              decoration: const InputDecoration(
                                labelText: 'Add to Collection',
                                hintText: 'Select a collection',
                              ),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('None'),
                                ),
                                ...collections.map((collection) {
                                  return DropdownMenuItem<String?>(
                                    value: collection.id,
                                    child: Text(collection.name),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedCollectionId = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => const Text('Error loading collections'),
                    ),

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
                            label: Text('#$tag'),
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
                    // Validate inputs
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Title cannot be empty'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      // Create new pin
                      final newPin = Pin.create(
                        title: titleController.text.trim(),
                        content: contentController.text.trim(),
                        type: selectedType,
                        priority: selectedPriority,
                        tags: selectedTags,
                      );

                      // Save pin
                      ref.read(pinRepositoryProvider).createPin(newPin);

                      // Add to collection if selected
                      if (selectedCollectionId != null) {
                        ref
                            .read(collectionRepositoryProvider)
                            .addPinToCollection(
                              selectedCollectionId!,
                              newPin.id,
                            );

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Pin added to collection'),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        );
                      } else {
                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Pin created successfully'),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        );
                      }

                      Navigator.of(context).pop();
                    } catch (e) {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error creating pin: $e'),
                          backgroundColor: Colors.red,
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

  void _showCreateTagDialog(
    BuildContext context,
    WidgetRef ref,
    Function(String) onTagCreated,
  ) {
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
                FilledButton(
                  onPressed: () {
                    final tagName = textController.text.trim();
                    if (tagName.isNotEmpty) {
                      // Add tag to the system
                      ref.read(tagRepositoryProvider).createTag(
                            tagName,
                            color: selectedColor,
                          );

                      // Call the callback with the new tag
                      onTagCreated(tagName);

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Tag "$tagName" added to pin'),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                      );

                      Navigator.of(context).pop();
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
