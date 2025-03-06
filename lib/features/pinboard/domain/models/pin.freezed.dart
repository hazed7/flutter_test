// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pin.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PinVersion _$PinVersionFromJson(Map<String, dynamic> json) {
  return _PinVersion.fromJson(json);
}

/// @nodoc
mixin _$PinVersion {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this PinVersion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PinVersion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PinVersionCopyWith<PinVersion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PinVersionCopyWith<$Res> {
  factory $PinVersionCopyWith(
          PinVersion value, $Res Function(PinVersion) then) =
      _$PinVersionCopyWithImpl<$Res, PinVersion>;
  @useResult
  $Res call({String id, String title, String content, DateTime timestamp});
}

/// @nodoc
class _$PinVersionCopyWithImpl<$Res, $Val extends PinVersion>
    implements $PinVersionCopyWith<$Res> {
  _$PinVersionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PinVersion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? content = null,
    Object? timestamp = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PinVersionImplCopyWith<$Res>
    implements $PinVersionCopyWith<$Res> {
  factory _$$PinVersionImplCopyWith(
          _$PinVersionImpl value, $Res Function(_$PinVersionImpl) then) =
      __$$PinVersionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String title, String content, DateTime timestamp});
}

/// @nodoc
class __$$PinVersionImplCopyWithImpl<$Res>
    extends _$PinVersionCopyWithImpl<$Res, _$PinVersionImpl>
    implements _$$PinVersionImplCopyWith<$Res> {
  __$$PinVersionImplCopyWithImpl(
      _$PinVersionImpl _value, $Res Function(_$PinVersionImpl) _then)
      : super(_value, _then);

  /// Create a copy of PinVersion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? content = null,
    Object? timestamp = null,
  }) {
    return _then(_$PinVersionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PinVersionImpl implements _PinVersion {
  const _$PinVersionImpl(
      {required this.id,
      required this.title,
      required this.content,
      required this.timestamp});

  factory _$PinVersionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PinVersionImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String content;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'PinVersion(id: $id, title: $title, content: $content, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PinVersionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, content, timestamp);

  /// Create a copy of PinVersion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PinVersionImplCopyWith<_$PinVersionImpl> get copyWith =>
      __$$PinVersionImplCopyWithImpl<_$PinVersionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PinVersionImplToJson(
      this,
    );
  }
}

abstract class _PinVersion implements PinVersion {
  const factory _PinVersion(
      {required final String id,
      required final String title,
      required final String content,
      required final DateTime timestamp}) = _$PinVersionImpl;

  factory _PinVersion.fromJson(Map<String, dynamic> json) =
      _$PinVersionImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get content;
  @override
  DateTime get timestamp;

  /// Create a copy of PinVersion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PinVersionImplCopyWith<_$PinVersionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Pin _$PinFromJson(Map<String, dynamic> json) {
  return _Pin.fromJson(json);
}

/// @nodoc
mixin _$Pin {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get color => throw _privateConstructorUsedError;
  bool get isPinned => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  PinType get type => throw _privateConstructorUsedError;
  bool get isArchived => throw _privateConstructorUsedError;
  bool get isProtected => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  PinPriority get priority => throw _privateConstructorUsedError;
  List<PinVersion> get versionHistory => throw _privateConstructorUsedError;

  /// Serializes this Pin to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Pin
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PinCopyWith<Pin> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PinCopyWith<$Res> {
  factory $PinCopyWith(Pin value, $Res Function(Pin) then) =
      _$PinCopyWithImpl<$Res, Pin>;
  @useResult
  $Res call(
      {String id,
      String title,
      String content,
      DateTime createdAt,
      DateTime updatedAt,
      String color,
      bool isPinned,
      List<String> tags,
      PinType type,
      bool isArchived,
      bool isProtected,
      String password,
      PinPriority priority,
      List<PinVersion> versionHistory});
}

/// @nodoc
class _$PinCopyWithImpl<$Res, $Val extends Pin> implements $PinCopyWith<$Res> {
  _$PinCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Pin
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? content = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? color = null,
    Object? isPinned = null,
    Object? tags = null,
    Object? type = null,
    Object? isArchived = null,
    Object? isProtected = null,
    Object? password = null,
    Object? priority = null,
    Object? versionHistory = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
      isPinned: null == isPinned
          ? _value.isPinned
          : isPinned // ignore: cast_nullable_to_non_nullable
              as bool,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PinType,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      isProtected: null == isProtected
          ? _value.isProtected
          : isProtected // ignore: cast_nullable_to_non_nullable
              as bool,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as PinPriority,
      versionHistory: null == versionHistory
          ? _value.versionHistory
          : versionHistory // ignore: cast_nullable_to_non_nullable
              as List<PinVersion>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PinImplCopyWith<$Res> implements $PinCopyWith<$Res> {
  factory _$$PinImplCopyWith(_$PinImpl value, $Res Function(_$PinImpl) then) =
      __$$PinImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String content,
      DateTime createdAt,
      DateTime updatedAt,
      String color,
      bool isPinned,
      List<String> tags,
      PinType type,
      bool isArchived,
      bool isProtected,
      String password,
      PinPriority priority,
      List<PinVersion> versionHistory});
}

/// @nodoc
class __$$PinImplCopyWithImpl<$Res> extends _$PinCopyWithImpl<$Res, _$PinImpl>
    implements _$$PinImplCopyWith<$Res> {
  __$$PinImplCopyWithImpl(_$PinImpl _value, $Res Function(_$PinImpl) _then)
      : super(_value, _then);

  /// Create a copy of Pin
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? content = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? color = null,
    Object? isPinned = null,
    Object? tags = null,
    Object? type = null,
    Object? isArchived = null,
    Object? isProtected = null,
    Object? password = null,
    Object? priority = null,
    Object? versionHistory = null,
  }) {
    return _then(_$PinImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
      isPinned: null == isPinned
          ? _value.isPinned
          : isPinned // ignore: cast_nullable_to_non_nullable
              as bool,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PinType,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      isProtected: null == isProtected
          ? _value.isProtected
          : isProtected // ignore: cast_nullable_to_non_nullable
              as bool,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as PinPriority,
      versionHistory: null == versionHistory
          ? _value._versionHistory
          : versionHistory // ignore: cast_nullable_to_non_nullable
              as List<PinVersion>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PinImpl extends _Pin {
  const _$PinImpl(
      {required this.id,
      required this.title,
      required this.content,
      required this.createdAt,
      required this.updatedAt,
      this.color = '',
      this.isPinned = false,
      final List<String> tags = const [],
      this.type = PinType.note,
      this.isArchived = false,
      this.isProtected = false,
      this.password = '',
      this.priority = PinPriority.medium,
      final List<PinVersion> versionHistory = const []})
      : _tags = tags,
        _versionHistory = versionHistory,
        super._();

  factory _$PinImpl.fromJson(Map<String, dynamic> json) =>
      _$$PinImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String content;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey()
  final String color;
  @override
  @JsonKey()
  final bool isPinned;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  final PinType type;
  @override
  @JsonKey()
  final bool isArchived;
  @override
  @JsonKey()
  final bool isProtected;
  @override
  @JsonKey()
  final String password;
  @override
  @JsonKey()
  final PinPriority priority;
  final List<PinVersion> _versionHistory;
  @override
  @JsonKey()
  List<PinVersion> get versionHistory {
    if (_versionHistory is EqualUnmodifiableListView) return _versionHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_versionHistory);
  }

  @override
  String toString() {
    return 'Pin(id: $id, title: $title, content: $content, createdAt: $createdAt, updatedAt: $updatedAt, color: $color, isPinned: $isPinned, tags: $tags, type: $type, isArchived: $isArchived, isProtected: $isProtected, password: $password, priority: $priority, versionHistory: $versionHistory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PinImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.isPinned, isPinned) ||
                other.isPinned == isPinned) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            (identical(other.isProtected, isProtected) ||
                other.isProtected == isProtected) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            const DeepCollectionEquality()
                .equals(other._versionHistory, _versionHistory));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      content,
      createdAt,
      updatedAt,
      color,
      isPinned,
      const DeepCollectionEquality().hash(_tags),
      type,
      isArchived,
      isProtected,
      password,
      priority,
      const DeepCollectionEquality().hash(_versionHistory));

  /// Create a copy of Pin
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PinImplCopyWith<_$PinImpl> get copyWith =>
      __$$PinImplCopyWithImpl<_$PinImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PinImplToJson(
      this,
    );
  }
}

abstract class _Pin extends Pin {
  const factory _Pin(
      {required final String id,
      required final String title,
      required final String content,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final String color,
      final bool isPinned,
      final List<String> tags,
      final PinType type,
      final bool isArchived,
      final bool isProtected,
      final String password,
      final PinPriority priority,
      final List<PinVersion> versionHistory}) = _$PinImpl;
  const _Pin._() : super._();

  factory _Pin.fromJson(Map<String, dynamic> json) = _$PinImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get content;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String get color;
  @override
  bool get isPinned;
  @override
  List<String> get tags;
  @override
  PinType get type;
  @override
  bool get isArchived;
  @override
  bool get isProtected;
  @override
  String get password;
  @override
  PinPriority get priority;
  @override
  List<PinVersion> get versionHistory;

  /// Create a copy of Pin
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PinImplCopyWith<_$PinImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
