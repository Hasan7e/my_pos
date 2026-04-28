import 'package:hive_ce/hive.dart';

part 'sale_line_item.g.dart';

@HiveType(typeId: 1)
class SaleLineItem extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String? barcode;

  @HiveField(2)
  int quantity;

  @HiveField(3)
  double unitPrice;

  @HiveField(4)
  double vatRate;

  SaleLineItem({
    required this.name,
    this.barcode,
    required this.quantity,
    required this.unitPrice,
    required this.vatRate,
  });

  double get lineTotal => quantity * unitPrice;
}
