import 'package:hive_flutter/hive_flutter.dart';
import '../../calculator/models/calculation.dart';

/// Wrapper for saving past calculations in the History tab.
@HiveType(typeId: 2)
class HistoryItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  Calculation calculation;

  @HiveField(2)
  String? notes;

  @HiveField(3)
  DateTime recordedAt;

  HistoryItem({
    required this.id,
    required this.calculation,
    this.notes,
    required this.recordedAt,
  });
}

/// Manual TypeAdapter for HistoryItem to avoid unnecessary code generation.
class HistoryItemAdapter extends TypeAdapter<HistoryItem> {
  @override
  final int typeId = 2;

  @override
  HistoryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HistoryItem(
      id: fields[0] as String,
      calculation: fields[1] as Calculation,
      notes: fields[2] as String?,
      recordedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.calculation)
      ..writeByte(2)..write(obj.notes)
      ..writeByte(3)..write(obj.recordedAt);
  }
}
