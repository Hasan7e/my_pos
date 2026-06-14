import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:my_pos/data/receipt_settings_store.dart';
import 'package:my_pos/data/report_store.dart';
import 'package:my_pos/data/sales_store.dart';
import 'package:my_pos/models/sale_line_item.dart';
import 'package:my_pos/models/sale_record.dart';

class XReportPage extends StatelessWidget {
  const XReportPage({super.key});

  void _openPrintPreview(BuildContext context, _XReportData report) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _XReportPrintPage(report: report)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('X Report'), centerTitle: true),
      body: ValueListenableBuilder<Box<SaleRecord>>(
        valueListenable: SalesStore.instance.salesListenable(),
        builder: (context, box, _) {
          final periodSales = ReportStore.instance.getCurrentPeriodSales(
            SalesStore.instance.getSales(),
          );
          final report = _XReportData.fromSales(periodSales);

          if (report.transactionCount == 0) {
            return const Center(child: Text('No sales recorded yet'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ReportHeader(report: report),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _openPrintPreview(context, report),
                icon: const Icon(Icons.print),
                label: const Text('Print X Report'),
              ),
              const SizedBox(height: 16),
              _SummaryGrid(report: report),
              const SizedBox(height: 16),
              _ReportSection(
                title: 'Payment Breakdown',
                children: [
                  _ReportRow(
                    label: 'Cash',
                    value: '€${report.cashTotal.toStringAsFixed(2)}',
                  ),
                  _ReportRow(
                    label: 'Card',
                    value: '€${report.cardTotal.toStringAsFixed(2)}',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ReportSection(
                title: 'VAT Breakdown',
                children: report.vatBreakdown.entries.map((entry) {
                  return _ReportRow(
                    label: 'VAT ${entry.key}%',
                    value: '€${entry.value.toStringAsFixed(2)}',
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              _ReportSection(
                title: 'Sales By Item',
                children: report.itemSummaries.map((item) {
                  return _ReportRow(
                    label: '${item.name} x${item.quantity}',
                    value: '€${item.total.toStringAsFixed(2)}',
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _XReportPrintPage extends StatelessWidget {
  final _XReportData report;

  const _XReportPrintPage({required this.report});

  @override
  Widget build(BuildContext context) {
    final receiptSettings = ReceiptSettingsStore.instance.getSettings();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Print X Report'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Printing X Report...')),
              );
            },
            icon: const Icon(Icons.print),
            tooltip: 'Print X Report',
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
                    'X REPORT',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text('From: ${report.startTime.toLocal()}'),
                  Text('To: ${report.endTime.toLocal()}'),
                  Text('Printed: ${DateTime.now().toLocal()}'),
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
                    'X Report only. Trading period remains open.',
                    textAlign: TextAlign.center,
                  ),
                  if (receiptSettings.footerMessage.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      receiptSettings.footerMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Printing X Report...')),
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

class _ReportHeader extends StatelessWidget {
  final _XReportData report;

  const _ReportHeader({required this.report});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Trading Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('From: ${report.startTime.toLocal()}'),
            Text('To: ${report.endTime.toLocal()}'),
            const SizedBox(height: 8),
            const Text(
              'This report does not close or reset the trading period.',
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final _XReportData report;

  const _SummaryGrid({required this.report});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.4,
      children: [
        _SummaryTile(
          label: 'Total Sales',
          value: '€${report.totalSales.toStringAsFixed(2)}',
        ),
        _SummaryTile(
          label: 'Transactions',
          value: report.transactionCount.toString(),
        ),
        _SummaryTile(label: 'Items Sold', value: report.itemsSold.toString()),
        _SummaryTile(
          label: 'Average Sale',
          value: '€${report.averageSale.toStringAsFixed(2)}',
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ReportSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (children.isEmpty)
              const Text('No data available')
            else
              ...children,
          ],
        ),
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReportRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _XReportData {
  final DateTime startTime;
  final DateTime endTime;
  final int transactionCount;
  final int itemsSold;
  final double totalSales;
  final double cashTotal;
  final double cardTotal;
  final Map<String, double> vatBreakdown;
  final List<_ItemSummary> itemSummaries;

  const _XReportData({
    required this.startTime,
    required this.endTime,
    required this.transactionCount,
    required this.itemsSold,
    required this.totalSales,
    required this.cashTotal,
    required this.cardTotal,
    required this.vatBreakdown,
    required this.itemSummaries,
  });

  double get averageSale =>
      transactionCount == 0 ? 0 : totalSales / transactionCount;

  factory _XReportData.fromSales(List<SaleRecord> sales) {
    final sortedSales = sales.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final now = DateTime.now();
    final Map<String, double> vatBreakdown = {};
    final Map<String, _ItemSummary> itemMap = {};
    var totalSales = 0.0;
    var cashTotal = 0.0;
    var cardTotal = 0.0;
    var itemsSold = 0;

    for (final sale in sortedSales) {
      totalSales += sale.total;
      if (sale.paymentMethod.toLowerCase() == 'cash') {
        cashTotal += sale.total;
      } else if (sale.paymentMethod.toLowerCase() == 'card') {
        cardTotal += sale.total;
      }

      for (final entry in sale.vatBreakdown.entries) {
        vatBreakdown[entry.key] = (vatBreakdown[entry.key] ?? 0) + entry.value;
      }

      for (final item in sale.items) {
        itemsSold += item.quantity;
        final key = '${item.name}|${item.unitPrice}|${item.vatRate}';
        final existing = itemMap[key];
        if (existing == null) {
          itemMap[key] = _ItemSummary.fromLineItem(item);
        } else {
          existing.quantity += item.quantity;
          existing.total += item.lineTotal;
        }
      }
    }

    return _XReportData(
      startTime: sortedSales.isEmpty ? now : sortedSales.first.createdAt,
      endTime: sortedSales.isEmpty ? now : sortedSales.last.createdAt,
      transactionCount: sortedSales.length,
      itemsSold: itemsSold,
      totalSales: totalSales,
      cashTotal: cashTotal,
      cardTotal: cardTotal,
      vatBreakdown: vatBreakdown,
      itemSummaries: itemMap.values.toList()
        ..sort((a, b) => b.total.compareTo(a.total)),
    );
  }
}

class _ItemSummary {
  final String name;
  int quantity;
  double total;

  _ItemSummary({
    required this.name,
    required this.quantity,
    required this.total,
  });

  factory _ItemSummary.fromLineItem(SaleLineItem item) {
    return _ItemSummary(
      name: item.name,
      quantity: item.quantity,
      total: item.lineTotal,
    );
  }
}
