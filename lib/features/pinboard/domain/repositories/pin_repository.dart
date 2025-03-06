import '../models/pin.dart';

/// Repository interface for managing pins
abstract class PinRepository {
  /// Get all pins
  Future<List<Pin>> getAllPins();

  /// Get a pin by id
  Future<Pin?> getPinById(String id);

  /// Create a new pin
  Future<void> createPin(Pin pin);

  /// Update an existing pin
  Future<void> updatePin(Pin pin);

  /// Delete a pin by id
  Future<void> deletePin(String id);

  /// Get pins by tag
  Future<List<Pin>> getPinsByTag(String tag);

  /// Get pins by type
  Future<List<Pin>> getPinsByType(PinType type);

  /// Get pinned pins
  Future<List<Pin>> getPinnedPins();

  /// Get archived pins
  Future<List<Pin>> getArchivedPins();

  /// Get pins by priority
  Future<List<Pin>> getPinsByPriority(PinPriority priority);

  /// Archive a pin
  Future<void> archivePin(String id);

  /// Unarchive a pin
  Future<void> unarchivePin(String id);

  /// Create a new version of a pin
  Future<void> createPinVersion(Pin pin);

  /// Restore a pin version
  Future<Pin> restorePinVersion(String pinId, String versionId);

  /// Stream of all pins
  Stream<List<Pin>> watchAllPins();
}
