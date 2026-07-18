import 'package:flutter_test/flutter_test.dart';
import 'package:my_pos/models/sale_line_item.dart';

void main() {
  group('SaleLineItem.lineTotal', () {
    test('multiplies the unit price by the quantity', () {
      final item = SaleLineItem(
        name: 'Coffee',
        barcode: '123456789',
        quantity: 3,
        unitPrice: 2.50,
        vatRate: 13.5,
      );

      expect(item.lineTotal, 7.50);
    });

    test('returns zero when the quantity is zero', () {
      final item = SaleLineItem(
        name: 'Coffee',
        quantity: 0,
        unitPrice: 2.50,
        vatRate: 13.5,
      );

      expect(item.lineTotal, 0);
    });
  });
}
