import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/models/collection.dart';
import '../../domain/repositories/collection_repository.dart';

/// Implementation of [CollectionRepository] using Hive for local storage
class CollectionRepositoryImpl implements CollectionRepository {
  /// Constructor
  CollectionRepositoryImpl({Box? collectionsBox})
      : _collectionsBox = collectionsBox ?? Hive.box('collections');

  final Box _collectionsBox;
  final _collectionsStreamController =
      StreamController<List<Collection>>.broadcast();

  @override
  Future<List<Collection>> getAllCollections() async {
    final collections = _collectionsBox.values
        .map((json) => Collection.fromJson(Map<String, dynamic>.from(json)))
        .toList();
    return collections.cast<Collection>();
  }

  @override
  Future<Collection?> getCollectionById(String id) async {
    final json = _collectionsBox.get(id);
    if (json == null) return null;
    return Collection.fromJson(Map<String, dynamic>.from(json));
  }

  @override
  Future<void> createCollection(Collection collection) async {
    await _collectionsBox.put(collection.id, collection.toJson());
    _updateCollectionsStream();
  }

  @override
  Future<void> updateCollection(Collection collection) async {
    await _collectionsBox.put(collection.id, collection.toJson());
    _updateCollectionsStream();
  }

  @override
  Future<void> deleteCollection(String id) async {
    await _collectionsBox.delete(id);
    _updateCollectionsStream();
  }

  @override
  Future<void> addPinToCollection(String collectionId, String pinId) async {
    final collection = await getCollectionById(collectionId);
    if (collection == null) return;

    if (!collection.pinIds.contains(pinId)) {
      final updatedCollection = collection.copyWith(
        pinIds: [...collection.pinIds, pinId],
        updatedAt: DateTime.now(),
      );
      await updateCollection(updatedCollection);
    }
  }

  @override
  Future<void> removePinFromCollection(
      String collectionId, String pinId) async {
    final collection = await getCollectionById(collectionId);
    if (collection == null) return;

    if (collection.pinIds.contains(pinId)) {
      final updatedCollection = collection.copyWith(
        pinIds: collection.pinIds.where((id) => id != pinId).toList(),
        updatedAt: DateTime.now(),
      );
      await updateCollection(updatedCollection);
    }
  }

  @override
  Future<List<String>> getPinsInCollection(String collectionId) async {
    final collection = await getCollectionById(collectionId);
    if (collection == null) return [];
    return collection.pinIds;
  }

  @override
  Stream<List<Collection>> watchAllCollections() {
    // Initialize the stream with current collections
    _updateCollectionsStream();

    // Listen to box changes and update the stream
    _collectionsBox.listenable().addListener(_updateCollectionsStream);

    return _collectionsStreamController.stream;
  }

  void _updateCollectionsStream() async {
    final collections = await getAllCollections();
    _collectionsStreamController.add(collections);
  }
}
