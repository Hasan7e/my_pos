import 'package:hive_ce/hive.dart';

part 'z_report_record.g.dart';

@HiveType(typeId: 7)
class ZReportRecord extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime startTime;

  @HiveField(2)
  DateTime endTime;

  @HiveField(3)
  DateTime? closedAt;

  @HiveField(4)
  int transactionCount;

  @HiveField(5)
  int itemsSold;

  @HiveField(6)
  double totalSales;

  @HiveField(7)
  double cashTotal;

  @HiveField(8)
  double cardTotal;

  @HiveField(9)
  Map<String, double> vatBreakdown;

  @HiveField(10)
  double? grossSales;

  @HiveField(11)
  double? refundTotal;

  @HiveField(12)
  int? returnCount;

  @HiveField(13)
  int? itemsReturned;

  @HiveField(14)
  String? closedBy;

  ZReportRecord({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.closedAt,
    required this.transactionCount,
    required this.itemsSold,
    required this.totalSales,
    required this.cashTotal,
    required this.cardTotal,
    required this.vatBreakdown,
    this.grossSales,
    this.refundTotal,
    this.returnCount,
    this.itemsReturned,
    this.closedBy,
  });

  double get averageSale =>
      transactionCount == 0 ? 0 : totalSales / transactionCount;

  double get effectiveGrossSales => grossSales ?? totalSales;

  double get effectiveRefundTotal => refundTotal ?? 0;

  int get effectiveReturnCount => returnCount ?? 0;

  int get effectiveItemsReturned => itemsReturned ?? 0;
}
