import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/collection_repository_impl.dart';
import '../../domain/models/collection.dart';
import '../../domain/repositories/collection_repository.dart';
import 'pin_providers.dart';

/// Provider for the collection repository
final collectionRepositoryProvider = Provider<CollectionRepository>((ref) {
  return CollectionRepositoryImpl();
});

/// Provider for all collections
final allCollectionsProvider = StreamProvider<List<Collection>>((ref) {
  final repository = ref.watch(collectionRepositoryProvider);
  return repository.watchAllCollections();
});

/// Provider for a single collection by id
final collectionByIdProvider =
    FutureProvider.family<Collection?, String>((ref, id) {
  final repository = ref.watch(collectionRepositoryProvider);
  return repository.getCollectionById(id);
});

/// Provider for the selected collection id
final selectedCollectionIdProvider = StateProvider<String?>((ref) => null);

/// Provider for the selected collection
final selectedCollectionProvider = Provider<Collection?>((ref) {
  final selectedCollectionId = ref.watch(selectedCollectionIdProvider);
  if (selectedCollectionId == null) return null;

  final collectionAsync =
      ref.watch(collectionByIdProvider(selectedCollectionId));
  return collectionAsync.when(
    data: (collection) => collection,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider for pins in the selected collection
final pinsInSelectedCollectionProvider = Provider<List<String>>((ref) {
  final selectedCollection = ref.watch(selectedCollectionProvider);
  if (selectedCollection == null) return [];
  return selectedCollection.pinIds;
});

/// Provider for filtered pins in the selected collection
final filteredPinsInCollectionProvider = Provider<List<dynamic>>((ref) {
  final selectedCollection = ref.watch(selectedCollectionProvider);
  if (selectedCollection == null) return [];

  final allPins = ref.watch(filteredPinsProvider);
  final pinIds = selectedCollection.pinIds;

  return allPins.where((pin) => pinIds.contains(pin.id)).toList();
});
