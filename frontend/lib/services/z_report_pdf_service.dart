import 'dart:typed_data';

import 'package:my_pos/data/app_settings_store.dart';
import 'package:my_pos/data/receipt_settings_store.dart';
import 'package:my_pos/models/z_report_record.dart';
import 'package:my_pos/services/pdf_font_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ZReportPdfService {
  ZReportPdfService._();

  static Future<Uint8List> buildPdf(ZReportRecord report) async {
    final receiptSettings = ReceiptSettingsStore.instance.getSettings();
    final appSettings = AppSettingsStore.instance;
    final document = pw.Document(theme: await PdfFontService.buildTheme());

    document.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          80 * PdfPageFormat.mm,
          double.infinity,
          marginAll: 5 * PdfPageFormat.mm,
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Text(
                receiptSettings.shopName,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                receiptSettings.shopAddress,
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                'VAT No: ${receiptSettings.vatNumber}',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 9),
              ),
              _divider(),
              pw.Text(
                'Z REPORT',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              _text('Report No: ${report.id}'),
              _text('From: ${appSettings.formatDateTime(report.startTime)}'),
              _text('To: ${appSettings.formatDateTime(report.endTime)}'),
              _text('Printed: ${appSettings.formatDateTime(DateTime.now())}'),
              if (report.closedAt != null)
                _text(
                  'Closed: ${appSettings.formatDateTime(report.closedAt!)}',
                ),
              if (report.closedBy?.trim().isNotEmpty == true)
                _text('Closed by: ${report.closedBy}'),
              _divider(),
              _row(
                'Gross Sales',
                appSettings.formatMoney(report.effectiveGrossSales),
              ),
              _row(
                'Refunds',
                appSettings.formatMoney(report.effectiveRefundTotal),
              ),
              _row(
                'Net Sales',
                appSettings.formatMoney(report.totalSales),
                isStrong: true,
              ),
              _row('Transactions', report.transactionCount.toString()),
              _row('Items Sold', report.itemsSold.toString()),
              _row('Returns', report.effectiveReturnCount.toString()),
              _row('Items Returned', report.effectiveItemsReturned.toString()),
              _row('Average Sale', appSettings.formatMoney(report.averageSale)),
              _divider(),
              _sectionTitle('Payment Breakdown'),
              _row('Cash', appSettings.formatMoney(report.cashTotal)),
              _row('Card', appSettings.formatMoney(report.cardTotal)),
              _divider(),
              _sectionTitle('VAT Breakdown'),
              ...report.vatBreakdown.entries.map(
                (entry) => _row(
                  'VAT ${entry.key}%',
                  appSettings.formatMoney(entry.value),
                ),
              ),
              _divider(),
              pw.Text(
                'Z Report closes the trading period.',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 8),
              ),
            ],
          );
        },
      ),
    );

    return document.save();
  }

  static pw.Widget _text(String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 3),
    child: pw.Text(value, style: const pw.TextStyle(fontSize: 9)),
  );

  static pw.Widget _sectionTitle(String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Text(
      value,
      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
    ),
  );

  static pw.Widget _row(String label, String value, {bool isStrong = false}) {
    final style = pw.TextStyle(
      fontSize: 9,
      fontWeight: isStrong ? pw.FontWeight.bold : pw.FontWeight.normal,
    );
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Text(label, style: style)),
          pw.Text(value, style: style),
        ],
      ),
    );
  }

  static pw.Widget _divider() => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 6),
    child: pw.Divider(thickness: 0.7),
  );
}
