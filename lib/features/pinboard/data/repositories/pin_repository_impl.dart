import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/models/pin.dart';
import '../../domain/repositories/pin_repository.dart';

/// Implementation of [PinRepository] using Hive for local storage
class PinRepositoryImpl implements PinRepository {
  /// Constructor
  PinRepositoryImpl({Box? pinsBox}) : _pinsBox = pinsBox ?? Hive.box('pins');

  final Box _pinsBox;
  final _pinsStreamController = StreamController<List<Pin>>.broadcast();

  @override
  Future<List<Pin>> getAllPins() async {
    final pins = _pinsBox.values
        .map((json) => Pin.fromJson(Map<String, dynamic>.from(json)))
        .toList();
    return pins.cast<Pin>();
  }

  @override
  Future<Pin?> getPinById(String id) async {
    final json = _pinsBox.get(id);
    if (json == null) return null;
    return Pin.fromJson(Map<String, dynamic>.from(json));
  }

  @override
  Future<void> createPin(Pin pin) async {
    await _pinsBox.put(pin.id, pin.toJson());
    _updatePinsStream();
  }

  @override
  Future<void> updatePin(Pin pin) async {
    await _pinsBox.put(pin.id, pin.toJson());
    _updatePinsStream();
  }

  @override
  Future<void> deletePin(String id) async {
    await _pinsBox.delete(id);
    _updatePinsStream();
  }

  @override
  Future<List<Pin>> getPinsByTag(String tag) async {
    final pins = await getAllPins();
    return pins.where((pin) => pin.tags.contains(tag)).toList();
  }

  @override
  Future<List<Pin>> getPinsByType(PinType type) async {
    final pins = await getAllPins();
    return pins.where((pin) => pin.type == type).toList();
  }

  @override
  Future<List<Pin>> getPinnedPins() async {
    final pins = await getAllPins();
    return pins.where((pin) => pin.isPinned).toList();
  }

  @override
  Future<List<Pin>> getArchivedPins() async {
    final pins = await getAllPins();
    return pins.where((pin) => pin.isArchived).toList();
  }

  @override
  Future<List<Pin>> getPinsByPriority(PinPriority priority) async {
    final pins = await getAllPins();
    return pins.where((pin) => pin.priority == priority).toList();
  }

  @override
  Future<void> archivePin(String id) async {
    final pin = await getPinById(id);
    if (pin != null) {
      final updatedPin = pin.copyWith(isArchived: true);
      await updatePin(updatedPin);
    }
  }

  @override
  Future<void> unarchivePin(String id) async {
    final pin = await getPinById(id);
    if (pin != null) {
      final updatedPin = pin.copyWith(isArchived: false);
      await updatePin(updatedPin);
    }
  }

  @override
  Future<void> createPinVersion(Pin pin) async {
    final updatedPin = pin.createVersion();
    await updatePin(updatedPin);
  }

  @override
  Future<Pin> restorePinVersion(String pinId, String versionId) async {
    final pin = await getPinById(pinId);
    if (pin == null) {
      throw Exception('Pin not found');
    }

    final restoredPin = pin.restoreVersion(versionId);
    await updatePin(restoredPin);
    return restoredPin;
  }

  @override
  Stream<List<Pin>> watchAllPins() {
    // Initialize the stream with current pins
    _updatePinsStream();

    // Listen to box changes and update the stream
    _pinsBox.listenable().addListener(_updatePinsStream);

    return _pinsStreamController.stream;
  }

  void _updatePinsStream() async {
    final pins = await getAllPins();
    _pinsStreamController.add(pins);
  }
}
