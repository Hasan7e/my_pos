import 'package:hive_ce/hive.dart';

part 'quick_sale_config.g.dart';

@HiveType(typeId: 4)
class QuickSaleConfig extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String label;

  @HiveField(2)
  double price;

  QuickSaleConfig({required this.id, required this.label, required this.price});
}
