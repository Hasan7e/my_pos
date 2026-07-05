import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:my_pos/models/receipt_record.dart';
import 'package:my_pos/models/return_record.dart';
import 'package:my_pos/models/sale_record.dart';

class SalesStore {
  SalesStore._();

  static final SalesStore instance = SalesStore._();

  Box<SaleRecord> get _salesBox => Hive.box<SaleRecord>('sales');
  Box<ReceiptRecord> get _receiptsBox => Hive.box<ReceiptRecord>('receipts');
  Box<ReturnRecord> get _returnsBox => Hive.box<ReturnRecord>('returns');

  ValueListenable<Box<SaleRecord>> salesListenable() => _salesBox.listenable();
  ValueListenable<Box<ReceiptRecord>> receiptsListenable() =>
      _receiptsBox.listenable();
  ValueListenable<Box<ReturnRecord>> returnsListenable() =>
      _returnsBox.listenable();

  List<SaleRecord> getSales() => _salesBox.values.toList().reversed.toList();

  List<ReceiptRecord> getReceipts() =>
      _receiptsBox.values.toList().reversed.toList();

  List<ReturnRecord> getReturns() =>
      _returnsBox.values.toList().reversed.toList();

  Future<void> saveSale(SaleRecord sale) async {
    await _salesBox.put(sale.id, sale);
    await _salesBox.flush();
  }

  Future<void> saveReceipt(ReceiptRecord receipt) async {
    await _receiptsBox.put(receipt.id, receipt);
    await _receiptsBox.flush();
  }

  ReceiptRecord? getReceipt(String id) => _receiptsBox.get(id);

  ReceiptRecord? getReceiptBySaleId(String saleId) {
    for (final receipt in _receiptsBox.values) {
      if (receipt.saleId == saleId) return receipt;
    }
    return null;
  }

  List<SaleRecord> searchSalesForReturn(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return [];

    final matchedSaleIds = <String>{};

    for (final receipt in _receiptsBox.values) {
      if (receipt.id.toLowerCase().contains(normalized) ||
          receipt.saleId.toLowerCase().contains(normalized)) {
        matchedSaleIds.add(receipt.saleId);
      }
    }

    return _salesBox.values.where((sale) {
      if (sale.id.toLowerCase().contains(normalized)) return true;
      if (matchedSaleIds.contains(sale.id)) return true;

      return sale.items.any((item) {
        final barcode = item.barcode?.toLowerCase() ?? '';
        return barcode.contains(normalized) ||
            item.name.toLowerCase().contains(normalized);
      });
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> saveReturn(ReturnRecord returnRecord) async {
    await _returnsBox.put(returnRecord.id, returnRecord);
    await _returnsBox.flush();
  }
}
