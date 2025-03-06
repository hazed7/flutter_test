import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/pin.dart';
import '../providers/pin_providers.dart';
import '../widgets/pin_search_bar.dart';

/// Keyboard shortcuts service provider
final keyboardShortcutsServiceProvider =
    Provider<KeyboardShortcutsService>((ref) {
  return KeyboardShortcutsService(ref);
});

/// Keyboard shortcuts service
class KeyboardShortcutsService {
  /// Constructor
  KeyboardShortcutsService(this._ref);

  final Ref _ref;

  /// Handle keyboard shortcuts
  KeyEventResult handleKeyEvent(FocusNode node, KeyEvent event) {
    // Only handle key down events
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    // Check for keyboard shortcuts
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _ref.read(selectedPinIdProvider.notifier).state = null;
      return KeyEventResult.handled;
    }

    // Check for modifier keys
    final isControlOrMetaPressed = HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;

    // Ctrl/Cmd + N - New pin
    if (event.logicalKey == LogicalKeyboardKey.keyN && isControlOrMetaPressed) {
      _createNewPin();
      return KeyEventResult.handled;
    }

    // Ctrl/Cmd + F - Focus search
    if (event.logicalKey == LogicalKeyboardKey.keyF && isControlOrMetaPressed) {
      _focusSearch();
      return KeyEventResult.handled;
    }

    // Ctrl/Cmd + G - Toggle grid/list view
    if (event.logicalKey == LogicalKeyboardKey.keyG && isControlOrMetaPressed) {
      _toggleViewMode();
      return KeyEventResult.handled;
    }

    // Ctrl/Cmd + A - Toggle show archived
    if (event.logicalKey == LogicalKeyboardKey.keyA && isControlOrMetaPressed) {
      _toggleShowArchived();
      return KeyEventResult.handled;
    }

    // Ctrl/Cmd + Delete - Delete selected pin
    if (event.logicalKey == LogicalKeyboardKey.delete &&
        isControlOrMetaPressed) {
      _deleteSelectedPin();
      return KeyEventResult.handled;
    }

    // Ctrl/Cmd + P - Pin/unpin selected pin
    if (event.logicalKey == LogicalKeyboardKey.keyP && isControlOrMetaPressed) {
      _togglePinSelectedPin();
      return KeyEventResult.handled;
    }

    // Ctrl/Cmd + H - Archive/unarchive selected pin
    if (event.logicalKey == LogicalKeyboardKey.keyH && isControlOrMetaPressed) {
      _toggleArchiveSelectedPin();
      return KeyEventResult.handled;
    }

    // Ctrl/Cmd + 1-4 - Set priority
    if ((event.logicalKey == LogicalKeyboardKey.digit1 ||
            event.logicalKey == LogicalKeyboardKey.digit2 ||
            event.logicalKey == LogicalKeyboardKey.digit3 ||
            event.logicalKey == LogicalKeyboardKey.digit4) &&
        isControlOrMetaPressed) {
      _setPriorityForSelectedPin(event.logicalKey);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _createNewPin() {
    // Create a new pin with default values
    final newPin = Pin.create(
      title: 'New Pin',
      content: '',
      type: PinType.note,
    );

    // Save the pin
    _ref.read(pinRepositoryProvider).createPin(newPin);

    // Select the new pin
    _ref.read(selectedPinIdProvider.notifier).state = newPin.id;
  }

  void _focusSearch() {
    final focusNode = _ref.read(searchBarFocusNodeProvider);
    focusNode.requestFocus();
  }

  void _toggleViewMode() {
    final currentMode = _ref.read(viewModeProvider);
    _ref.read(viewModeProvider.notifier).state =
        currentMode == ViewMode.grid ? ViewMode.list : ViewMode.grid;
  }

  void _toggleShowArchived() {
    final currentValue = _ref.read(showArchivedProvider);
    _ref.read(showArchivedProvider.notifier).state = !currentValue;
  }

  void _deleteSelectedPin() async {
    final selectedPinId = _ref.read(selectedPinIdProvider);
    if (selectedPinId != null) {
      final repository = _ref.read(pinRepositoryProvider);
      await repository.deletePin(selectedPinId);
      _ref.read(selectedPinIdProvider.notifier).state = null;
    }
  }

  void _togglePinSelectedPin() async {
    final selectedPin = _ref.read(selectedPinProvider);
    if (selectedPin != null) {
      final repository = _ref.read(pinRepositoryProvider);
      final updatedPin = selectedPin.copyWith(isPinned: !selectedPin.isPinned);
      await repository.updatePin(updatedPin);
    }
  }

  void _toggleArchiveSelectedPin() async {
    final selectedPin = _ref.read(selectedPinProvider);
    if (selectedPin != null) {
      final repository = _ref.read(pinRepositoryProvider);
      if (selectedPin.isArchived) {
        await repository.unarchivePin(selectedPin.id);
      } else {
        await repository.archivePin(selectedPin.id);
      }
    }
  }

  void _setPriorityForSelectedPin(LogicalKeyboardKey key) async {
    final selectedPin = _ref.read(selectedPinProvider);
    if (selectedPin != null) {
      final repository = _ref.read(pinRepositoryProvider);

      PinPriority priority;
      if (key == LogicalKeyboardKey.digit1) {
        priority = PinPriority.low;
      } else if (key == LogicalKeyboardKey.digit2) {
        priority = PinPriority.medium;
      } else if (key == LogicalKeyboardKey.digit3) {
        priority = PinPriority.high;
      } else {
        priority = PinPriority.urgent;
      }

      final updatedPin = selectedPin.copyWith(priority: priority);
      await repository.updatePin(updatedPin);
    }
  }
}
