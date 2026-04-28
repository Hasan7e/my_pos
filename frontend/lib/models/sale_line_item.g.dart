// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_line_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaleLineItemAdapter extends TypeAdapter<SaleLineItem> {
  @override
  final typeId = 1;

  @override
  SaleLineItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleLineItem(
      name: fields[0] as String,
      barcode: fields[1] as String?,
      quantity: (fields[2] as num).toInt(),
      unitPrice: (fields[3] as num).toDouble(),
      vatRate: (fields[4] as num).toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, SaleLineItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.barcode)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.unitPrice)
      ..writeByte(4)
      ..write(obj.vatRate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleLineItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
