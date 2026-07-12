import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:my_pos/data/app_settings_store.dart';
import 'package:my_pos/data/receipt_settings_store.dart';
import 'package:my_pos/models/z_report_record.dart';
import 'package:my_pos/services/z_report_pdf_service.dart';
import 'package:printing/printing.dart';

class ZReportPrintPage extends StatelessWidget {
  final ZReportRecord report;

  const ZReportPrintPage({super.key, required this.report});

  String get _fileName => 'z-report-${report.id}.pdf';

  Future<void> _print(BuildContext context) async {
    try {
      await Printing.layoutPdf(
        name: _fileName,
        onLayout: (_) => ZReportPdfService.buildPdf(report),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open the print dialog.')),
        );
      }
    }
  }

  Future<void> _savePdf(BuildContext context) async {
    try {
      final bytes = await ZReportPdfService.buildPdf(report);
      final location = await getSaveLocation(
        suggestedName: _fileName,
        acceptedTypeGroups: const [
          XTypeGroup(label: 'PDF documents', extensions: ['pdf']),
        ],
      );
      if (location == null) return;

      await XFile.fromData(
        bytes,
        mimeType: 'application/pdf',
        name: _fileName,
      ).saveTo(location.path);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to save the PDF.')),
        );
      }
    }
  }

  Future<void> _sharePdf(BuildContext context) async {
    try {
      await Printing.sharePdf(
        bytes: await ZReportPdfService.buildPdf(report),
        filename: _fileName,
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to share the PDF.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final receiptSettings = ReceiptSettingsStore.instance.getSettings();
    final appSettings = AppSettingsStore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Z Report'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _print(context),
            icon: const Icon(Icons.print),
            tooltip: 'Print Z Report',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  Text(
                    receiptSettings.shopName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    receiptSettings.shopAddress,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'VAT No: ${receiptSettings.vatNumber}',
                    textAlign: TextAlign.center,
                  ),
                  const Divider(height: 24),
                  const Text(
                    'Z REPORT',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text('Report No: ${report.id}'),
                  Text('From: ${appSettings.formatDateTime(report.startTime)}'),
                  Text('To: ${appSettings.formatDateTime(report.endTime)}'),
                  Text(
                    'Printed: ${appSettings.formatDateTime(DateTime.now())}',
                  ),
                  if (report.closedAt != null)
                    Text(
                      'Closed: ${appSettings.formatDateTime(report.closedAt!)}',
                    ),
                  if (report.closedBy?.trim().isNotEmpty == true)
                    Text('Closed by: ${report.closedBy}'),
                  const Divider(height: 24),
                  _ThermalReportRow(
                    label: 'Gross Sales',
                    value: appSettings.formatMoney(report.effectiveGrossSales),
                  ),
                  _ThermalReportRow(
                    label: 'Refunds',
                    value: appSettings.formatMoney(report.effectiveRefundTotal),
                  ),
                  _ThermalReportRow(
                    label: 'Net Sales',
                    value: appSettings.formatMoney(report.totalSales),
                    isStrong: true,
                  ),
                  _ThermalReportRow(
                    label: 'Transactions',
                    value: report.transactionCount.toString(),
                  ),
                  _ThermalReportRow(
                    label: 'Items Sold',
                    value: report.itemsSold.toString(),
                  ),
                  _ThermalReportRow(
                    label: 'Returns',
                    value: report.effectiveReturnCount.toString(),
                  ),
                  _ThermalReportRow(
                    label: 'Items Returned',
                    value: report.effectiveItemsReturned.toString(),
                  ),
                  _ThermalReportRow(
                    label: 'Average Sale',
                    value: appSettings.formatMoney(report.averageSale),
                  ),
                  const Divider(height: 24),
                  const Text(
                    'Payment Breakdown',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _ThermalReportRow(
                    label: 'Cash',
                    value: appSettings.formatMoney(report.cashTotal),
                  ),
                  _ThermalReportRow(
                    label: 'Card',
                    value: appSettings.formatMoney(report.cardTotal),
                  ),
                  const Divider(height: 24),
                  const Text(
                    'VAT Breakdown',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...report.vatBreakdown.entries.map(
                    (entry) => _ThermalReportRow(
                      label: 'VAT ${entry.key}%',
                      value: appSettings.formatMoney(entry.value),
                    ),
                  ),
                  const Divider(height: 24),
                  const Text(
                    'Z Report closes the trading period.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => _print(context),
                    icon: const Icon(Icons.print),
                    label: const Text('Print / Thermal Printer'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _savePdf(context),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('Save PDF'),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => _sharePdf(context),
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Share PDF'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThermalReportRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isStrong;

  const _ThermalReportRow({
    required this.label,
    required this.value,
    this.isStrong = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: isStrong ? FontWeight.bold : FontWeight.normal,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
