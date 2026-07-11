import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:my_pos/data/app_settings_store.dart';
import 'package:my_pos/data/report_store.dart';
import 'package:my_pos/data/sales_store.dart';
import 'package:my_pos/models/return_record.dart';
import 'package:my_pos/models/sale_record.dart';
import 'package:my_pos/models/z_report_record.dart';
import 'package:my_pos/screens/z_report_print_page.dart';

class ZReportPage extends StatelessWidget {
  const ZReportPage({super.key});

  Future<void> _generateZReport(
    BuildContext context,
    _ZReportData report,
  ) async {
    final shouldClose = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Generate Z Report'),
          content: const Text(
            'This will close the current trading period. Future X and Z reports will start after this close time.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Close Period'),
            ),
          ],
        );
      },
    );

    if (shouldClose != true) return;

    final closedAt = DateTime.now();
    final reportRecord = report.toRecord(
      id: closedAt.microsecondsSinceEpoch.toString(),
      closedAt: closedAt,
    );

    await ReportStore.instance.saveZReport(reportRecord);
    await ReportStore.instance.closeCurrentPeriod(closedAt);

    if (!context.mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ZReportPrintPage(report: reportRecord)),
    );
  }

  void _openPrintPreview(BuildContext context, _ZReportData report) {
    final previewRecord = report.toRecord(id: 'Preview', closedAt: null);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ZReportPrintPage(report: previewRecord),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Z Report'), centerTitle: true),
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
              final report = _ZReportData.fromRecords(
                sales: periodSales,
                returns: periodReturns,
              );

              if (report.transactionCount == 0 && report.returnCount == 0) {
                return const Center(
                  child: Text('No sales in the current trading period'),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _ReportHeader(report: report),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openPrintPreview(context, report),
                          icon: const Icon(Icons.print),
                          label: const Text('Preview Print'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _generateZReport(context, report),
                          icon: const Icon(Icons.lock_clock),
                          label: const Text('Generate Z Report'),
                        ),
                      ),
                    ],
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
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ReportHeader extends StatelessWidget {
  final _ZReportData report;

  const _ReportHeader({required this.report});

  @override
  Widget build(BuildContext context) {
    final lastClose = ReportStore.instance.getLastZCloseTime();
    final appSettings = AppSettingsStore.instance;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Trading Period',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Last Z Close: ${lastClose == null ? 'Never' : appSettings.formatDateTime(lastClose)}',
            ),
            Text('From: ${appSettings.formatDateTime(report.startTime)}'),
            Text('To: ${appSettings.formatDateTime(report.endTime)}'),
            const SizedBox(height: 8),
            const Text(
              'Generating this report will close the current trading period.',
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final _ZReportData report;

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
        _SummaryTile(label: 'Returns', value: report.returnCount.toString()),
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

class _ZReportData {
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

  const _ZReportData({
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
  });

  double get averageSale =>
      transactionCount == 0 ? 0 : totalSales / transactionCount;

  ZReportRecord toRecord({required String id, DateTime? closedAt}) {
    return ZReportRecord(
      id: id,
      startTime: startTime,
      endTime: endTime,
      closedAt: closedAt,
      transactionCount: transactionCount,
      itemsSold: itemsSold - itemsReturned,
      totalSales: totalSales,
      cashTotal: cashTotal,
      cardTotal: cardTotal,
      vatBreakdown: vatBreakdown,
    );
  }

  factory _ZReportData.fromRecords({
    required List<SaleRecord> sales,
    required List<ReturnRecord> returns,
  }) {
    final sortedSales = sales.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final sortedReturns = returns.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final now = DateTime.now();
    final Map<String, double> vatBreakdown = {};
    var grossSales = 0.0;
    var refundTotal = 0.0;
    var cashTotal = 0.0;
    var cardTotal = 0.0;
    var itemsSold = 0;
    var itemsReturned = 0;

    for (final sale in sortedSales) {
      grossSales += sale.total;
      cashTotal += _cashAmountForSale(sale);
      cardTotal += _cardAmountForSale(sale);

      for (final entry in sale.vatBreakdown.entries) {
        vatBreakdown[entry.key] = (vatBreakdown[entry.key] ?? 0) + entry.value;
      }

      for (final item in sale.items) {
        itemsSold += item.quantity;
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
      }
    }

    final allDates = [
      ...sortedSales.map((sale) => sale.createdAt),
      ...sortedReturns.map((returnRecord) => returnRecord.createdAt),
    ]..sort();

    return _ZReportData(
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
    );
  }

  static double _cashAmountForSale(SaleRecord sale) {
    if (sale.cashPaid != null) return sale.cashPaid!;

    final paymentMethod = sale.paymentMethod.toLowerCase();
    if (paymentMethod == 'cash') return sale.total;
    if (!paymentMethod.startsWith('split')) return 0;

    return _splitAmountForLabel(sale.paymentMethod, 'Cash');
  }

  static double _cardAmountForSale(SaleRecord sale) {
    if (sale.cardPaid != null) return sale.cardPaid!;

    final paymentMethod = sale.paymentMethod.toLowerCase();
    if (paymentMethod == 'card') return sale.total;
    if (!paymentMethod.startsWith('split')) return 0;

    return _splitAmountForLabel(sale.paymentMethod, 'Card');
  }

  static double _splitAmountForLabel(String paymentMethod, String label) {
    final regex = RegExp('$label: ([0-9]+(?:\\.[0-9]+)?)');
    final match = regex.firstMatch(paymentMethod);
    if (match == null) return 0;

    return double.tryParse(match.group(1) ?? '') ?? 0;
  }
}
