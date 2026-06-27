import 'package:hive_flutter/hive_flutter.dart';
import 'price_history_entry.dart';

/// Stored product or preset inside the Price Book.
@HiveType(typeId: 4)
class PriceBookItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String category;

  @HiveField(3)
  double currentUnitPrice;

  @HiveField(4)
  double baseWeightInGrams;

  @HiveField(5)
  List<PriceHistoryEntry> priceHistory;

  @HiveField(6)
  DateTime updatedAt;

  PriceBookItem({
    required this.id,
    required this.name,
    required this.category,
    required this.currentUnitPrice,
    required this.baseWeightInGrams,
    required this.priceHistory,
    required this.updatedAt,
  });

  String get unit => category;
  set unit(String value) => category = value;

  double get price => currentUnitPrice;
  set price(double value) => currentUnitPrice = value;
}

/// Manual TypeAdapter for PriceBookItem to avoid unnecessary code generation.
class PriceBookItemAdapter extends TypeAdapter<PriceBookItem> {
  @override
  final int typeId = 4;

  @override
  PriceBookItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PriceBookItem(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      currentUnitPrice: fields[3] as double,
      baseWeightInGrams: fields[4] as double,
      priceHistory: (fields[5] as List).cast<PriceHistoryEntry>(),
      updatedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PriceBookItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.name)
      ..writeByte(2)..write(obj.category)
      ..writeByte(3)..write(obj.currentUnitPrice)
      ..writeByte(4)..write(obj.baseWeightInGrams)
      ..writeByte(5)..write(obj.priceHistory)
      ..writeByte(6)..write(obj.updatedAt);
  }
}
