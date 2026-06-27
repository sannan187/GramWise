import 'package:hive_flutter/hive_flutter.dart';

/// Represents an active or recorded calculation operation.
@HiveType(typeId: 1)
class Calculation extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double unitPrice;

  @HiveField(2)
  double unitWeightInGrams;

  @HiveField(3)
  double targetWeightInGrams;

  @HiveField(4)
  double calculatedPrice;

  @HiveField(5)
  DateTime timestamp;

  Calculation({
    required this.id,
    required this.unitPrice,
    required this.unitWeightInGrams,
    required this.targetWeightInGrams,
    required this.calculatedPrice,
    required this.timestamp,
  });
}

/// Manual TypeAdapter for Calculation to avoid unnecessary code generation.
class CalculationAdapter extends TypeAdapter<Calculation> {
  @override
  final int typeId = 1;

  @override
  Calculation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Calculation(
      id: fields[0] as String,
      unitPrice: fields[1] as double,
      unitWeightInGrams: fields[2] as double,
      targetWeightInGrams: fields[3] as double,
      calculatedPrice: fields[4] as double,
      timestamp: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Calculation obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.unitPrice)
      ..writeByte(2)..write(obj.unitWeightInGrams)
      ..writeByte(3)..write(obj.targetWeightInGrams)
      ..writeByte(4)..write(obj.calculatedPrice)
      ..writeByte(5)..write(obj.timestamp);
  }
}
