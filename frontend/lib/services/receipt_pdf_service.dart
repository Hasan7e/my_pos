import 'dart:typed_data';

import 'package:my_pos/data/app_settings_store.dart';
import 'package:my_pos/data/receipt_settings_store.dart';
import 'package:my_pos/models/receipt_record.dart';
import 'package:my_pos/services/pdf_font_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReceiptPdfService {
  ReceiptPdfService._();

  static Future<Uint8List> buildPdf(ReceiptRecord receipt) async {
    final appSettings = AppSettingsStore.instance;
    final receiptSettings = ReceiptSettingsStore.instance.getSettings();
    final document = pw.Document(theme: await PdfFontService.buildTheme());

    document.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          80 * PdfPageFormat.mm,
          double.infinity,
          marginAll: 5 * PdfPageFormat.mm,
        ),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Text(
              receipt.shopName,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            _center(receipt.shopAddress),
            _center('VAT No: ${receipt.vatNumber}'),
            _divider(),
            _text('Receipt No: ${receipt.id}'),
            _text('Sale ID: ${receipt.saleId}'),
            _text(
              'Date/Time: ${appSettings.formatDateTime(receipt.createdAt)}',
            ),
            _text('Server: ${receipt.serverName}'),
            _divider(),
            ...receipt.items.map(
              (item) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(item.name, style: const pw.TextStyle(fontSize: 9)),
                    _row(
                      '${item.quantity} x ${appSettings.formatMoney(item.unitPrice)}',
                      appSettings.formatMoney(item.lineTotal),
                    ),
                  ],
                ),
              ),
            ),
            _divider(),
            _row(
              'Total',
              appSettings.formatMoney(receipt.total),
              isStrong: true,
            ),
            _text('Payment: ${receipt.paymentMethod}'),
            _divider(),
            _sectionTitle('VAT Breakdown'),
            ...receipt.vatBreakdown.entries.map(
              (entry) => _row(
                'VAT ${entry.key}%',
                appSettings.formatMoney(entry.value),
              ),
            ),
            if (receiptSettings.footerMessage.trim().isNotEmpty) ...[
              _divider(),
              pw.Text(
                receiptSettings.footerMessage,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return document.save();
  }

  static pw.Widget _center(String value) => pw.Text(
    value,
    textAlign: pw.TextAlign.center,
    style: const pw.TextStyle(fontSize: 9),
  );

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
