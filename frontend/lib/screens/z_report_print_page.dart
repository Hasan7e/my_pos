import 'package:flutter/material.dart';
import 'package:my_pos/data/receipt_settings_store.dart';
import 'package:my_pos/models/z_report_record.dart';

class ZReportPrintPage extends StatelessWidget {
  final ZReportRecord report;

  const ZReportPrintPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final receiptSettings = ReceiptSettingsStore.instance.getSettings();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Z Report'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Printing Z Report...')),
              );
            },
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
                  Text('From: ${report.startTime.toLocal()}'),
                  Text('To: ${report.endTime.toLocal()}'),
                  Text('Printed: ${DateTime.now().toLocal()}'),
                  if (report.closedAt != null)
                    Text('Closed: ${report.closedAt!.toLocal()}'),
                  const Divider(height: 24),
                  _ThermalReportRow(
                    label: 'Total Sales',
                    value: '€${report.totalSales.toStringAsFixed(2)}',
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
                    label: 'Average Sale',
                    value: '€${report.averageSale.toStringAsFixed(2)}',
                  ),
                  const Divider(height: 24),
                  const Text(
                    'Payment Breakdown',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _ThermalReportRow(
                    label: 'Cash',
                    value: '€${report.cashTotal.toStringAsFixed(2)}',
                  ),
                  _ThermalReportRow(
                    label: 'Card',
                    value: '€${report.cardTotal.toStringAsFixed(2)}',
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
                      value: '€${entry.value.toStringAsFixed(2)}',
                    ),
                  ),
                  const Divider(height: 24),
                  const Text(
                    'Z Report closes the trading period.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Printing Z Report...')),
                      );
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Print Copy'),
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
