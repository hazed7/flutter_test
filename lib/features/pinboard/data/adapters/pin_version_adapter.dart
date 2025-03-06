import 'package:hive/hive.dart';

import '../../domain/models/pin.dart';

/// Adapter for PinVersion to work with Hive
class PinVersionAdapter extends TypeAdapter<PinVersion> {
  @override
  final int typeId = 2; // Use a unique type ID

  @override
  PinVersion read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final content = reader.readString();
    final timestamp = DateTime.fromMillisecondsSinceEpoch(reader.readInt());

    return PinVersion(
      id: id,
      title: title,
      content: content,
      timestamp: timestamp,
    );
  }

  @override
  void write(BinaryWriter writer, PinVersion obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.content);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
  }
}
