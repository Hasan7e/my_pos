import 'package:hive_ce/hive.dart';
import 'sale_line_item.dart';

part 'sale_record.g.dart';

@HiveType(typeId: 2)
class SaleRecord extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  String serverName;

  @HiveField(3)
  String paymentMethod;

  @HiveField(4)
  double total;

  @HiveField(5)
  List<SaleLineItem> items;

  @HiveField(6)
  Map<String, double> vatBreakdown;

  SaleRecord({
    required this.id,
    required this.createdAt,
    required this.serverName,
    required this.paymentMethod,
    required this.total,
    required this.items,
    required this.vatBreakdown,
  });
}
