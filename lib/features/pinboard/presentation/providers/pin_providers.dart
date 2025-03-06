import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/pin_repository_impl.dart';
import '../../domain/models/pin.dart';
import '../../domain/repositories/pin_repository.dart';

/// Provider for the pin repository
final pinRepositoryProvider = Provider<PinRepository>((ref) {
  return PinRepositoryImpl();
});

/// Provider for tag colors
final tagColorsProvider = StateProvider<Map<String, String>>((ref) => {});

/// Provider for a simple tag repository
final tagRepositoryProvider = Provider<TagRepository>((ref) {
  return TagRepositoryImpl(ref.watch(pinRepositoryProvider), ref);
});

/// Simple tag repository interface
abstract class TagRepository {
  /// Create a new tag
  Future<void> createTag(String tagName, {String color = ''});

  /// Delete a tag from all pins
  Future<void> deleteTag(String tagName);

  /// Rename a tag across all pins
  Future<void> renameTag(String oldName, String newName);

  /// Update tag color across all pins
  Future<void> updateTagColor(String tagName, String color);

  /// Get tag color
  String getTagColor(String tagName);
}

/// Implementation of the tag repository
class TagRepositoryImpl implements TagRepository {
  /// Constructor
  TagRepositoryImpl(this._pinRepository, this._ref);

  final PinRepository _pinRepository;
  final Ref _ref;

  @override
  Future<void> createTag(String tagName, {String color = ''}) async {
    // Create a dummy pin with this tag to ensure it exists in the system
    final dummyPin = Pin.create(
      title: 'Tag: $tagName',
      content: 'This is a temporary pin to create the tag',
      tags: [tagName],
      color: color,
    );

    // Save the pin
    await _pinRepository.createPin(dummyPin);

    // Then immediately delete it to avoid cluttering the UI
    await _pinRepository.deletePin(dummyPin.id);

    // Store the tag color
    if (color.isNotEmpty) {
      _ref.read(tagColorsProvider.notifier).update((state) => {
            ...state,
            tagName: color,
          });
    }

    // Add to persistent tags
    _ref.read(persistentTagsProvider.notifier).update((state) => {
          ...state,
          tagName,
        });
  }

  @override
  Future<void> deleteTag(String tagName) async {
    final pinsWithTag = await _pinRepository.getPinsByTag(tagName);

    for (final pin in pinsWithTag) {
      final updatedTags = List<String>.from(pin.tags)..remove(tagName);
      final updatedPin = pin.copyWith(
        tags: updatedTags,
        // Clear the color if it was the only tag and the color was set
        color: updatedTags.isEmpty ? '' : pin.color,
      );
      await _pinRepository.updatePin(updatedPin);
    }
  }

  @override
  Future<void> renameTag(String oldName, String newName) async {
    final pinsWithTag = await _pinRepository.getPinsByTag(oldName);

    // Get the color of the old tag
    final oldColor = getTagColor(oldName);

    for (final pin in pinsWithTag) {
      final updatedTags = List<String>.from(pin.tags)
        ..remove(oldName)
        ..add(newName);
      final updatedPin = pin.copyWith(tags: updatedTags);
      await _pinRepository.updatePin(updatedPin);
    }

    // Update the tag color for the new name
    if (oldColor.isNotEmpty) {
      _ref.read(tagColorsProvider.notifier).update((state) {
        final newState = Map<String, String>.from(state);
        newState.remove(oldName);
        newState[newName] = oldColor;
        return newState;
      });
    }

    // Update persistent tags
    _ref.read(persistentTagsProvider.notifier).update((state) {
      final newState = Set<String>.from(state);
      newState.remove(oldName);
      newState.add(newName);
      return newState;
    });
  }

  @override
  Future<void> updateTagColor(String tagName, String color) async {
    final pinsWithTag = await _pinRepository.getPinsByTag(tagName);

    for (final pin in pinsWithTag) {
      final updatedPin = pin.copyWith(color: color);
      await _pinRepository.updatePin(updatedPin);
    }

    // Store the tag color
    _ref.read(tagColorsProvider.notifier).update((state) => {
          ...state,
          tagName: color,
        });
  }

  @override
  String getTagColor(String tagName) {
    return _ref.read(tagColorsProvider)[tagName] ?? '';
  }
}

/// Provider for all pins
final allPinsProvider = StreamProvider<List<Pin>>((ref) {
  final repository = ref.watch(pinRepositoryProvider);
  return repository.watchAllPins();
});

