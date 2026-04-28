import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:my_pos/models/quick_sale_config.dart';

class QuickSaleStore {
  QuickSaleStore._();

  static final QuickSaleStore instance = QuickSaleStore._();

  Box<QuickSaleConfig> get _box => Hive.box<QuickSaleConfig>('quick_sales');

  ValueListenable<Box<QuickSaleConfig>> listenable() => _box.listenable();

  List<QuickSaleConfig> getButtons() {
    final buttons = _box.values.toList();
    if (buttons.isEmpty) {
      return [
        QuickSaleConfig(id: '1', label: 'Coffee', price: 3.50),
        QuickSaleConfig(id: '2', label: 'Tea', price: 2.80),
        QuickSaleConfig(id: '3', label: 'Sandwich', price: 5.20),
      ];
    }
    return buttons;
  }

  Future<void> ensureDefaults() async {
    if (_box.isNotEmpty) return;

    await _box.putAll({
      '1': QuickSaleConfig(id: '1', label: 'Coffee', price: 3.50),
      '2': QuickSaleConfig(id: '2', label: 'Tea', price: 2.80),
      '3': QuickSaleConfig(id: '3', label: 'Sandwich', price: 5.20),
    });
    await _box.flush();
  }

  Future<void> saveButton(QuickSaleConfig config) async {
    await _box.put(config.id, config);
    await _box.flush();
  }
}
