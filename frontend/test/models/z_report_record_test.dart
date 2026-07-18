import 'package:flutter_test/flutter_test.dart';
import 'package:my_pos/models/z_report_record.dart';

void main() {
  ZReportRecord buildReport({
    int transactionCount = 4,
    double totalSales = 100,
    double? grossSales,
    double? refundTotal,
  }) {
    return ZReportRecord(
      id: 'z-001',
      startTime: DateTime(2026, 7, 12, 9),
      endTime: DateTime(2026, 7, 12, 17),
      closedAt: DateTime(2026, 7, 12, 17),
      transactionCount: transactionCount,
      itemsSold: 10,
      totalSales: totalSales,
      cashTotal: 60,
      cardTotal: 40,
      vatBreakdown: const {'13.5': 11.89},
      grossSales: grossSales,
      refundTotal: refundTotal,
    );
  }

  group('ZReportRecord', () {
    test('calculates the average sale from net sales', () {
      expect(buildReport().averageSale, 25);
    });

    test('uses zero as the average when there are no transactions', () {
      expect(buildReport(transactionCount: 0).averageSale, 0);
    });

    test('uses legacy totals when optional refund fields are absent', () {
      final report = buildReport();

      expect(report.effectiveGrossSales, 100);
      expect(report.effectiveRefundTotal, 0);
      expect(report.effectiveReturnCount, 0);
      expect(report.effectiveItemsReturned, 0);
    });

    test('uses recorded gross and refund totals when present', () {
      final report = buildReport(grossSales: 125, refundTotal: 25);

      expect(report.effectiveGrossSales, 125);
      expect(report.effectiveRefundTotal, 25);
    });
  });
}
