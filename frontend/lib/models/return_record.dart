import 'package:hive_ce/hive.dart';
import 'return_line_item.dart';

part 'return_record.g.dart';

@HiveType(typeId: 9)
class ReturnRecord extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String originalSaleId;

  @HiveField(2)
  String? originalReceiptId;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  String managerName;

  @HiveField(5)
  String refundMethod;

  @HiveField(6)
  String reason;

  @HiveField(7)
  double refundTotal;

  @HiveField(8)
  List<ReturnLineItem> items;

  ReturnRecord({
    required this.id,
    required this.originalSaleId,
    this.originalReceiptId,
    required this.createdAt,
    required this.managerName,
    required this.refundMethod,
    required this.reason,
    required this.refundTotal,
    required this.items,
  });
}
