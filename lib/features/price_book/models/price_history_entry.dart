import 'package:hive_flutter/hive_flutter.dart';

/// Historical log entry for tracking price fluctuations over time in the analytics graph.
@HiveType(typeId: 3)
class PriceHistoryEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double unitPrice;

  @HiveField(2)
  DateTime timestamp;

  @HiveField(3)
  String? note;

  PriceHistoryEntry({
    required this.id,
    required this.unitPrice,
    required this.timestamp,
    this.note,
  });
}

/// Manual TypeAdapter for PriceHistoryEntry to avoid unnecessary code generation.
class PriceHistoryEntryAdapter extends TypeAdapter<PriceHistoryEntry> {
  @override
  final int typeId = 3;

  @override
  PriceHistoryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PriceHistoryEntry(
      id: fields[0] as String,
      unitPrice: fields[1] as double,
      timestamp: fields[2] as DateTime,
      note: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PriceHistoryEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.unitPrice)
      ..writeByte(2)..write(obj.timestamp)
      ..writeByte(3)..write(obj.note);
  }
}
