// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'return_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReturnRecordAdapter extends TypeAdapter<ReturnRecord> {
  @override
  final typeId = 9;

  @override
  ReturnRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReturnRecord(
      id: fields[0] as String,
      originalSaleId: fields[1] as String,
      originalReceiptId: fields[2] as String?,
      createdAt: fields[3] as DateTime,
      managerName: fields[4] as String,
      refundMethod: fields[5] as String,
      reason: fields[6] as String,
      refundTotal: (fields[7] as num).toDouble(),
      items: (fields[8] as List).cast<ReturnLineItem>(),
    );
  }

  @override
  void write(BinaryWriter writer, ReturnRecord obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.originalSaleId)
      ..writeByte(2)
      ..write(obj.originalReceiptId)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.managerName)
      ..writeByte(5)
      ..write(obj.refundMethod)
      ..writeByte(6)
      ..write(obj.reason)
      ..writeByte(7)
      ..write(obj.refundTotal)
      ..writeByte(8)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReturnRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
