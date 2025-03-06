// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PinVersionImpl _$$PinVersionImplFromJson(Map<String, dynamic> json) =>
    _$PinVersionImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$PinVersionImplToJson(_$PinVersionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
    };

_$PinImpl _$$PinImplFromJson(Map<String, dynamic> json) => _$PinImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      color: json['color'] as String? ?? '',
      isPinned: json['isPinned'] as bool? ?? false,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      type: $enumDecodeNullable(_$PinTypeEnumMap, json['type']) ?? PinType.note,
      isArchived: json['isArchived'] as bool? ?? false,
      isProtected: json['isProtected'] as bool? ?? false,
      password: json['password'] as String? ?? '',
      priority: $enumDecodeNullable(_$PinPriorityEnumMap, json['priority']) ??
          PinPriority.medium,
      versionHistory: (json['versionHistory'] as List<dynamic>?)
              ?.map((e) => PinVersion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$PinImplToJson(_$PinImpl instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'color': instance.color,
      'isPinned': instance.isPinned,
      'tags': instance.tags,
      'type': _$PinTypeEnumMap[instance.type]!,
      'isArchived': instance.isArchived,
      'isProtected': instance.isProtected,
      'password': instance.password,
      'priority': _$PinPriorityEnumMap[instance.priority]!,
      'versionHistory': instance.versionHistory,
    };

const _$PinTypeEnumMap = {
  PinType.note: 'note',
  PinType.task: 'task',
  PinType.image: 'image',
  PinType.link: 'link',
};

const _$PinPriorityEnumMap = {
  PinPriority.low: 'low',
  PinPriority.medium: 'medium',
  PinPriority.high: 'high',
  PinPriority.urgent: 'urgent',
};
