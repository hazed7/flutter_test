import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/pin.dart';
import '../providers/pin_providers.dart';

/// Dialog for managing tags on a pin
class TagManagementDialog extends ConsumerStatefulWidget {
  /// Constructor
  const TagManagementDialog({
    super.key,
    required this.pin,
  });

  /// The pin to manage tags for
  final Pin pin;

  @override
  ConsumerState<TagManagementDialog> createState() =>
      _TagManagementDialogState();
}

class _TagManagementDialogState extends ConsumerState<TagManagementDialog> {
  late List<String> _selectedTags;
  final _newTagController = TextEditingController();
  String? _errorMessage;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedTags = List.from(widget.pin.tags);
  }

  @override
  void dispose() {
    _newTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allTags = ref.watch(allTagsProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.tag,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Manage Tags',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // New tag input
            Form(
              key: _formKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _newTagController,
                      decoration: InputDecoration(
                        labelText: 'New Tag',
                        hintText: 'Enter a new tag',
                        prefixIcon: const Icon(Icons.add),
                        border: const OutlineInputBorder(),
                        errorText: _errorMessage,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Tag cannot be empty';
                        }
                        if (_selectedTags.contains(value.trim())) {
                          return 'Tag already exists';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _addNewTag(),
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addNewTag,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      padding: const EdgeInsets.all(12),
                    ),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Selected tags section
            Text(
              'Selected Tags',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (_selectedTags.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
                child: Center(
                  child: Text(
                    'No tags selected',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedTags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        _selectedTags.remove(tag);
                      });
                    },
                    backgroundColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 24),

            // Available tags section
            if (allTags.isNotEmpty) ...[
              Text(
                'Available Tags',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allTags
                    .where((tag) => !_selectedTags.contains(tag))
                    .map((tag) {
                  return ActionChip(
                    label: Text(tag),
                    avatar: const Icon(Icons.add, size: 18),
                    onPressed: () {
                      setState(() {
                        _selectedTags.add(tag);
                      });
                    },
                    backgroundColor: theme.colorScheme.surfaceVariant,
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save Tags'),
                  onPressed: _saveTags,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addNewTag() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final newTag = _newTagController.text.trim();

    setState(() {
      _selectedTags.add(newTag);
      _newTagController.clear();
      _errorMessage = null;
    });
  }

  void _saveTags() async {
    final repository = ref.read(pinRepositoryProvider);
    final updatedPin = widget.pin.copyWith(tags: _selectedTags);

    try {
      await repository.updatePin(updatedPin);
      if (mounted) {
        Navigator.of(context).pop(true);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Tags saved successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error saving tags: ${e.toString()}';
        });
      }
    }
  }
}
