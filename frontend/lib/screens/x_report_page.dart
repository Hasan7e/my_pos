import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:my_pos/data/app_settings_store.dart';
import 'package:my_pos/data/receipt_settings_store.dart';
import 'package:my_pos/data/report_store.dart';
import 'package:my_pos/data/sales_store.dart';
import 'package:my_pos/models/return_record.dart';
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
        builder: (context, salesBox, _) {
          return ValueListenableBuilder<Box<ReturnRecord>>(
            valueListenable: SalesStore.instance.returnsListenable(),
            builder: (context, returnsBox, _) {
              final appSettings = AppSettingsStore.instance;
              final periodSales = ReportStore.instance.getCurrentPeriodSales(
                SalesStore.instance.getSales(),
              );
              final periodReturns = ReportStore.instance
                  .getCurrentPeriodReturns(SalesStore.instance.getReturns());
              final report = _XReportData.fromRecords(
                sales: periodSales,
                returns: periodReturns,
              );

              if (report.transactionCount == 0 && report.returnCount == 0) {
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
                        label: 'Cash Net',
                        value: appSettings.formatMoney(report.cashTotal),
                      ),
                      _ReportRow(
                        label: 'Card Net',
                        value: appSettings.formatMoney(report.cardTotal),
                      ),
                      _ReportRow(
                        label: 'Refunds',
                        value: appSettings.formatMoney(report.refundTotal),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ReportSection(
                    title: 'VAT Breakdown',
                    children: report.vatBreakdown.entries.map((entry) {
                      return _ReportRow(
                        label: 'VAT ${entry.key}%',
                        value: appSettings.formatMoney(entry.value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  _ReportSection(
                    title: 'Sales By Item (Net)',
                    children: report.itemSummaries.map((item) {
                      return _ReportRow(
                        label: '${item.name} x${item.quantity}',
                        value: appSettings.formatMoney(item.total),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
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
    final appSettings = AppSettingsStore.instance;

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
                    label: 'Net Sales',
                    value: appSettings.formatMoney(report.totalSales),
                    isStrong: true,
                  ),
                  _ThermalReportRow(
                    label: 'Gross Sales',
                    value: appSettings.formatMoney(report.grossSales),
                  ),
                  _ThermalReportRow(
                    label: 'Refunds',
                    value: appSettings.formatMoney(report.refundTotal),
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
                    label: 'Items Returned',
                    value: report.itemsReturned.toString(),
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
    final appSettings = AppSettingsStore.instance;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.4,
      children: [
        _SummaryTile(
          label: 'Net Sales',
          value: appSettings.formatMoney(report.totalSales),
        ),
        _SummaryTile(
          label: 'Gross Sales',
          value: appSettings.formatMoney(report.grossSales),
        ),
        _SummaryTile(
          label: 'Refunds',
          value: appSettings.formatMoney(report.refundTotal),
        ),
        _SummaryTile(
          label: 'Transactions',
          value: report.transactionCount.toString(),
        ),
        _SummaryTile(label: 'Items Sold', value: report.itemsSold.toString()),
        _SummaryTile(
          label: 'Items Returned',
          value: report.itemsReturned.toString(),
        ),
        _SummaryTile(
          label: 'Average Sale',
          value: appSettings.formatMoney(report.averageSale),
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
  final int returnCount;
  final int itemsReturned;
  final double grossSales;
  final double refundTotal;
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
    required this.returnCount,
    required this.itemsReturned,
    required this.grossSales,
    required this.refundTotal,
    required this.totalSales,
    required this.cashTotal,
    required this.cardTotal,
    required this.vatBreakdown,
    required this.itemSummaries,
  });

  double get averageSale =>
      transactionCount == 0 ? 0 : totalSales / transactionCount;

  factory _XReportData.fromRecords({
    required List<SaleRecord> sales,
    required List<ReturnRecord> returns,
  }) {
    final sortedSales = sales.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final sortedReturns = returns.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final now = DateTime.now();
    final Map<String, double> vatBreakdown = {};
    final Map<String, _ItemSummary> itemMap = {};
    var grossSales = 0.0;
    var refundTotal = 0.0;
    var cashTotal = 0.0;
    var cardTotal = 0.0;
    var itemsSold = 0;
    var itemsReturned = 0;

    for (final sale in sortedSales) {
      grossSales += sale.total;
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

    for (final returnRecord in sortedReturns) {
      refundTotal += returnRecord.refundTotal;
      if (returnRecord.refundMethod.toLowerCase().contains('cash')) {
        cashTotal -= returnRecord.refundTotal;
      } else if (returnRecord.refundMethod.toLowerCase().contains('card')) {
        cardTotal -= returnRecord.refundTotal;
      }

      for (final item in returnRecord.items) {
        itemsReturned += item.quantity;
        final rateKey = item.vatRate.toStringAsFixed(
          item.vatRate % 1 == 0 ? 0 : 1,
        );
        final vatAmount = item.lineTotal * item.vatRate / (100 + item.vatRate);
        vatBreakdown[rateKey] = (vatBreakdown[rateKey] ?? 0) - vatAmount;

        final key = '${item.name}|${item.unitPrice}|${item.vatRate}';
        final existing = itemMap[key];
        if (existing == null) {
          itemMap[key] = _ItemSummary(
            name: item.name,
            quantity: -item.quantity,
            total: -item.lineTotal,
          );
        } else {
          existing.quantity -= item.quantity;
          existing.total -= item.lineTotal;
        }
      }
    }

    final allDates = [
      ...sortedSales.map((sale) => sale.createdAt),
      ...sortedReturns.map((returnRecord) => returnRecord.createdAt),
    ]..sort();

    return _XReportData(
      startTime: allDates.isEmpty ? now : allDates.first,
      endTime: allDates.isEmpty ? now : allDates.last,
      transactionCount: sortedSales.length,
      itemsSold: itemsSold,
      returnCount: sortedReturns.length,
      itemsReturned: itemsReturned,
      grossSales: grossSales,
      refundTotal: refundTotal,
      totalSales: grossSales - refundTotal,
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
