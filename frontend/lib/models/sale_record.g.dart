// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaleRecordAdapter extends TypeAdapter<SaleRecord> {
  @override
  final typeId = 2;

  @override
  SaleRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleRecord(
      id: fields[0] as String,
      createdAt: fields[1] as DateTime,
      serverName: fields[2] as String,
      paymentMethod: fields[3] as String,
      total: (fields[4] as num).toDouble(),
      items: (fields[5] as List).cast<SaleLineItem>(),
      vatBreakdown: (fields[6] as Map).cast<String, double>(),
    );
  }

  @override
  void write(BinaryWriter writer, SaleRecord obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.serverName)
      ..writeByte(3)
      ..write(obj.paymentMethod)
      ..writeByte(4)
      ..write(obj.total)
      ..writeByte(5)
      ..write(obj.items)
      ..writeByte(6)
      ..write(obj.vatBreakdown);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
