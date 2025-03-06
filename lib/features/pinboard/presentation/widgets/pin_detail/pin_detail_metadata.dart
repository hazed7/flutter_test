import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/pin.dart';
import 'pin_detail_utils.dart';

/// Component for displaying pin metadata
class PinDetailMetadata extends StatelessWidget {
  /// Constructor
  const PinDetailMetadata({
    super.key,
    required this.pin,
    required this.theme,
  });

  /// The pin to display
  final Pin pin;

  /// The current theme
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Row(
      children: [
        // Priority indicator with hover effect
        _buildMetadataChip(
          icon: Icons.flag,
          label: pin.priority.displayName,
          backgroundColor: PinDetailUtils.getPriorityColor(pin.priority, theme),
          foregroundColor: PinDetailUtils.getPriorityIconColor(pin.priority),
          tooltip: 'Priority: ${pin.priority.displayName}',
        ),

        const SizedBox(width: 12),

        // Type indicator with hover effect
        _buildMetadataChip(
          icon: PinDetailUtils.getPinTypeIcon(pin.type),
          label: pin.type.displayName,
          backgroundColor: theme.colorScheme.tertiaryContainer.withOpacity(0.4),
          foregroundColor: theme.colorScheme.onTertiaryContainer,
          tooltip: 'Type: ${pin.type.displayName}',
        ),

        const Spacer(),

        // Date indicator
        Tooltip(
          message: 'Last updated on ${dateFormat.format(pin.updatedAt)}',
          child: Text(
            'Updated ${PinDetailUtils.formatDate(pin.updatedAt)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataChip({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: foregroundColor,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
