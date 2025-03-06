import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'pin.freezed.dart';
part 'pin.g.dart';

/// Pin version for tracking history
@freezed
class PinVersion with _$PinVersion {
  /// Default constructor
  const factory PinVersion({
    required String id,
    required String title,
    required String content,
    required DateTime timestamp,
  }) = _PinVersion;

  /// Factory constructor for creating a PinVersion from JSON
  factory PinVersion.fromJson(Map<String, dynamic> json) =>
      _$PinVersionFromJson(json);
}

/// Pin model representing a pinned item on the board
@freezed
class Pin with _$Pin {
  const Pin._();

  /// Default constructor
  const factory Pin({
    required String id,
    required String title,
    required String content,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default('') String color,
    @Default(false) bool isPinned,
    @Default([]) List<String> tags,
    @Default(PinType.note) PinType type,
    @Default(false) bool isArchived,
    @Default(false) bool isProtected,
    @Default('') String password,
    @Default(PinPriority.medium) PinPriority priority,
    @Default([]) List<PinVersion> versionHistory,
  }) = _Pin;

  /// Create a new pin with default values
  factory Pin.create({
    required String title,
    required String content,
    String? color,
    List<String>? tags,
    PinType? type,
    PinPriority? priority,
  }) {
    final now = DateTime.now();
    return Pin(
      id: const Uuid().v4(),
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
      color: color ?? '',
      tags: tags ?? [],
      type: type ?? PinType.note,
      priority: priority ?? PinPriority.medium,
    );
  }

  /// Create a new version of this pin
  Pin createVersion() {
    final currentVersion = PinVersion(
      id: const Uuid().v4(),
      title: title,
      content: content,
      timestamp: updatedAt,
    );

    return copyWith(
      versionHistory: [...versionHistory, currentVersion],
    );
  }

  /// Restore a version from history
  Pin restoreVersion(String versionId) {
    final version = versionHistory.firstWhere(
      (v) => v.id == versionId,
      orElse: () => throw Exception('Version not found'),
    );

    return copyWith(
      title: version.title,
      content: version.content,
      updatedAt: DateTime.now(),
    );
  }

  /// Factory constructor for creating a Pin from JSON
  factory Pin.fromJson(Map<String, dynamic> json) => _$PinFromJson(json);
}

/// Pin type enum
enum PinType {
  /// Note type
  note,

  /// Task type
  task,

  /// Image type
  image,

  /// Link type
  link,
}

/// Pin priority enum
enum PinPriority {
  /// Low priority
  low,

  /// Medium priority
  medium,

  /// High priority
  high,

  /// Urgent priority
  urgent,
}

/// Extension methods for PinType
extension PinTypeExtension on PinType {
  /// Get the display name of the pin type
  String get displayName {
    switch (this) {
      case PinType.note:
        return 'Note';
      case PinType.task:
        return 'Task';
      case PinType.image:
        return 'Image';
      case PinType.link:
        return 'Link';
    }
  }

  /// Get the icon data for the pin type
  String get iconName {
    switch (this) {
      case PinType.note:
        return 'note';
      case PinType.task:
        return 'task';
      case PinType.image:
        return 'image';
      case PinType.link:
        return 'link';
    }
  }
}

/// Extension methods for PinPriority
extension PinPriorityExtension on PinPriority {
  /// Get the display name of the priority
  String get displayName {
    switch (this) {
      case PinPriority.low:
        return 'Low';
      case PinPriority.medium:
        return 'Medium';
      case PinPriority.high:
        return 'High';
      case PinPriority.urgent:
        return 'Urgent';
    }
  }

  /// Get the color for the priority
  String get color {
    switch (this) {
      case PinPriority.low:
        return 'blue';
      case PinPriority.medium:
        return 'green';
      case PinPriority.high:
        return 'orange';
      case PinPriority.urgent:
        return 'red';
    }
  }
}
