import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:my_pos/models/receipt_record.dart';
import 'package:my_pos/models/sale_record.dart';

class SalesStore {
  SalesStore._();

  static final SalesStore instance = SalesStore._();

  Box<SaleRecord> get _salesBox => Hive.box<SaleRecord>('sales');
  Box<ReceiptRecord> get _receiptsBox => Hive.box<ReceiptRecord>('receipts');

  ValueListenable<Box<SaleRecord>> salesListenable() => _salesBox.listenable();
  ValueListenable<Box<ReceiptRecord>> receiptsListenable() =>
      _receiptsBox.listenable();

  List<SaleRecord> getSales() => _salesBox.values.toList().reversed.toList();

  List<ReceiptRecord> getReceipts() =>
      _receiptsBox.values.toList().reversed.toList();

  Future<void> saveSale(SaleRecord sale) async {
    await _salesBox.put(sale.id, sale);
    await _salesBox.flush();
  }

  Future<void> saveReceipt(ReceiptRecord receipt) async {
    await _receiptsBox.put(receipt.id, receipt);
    await _receiptsBox.flush();
  }

  ReceiptRecord? getReceipt(String id) => _receiptsBox.get(id);
}
