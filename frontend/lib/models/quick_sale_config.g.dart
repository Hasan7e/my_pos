// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quick_sale_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuickSaleConfigAdapter extends TypeAdapter<QuickSaleConfig> {
  @override
  final typeId = 4;

  @override
  QuickSaleConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuickSaleConfig(
      id: fields[0] as String,
      label: fields[1] as String,
      price: (fields[2] as num).toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, QuickSaleConfig obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.price);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuickSaleConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
