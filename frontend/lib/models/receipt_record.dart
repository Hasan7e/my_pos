import 'package:hive_ce/hive.dart';
import 'sale_line_item.dart';

part 'receipt_record.g.dart';

@HiveType(typeId: 3)
class ReceiptRecord extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String saleId;

  @HiveField(2)
  String shopName;

  @HiveField(3)
  String shopAddress;

  @HiveField(4)
  String vatNumber;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  String serverName;

  @HiveField(7)
  String paymentMethod;

  @HiveField(8)
  double total;

  @HiveField(9)
  List<SaleLineItem> items;

  @HiveField(10)
  Map<String, double> vatBreakdown;

  ReceiptRecord({
    required this.id,
    required this.saleId,
    required this.shopName,
    required this.shopAddress,
    required this.vatNumber,
    required this.createdAt,
    required this.serverName,
    required this.paymentMethod,
    required this.total,
    required this.items,
    required this.vatBreakdown,
  });
}
