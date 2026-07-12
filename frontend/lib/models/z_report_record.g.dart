// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'z_report_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ZReportRecordAdapter extends TypeAdapter<ZReportRecord> {
  @override
  final typeId = 7;

  @override
  ZReportRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ZReportRecord(
      id: fields[0] as String,
      startTime: fields[1] as DateTime,
      endTime: fields[2] as DateTime,
      closedAt: fields[3] as DateTime?,
      transactionCount: (fields[4] as num).toInt(),
      itemsSold: (fields[5] as num).toInt(),
      totalSales: (fields[6] as num).toDouble(),
      cashTotal: (fields[7] as num).toDouble(),
      cardTotal: (fields[8] as num).toDouble(),
      vatBreakdown: (fields[9] as Map).cast<String, double>(),
      grossSales: (fields[10] as num?)?.toDouble(),
      refundTotal: (fields[11] as num?)?.toDouble(),
      returnCount: (fields[12] as num?)?.toInt(),
      itemsReturned: (fields[13] as num?)?.toInt(),
      closedBy: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ZReportRecord obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.closedAt)
      ..writeByte(4)
      ..write(obj.transactionCount)
      ..writeByte(5)
      ..write(obj.itemsSold)
      ..writeByte(6)
      ..write(obj.totalSales)
      ..writeByte(7)
      ..write(obj.cashTotal)
      ..writeByte(8)
      ..write(obj.cardTotal)
      ..writeByte(9)
      ..write(obj.vatBreakdown)
      ..writeByte(10)
      ..write(obj.grossSales)
      ..writeByte(11)
      ..write(obj.refundTotal)
      ..writeByte(12)
      ..write(obj.returnCount)
      ..writeByte(13)
      ..write(obj.itemsReturned)
      ..writeByte(14)
      ..write(obj.closedBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZReportRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
