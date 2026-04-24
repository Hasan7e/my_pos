import 'package:hive_ce/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String barcode;

  @HiveField(2)
  String name;

  @HiveField(3)
  double? costPrice;

  @HiveField(4)
  double salePrice;

  @HiveField(5)
  double vatRate;

  @HiveField(6)
  int? stockAmount;

  Product({
    required this.id,
    required this.barcode,
    required this.name,
    this.costPrice,
    required this.salePrice,
    required this.vatRate,
    this.stockAmount,
  });
}
