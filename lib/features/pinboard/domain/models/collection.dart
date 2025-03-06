import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'collection.freezed.dart';
part 'collection.g.dart';

/// Collection model for organizing pins
@freezed
class Collection with _$Collection {
  const Collection._();

  /// Default constructor
  const factory Collection({
    required String id,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default('') String color,
    @Default('') String icon,
    @Default([]) List<String> pinIds,
    @Default('') String description,
  }) = _Collection;

  /// Create a new collection with default values
  factory Collection.create({
    required String name,
    String? color,
    String? icon,
    String? description,
  }) {
    final now = DateTime.now();
    return Collection(
      id: const Uuid().v4(),
      name: name,
      createdAt: now,
      updatedAt: now,
      color: color ?? '',
      icon: icon ?? 'folder',
      description: description ?? '',
    );
  }

  /// Factory constructor for creating a Collection from JSON
  factory Collection.fromJson(Map<String, dynamic> json) =>
      _$CollectionFromJson(json);
}
