import '../models/collection.dart';

/// Repository interface for managing collections
abstract class CollectionRepository {
  /// Get all collections
  Future<List<Collection>> getAllCollections();

  /// Get a collection by id
  Future<Collection?> getCollectionById(String id);

  /// Create a new collection
  Future<void> createCollection(Collection collection);

  /// Update an existing collection
  Future<void> updateCollection(Collection collection);

  /// Delete a collection by id
  Future<void> deleteCollection(String id);

  /// Add a pin to a collection
  Future<void> addPinToCollection(String collectionId, String pinId);

  /// Remove a pin from a collection
  Future<void> removePinFromCollection(String collectionId, String pinId);

  /// Get pins in a collection
  Future<List<String>> getPinsInCollection(String collectionId);

  /// Stream of all collections
  Stream<List<Collection>> watchAllCollections();
}
