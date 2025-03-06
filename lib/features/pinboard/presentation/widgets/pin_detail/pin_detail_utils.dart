import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/pin.dart';

/// Utility class for pin detail components
class PinDetailUtils {
  /// Format a date to a readable string
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  /// Get the icon for a pin type
  static IconData getPinTypeIcon(PinType type) {
    switch (type) {
      case PinType.note:
        return Icons.note;
      case PinType.task:
        return Icons.task_alt;
      case PinType.image:
        return Icons.image;
      case PinType.link:
        return Icons.link;
    }
  }

  /// Get the color for a pin priority
  static Color getPriorityColor(PinPriority priority, ThemeData theme) {
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

  /// Get the icon color for a pin priority
  static Color getPriorityIconColor(PinPriority priority) {
    switch (priority) {
      case PinPriority.low:
        return Colors.blue;
      case PinPriority.medium:
        return Colors.green;
      case PinPriority.high:
        return Colors.orange;
      case PinPriority.urgent:
        return Colors.red;
    }
  }
}
