import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';

/// User configuration state persisted in Hive.
@HiveType(typeId: 5)
class SettingsModel extends HiveObject {
  @HiveField(0)
  String themeMode; // 'light', 'dark', 'system'

  @HiveField(1)
  String defaultCurrencyCode;

  @HiveField(2)
  String defaultWeightUnit;

  @HiveField(3)
  bool hapticsEnabled;

  SettingsModel({
    this.themeMode = 'system',
    this.defaultCurrencyCode = AppConstants.defaultCurrencyCode,
    this.defaultWeightUnit = AppConstants.defaultWeightUnit,
    this.hapticsEnabled = true,
  });
}

/// Manual TypeAdapter for SettingsModel to avoid unnecessary code generation.
class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 5;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsModel(
      themeMode: fields[0] as String? ?? 'system',
      defaultCurrencyCode: fields[1] as String? ?? AppConstants.defaultCurrencyCode,
      defaultWeightUnit: fields[2] as String? ?? AppConstants.defaultWeightUnit,
      hapticsEnabled: fields[3] as bool? ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)..write(obj.themeMode)
      ..writeByte(1)..write(obj.defaultCurrencyCode)
      ..writeByte(2)..write(obj.defaultWeightUnit)
      ..writeByte(3)..write(obj.hapticsEnabled);
  }
}
