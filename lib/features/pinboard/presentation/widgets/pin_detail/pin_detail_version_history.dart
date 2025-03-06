import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/pin.dart';
import '../../providers/pin_providers.dart';

/// Component for displaying pin version history
class PinDetailVersionHistory extends ConsumerWidget {
  /// Constructor
  const PinDetailVersionHistory({
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
    if (pin.versionHistory.isEmpty) {
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
              Icons.history,
              size: 18,
              color: theme.colorScheme.primary.withOpacity(0.8),
            ),
            const SizedBox(width: 8),
            Text(
              'Version History',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),

            // View history button
            _buildViewHistoryButton(context, ref),
          ],
        ),

        const SizedBox(height: 12),

        // Version count with animation
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                '${pin.versionHistory.length} previous ${pin.versionHistory.length == 1 ? 'version' : 'versions'}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildViewHistoryButton(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: 'View version history',
      child: TextButton.icon(
        icon: const Icon(Icons.history, size: 16),
        label: const Text('View History'),
        style: TextButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          visualDensity: VisualDensity.compact,
          textStyle: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        onPressed: () {
          // Show version history dialog
          showDialog(
            context: context,
            builder: (context) => _VersionHistoryDialog(pin: pin, ref: ref),
          );
        },
      ),
    );
  }
}

/// Dialog for viewing version history
class _VersionHistoryDialog extends StatelessWidget {
  const _VersionHistoryDialog({
    required this.pin,
    required this.ref,
  });

  final Pin pin;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy h:mm a');

    return AlertDialog(
      title: const Text('Version History'),
      content: SizedBox(
        width: 600,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Previous versions of "${pin.title}"',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Version list
            Expanded(
              child: ListView.builder(
                itemCount: pin.versionHistory.length,
                itemBuilder: (context, index) {
                  final version =
                      pin.versionHistory[pin.versionHistory.length - 1 - index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerLowest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color:
                            theme.colorScheme.outlineVariant.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Version header
                          Row(
                            children: [
                              Icon(
                                Icons.history,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Version ${index + 1}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                dateFormat.format(version.timestamp),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Version title
                          Text(
                            version.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Version content preview
                          Text(
                            version.content.length > 100
                                ? '${version.content.substring(0, 100)}...'
                                : version.content,
                            style: theme.textTheme.bodyMedium,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),

                          // Restore button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                icon: const Icon(Icons.restore, size: 16),
                                label: const Text('Restore This Version'),
                                onPressed: () =>
                                    _restoreVersion(context, version.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  void _restoreVersion(BuildContext context, String versionId) {
    try {
      // Create a new version of the current state before restoring
      final currentVersion = pin.createVersion();

      // Restore the version
      final repository = ref.read(pinRepositoryProvider);
      final restoredPin = currentVersion.restoreVersion(versionId);
      repository.updatePin(restoredPin);

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Version restored successfully'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error restoring version: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