/// Provider for pinned pins
final pinnedPinsProvider = FutureProvider<List<Pin>>((ref) {
  final repository = ref.watch(pinRepositoryProvider);
  return repository.getPinnedPins();
});

/// Provider for archived pins
final archivedPinsProvider = FutureProvider<List<Pin>>((ref) {
  final repository = ref.watch(pinRepositoryProvider);
  return repository.getArchivedPins();
});

/// Provider for pins by type
final pinsByTypeProvider =
    FutureProvider.family<List<Pin>, PinType>((ref, type) {
  final repository = ref.watch(pinRepositoryProvider);
  return repository.getPinsByType(type);
});

/// Provider for pins by priority
final pinsByPriorityProvider =
    FutureProvider.family<List<Pin>, PinPriority>((ref, priority) {
  final repository = ref.watch(pinRepositoryProvider);
  return repository.getPinsByPriority(priority);
});

/// Provider for pins by tag
final pinsByTagProvider = FutureProvider.family<List<Pin>, String>((ref, tag) {
  final repository = ref.watch(pinRepositoryProvider);
  return repository.getPinsByTag(tag);
});

/// Provider for a single pin by id
final pinByIdProvider = FutureProvider.family<Pin?, String>((ref, id) {
  final repository = ref.watch(pinRepositoryProvider);
  return repository.getPinById(id);
});

/// Provider for the selected pin id
final selectedPinIdProvider = StateProvider<String?>((ref) => null);

/// Provider for the selected pin
final selectedPinProvider = Provider<Pin?>((ref) {
  final selectedPinId = ref.watch(selectedPinIdProvider);
  if (selectedPinId == null) return null;

  final pinAsync = ref.watch(pinByIdProvider(selectedPinId));
  return pinAsync.when(
    data: (pin) => pin,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider for the filter type
final filterTypeProvider = StateProvider<PinType?>((ref) => null);

/// Provider for the filter priority
final filterPriorityProvider = StateProvider<PinPriority?>((ref) => null);

/// Provider for the filter tag
final filterTagProvider = StateProvider<String?>((ref) => null);

/// Provider for the search query
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for showing archived pins
final showArchivedProvider = StateProvider<bool>((ref) => false);

/// Provider for the view mode (grid or list)
final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.grid);

/// Provider for filtered pins
final filteredPinsProvider = Provider<List<Pin>>((ref) {
  final pinsAsync = ref.watch(allPinsProvider);

  return pinsAsync.when(
    data: (pins) {
      final filterType = ref.watch(filterTypeProvider);
      final filterTag = ref.watch(filterTagProvider);
      final filterPriority = ref.watch(filterPriorityProvider);
      final searchQuery = ref.watch(searchQueryProvider);
      final showArchived = ref.watch(showArchivedProvider);

      var filteredPins = pins;

      // Filter by archived status
      if (!showArchived) {
        filteredPins = filteredPins.where((pin) => !pin.isArchived).toList();
      }

      // Filter by type
      if (filterType != null) {
        filteredPins =
            filteredPins.where((pin) => pin.type == filterType).toList();
      }

      // Filter by priority
      if (filterPriority != null) {
        filteredPins = filteredPins
            .where((pin) => pin.priority == filterPriority)
            .toList();
      }

      // Filter by tag
      if (filterTag != null && filterTag.isNotEmpty) {
        filteredPins =
            filteredPins.where((pin) => pin.tags.contains(filterTag)).toList();
      }

      // Filter by search query
      if (searchQuery.isNotEmpty) {
        filteredPins = filteredPins.where((pin) {
          return pin.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              pin.content.toLowerCase().contains(searchQuery.toLowerCase()) ||
              pin.tags.any((tag) =>
                  tag.toLowerCase().contains(searchQuery.toLowerCase()));
        }).toList();
      }

      return filteredPins;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for all available tags (including those not currently used by any pins)
final persistentTagsProvider = StateProvider<Set<String>>((ref) {
  final pinsAsync = ref.watch(allPinsProvider);

  return pinsAsync.when(
    data: (pins) {
      final allTags = <String>{};
      for (final pin in pins) {
        allTags.addAll(pin.tags);
      }
      return allTags;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

/// Provider for all available tags
final allTagsProvider = Provider<List<String>>((ref) {
  final persistentTags = ref.watch(persistentTagsProvider);
  return persistentTags.toList()..sort();
});

/// Provider for pin sort type
final pinSortTypeProvider = StateProvider<String>((ref) => 'date_desc');

/// View mode enum
enum ViewMode {
  /// Grid view
  grid,

  /// List view
  list,
}
