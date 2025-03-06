import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pin_providers.dart';
import '../../domain/models/pin.dart';

/// Widget that wraps the app with keyboard shortcuts
class KeyboardShortcutsWrapper extends ConsumerWidget {
  /// Constructor
  const KeyboardShortcutsWrapper({
    super.key,
    required this.child,
  });

  /// The child widget
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Focus(
      autofocus: true,
      onKeyEvent: (_, event) {
        // Only handle key down events
        if (event.runtimeType != KeyDownEvent) {
          return KeyEventResult.ignored;
        }

        // Handle keyboard shortcuts
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          // Deselect current pin
          ref.read(selectedPinIdProvider.notifier).state = null;
          return KeyEventResult.handled;
        }

        // Check if Ctrl/Cmd is pressed
        final isControlOrMetaPressed =
            HardwareKeyboard.instance.isControlPressed ||
                HardwareKeyboard.instance.isMetaPressed;

        // Handle Ctrl/Cmd key combinations
        if (isControlOrMetaPressed) {
          if (event.logicalKey == LogicalKeyboardKey.keyF) {
            // Focus search (handled in PinSearchBar)
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.keyG) {
            // Toggle grid/list view
            final currentViewMode = ref.read(viewModeProvider);
            ref.read(viewModeProvider.notifier).state =
                currentViewMode == ViewMode.grid
                    ? ViewMode.list
                    : ViewMode.grid;
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.keyA) {
            // Toggle show archived
            final showArchived = ref.read(showArchivedProvider);
            ref.read(showArchivedProvider.notifier).state = !showArchived;
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.keyN) {
            // Create new pin
            // This will be handled by the FAB
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.keyP) {
            // Pin/unpin selected pin
            final selectedPin = ref.read(selectedPinProvider);
            if (selectedPin != null) {
              final pinRepository = ref.read(pinRepositoryProvider);
              pinRepository.updatePin(
                selectedPin.copyWith(isPinned: !selectedPin.isPinned),
              );
            }
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.keyH) {
            // Archive/unarchive selected pin
            final selectedPin = ref.read(selectedPinProvider);
            if (selectedPin != null) {
              final pinRepository = ref.read(pinRepositoryProvider);
              pinRepository.updatePin(
                selectedPin.copyWith(isArchived: !selectedPin.isArchived),
              );
            }
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.delete) {
            // Delete selected pin
            final selectedPin = ref.read(selectedPinProvider);
            if (selectedPin != null) {
              final pinRepository = ref.read(pinRepositoryProvider);
              pinRepository.deletePin(selectedPin.id);
              ref.read(selectedPinIdProvider.notifier).state = null;
            }
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.digit1) {
            // Set low priority
            _setPriority(ref, PinPriority.low);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.digit2) {
            // Set medium priority
            _setPriority(ref, PinPriority.medium);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.digit3) {
            // Set high priority
            _setPriority(ref, PinPriority.high);
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.digit4) {
            // Set urgent priority
            _setPriority(ref, PinPriority.urgent);
            return KeyEventResult.handled;
          }
        }

        return KeyEventResult.ignored;
      },
      child: child,
    );
  }

  void _setPriority(WidgetRef ref, PinPriority priority) {
    final selectedPin = ref.read(selectedPinProvider);
    if (selectedPin != null) {
      final pinRepository = ref.read(pinRepositoryProvider);
      pinRepository.updatePin(
        selectedPin.copyWith(priority: priority),
      );
    }
  }
}
