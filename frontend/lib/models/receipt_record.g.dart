// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReceiptRecordAdapter extends TypeAdapter<ReceiptRecord> {
  @override
  final typeId = 3;

  @override
  ReceiptRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReceiptRecord(
      id: fields[0] as String,
      saleId: fields[1] as String,
      shopName: fields[2] as String,
      shopAddress: fields[3] as String,
      vatNumber: fields[4] as String,
      createdAt: fields[5] as DateTime,
      serverName: fields[6] as String,
      paymentMethod: fields[7] as String,
      total: (fields[8] as num).toDouble(),
      items: (fields[9] as List).cast<SaleLineItem>(),
      vatBreakdown: (fields[10] as Map).cast<String, double>(),
    );
  }

  @override
  void write(BinaryWriter writer, ReceiptRecord obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.saleId)
      ..writeByte(2)
      ..write(obj.shopName)
      ..writeByte(3)
      ..write(obj.shopAddress)
      ..writeByte(4)
      ..write(obj.vatNumber)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.serverName)
      ..writeByte(7)
      ..write(obj.paymentMethod)
      ..writeByte(8)
      ..write(obj.total)
      ..writeByte(9)
      ..write(obj.items)
      ..writeByte(10)
      ..write(obj.vatBreakdown);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceiptRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
