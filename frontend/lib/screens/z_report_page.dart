import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:my_pos/data/report_store.dart';
import 'package:my_pos/data/sales_store.dart';
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
        builder: (context, box, _) {
          final periodSales = ReportStore.instance.getCurrentPeriodSales(
            SalesStore.instance.getSales(),
          );
          final report = _ZReportData.fromSales(periodSales);

          if (report.transactionCount == 0) {
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
            ],
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
            Text('Last Z Close: ${lastClose?.toLocal() ?? 'Never'}'),
            Text('From: ${report.startTime.toLocal()}'),
            Text('To: ${report.endTime.toLocal()}'),
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

class _ZReportData {
  final DateTime startTime;
  final DateTime endTime;
  final int transactionCount;
  final int itemsSold;
  final double totalSales;
  final double cashTotal;
  final double cardTotal;
  final Map<String, double> vatBreakdown;

  const _ZReportData({
    required this.startTime,
    required this.endTime,
    required this.transactionCount,
    required this.itemsSold,
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
      itemsSold: itemsSold,
      totalSales: totalSales,
      cashTotal: cashTotal,
      cardTotal: cardTotal,
      vatBreakdown: vatBreakdown,
    );
  }

  factory _ZReportData.fromSales(List<SaleRecord> sales) {
    final sortedSales = sales.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final now = DateTime.now();
    final Map<String, double> vatBreakdown = {};
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
      }
    }

    return _ZReportData(
      startTime: sortedSales.isEmpty ? now : sortedSales.first.createdAt,
      endTime: sortedSales.isEmpty ? now : sortedSales.last.createdAt,
      transactionCount: sortedSales.length,
      itemsSold: itemsSold,
      totalSales: totalSales,
      cashTotal: cashTotal,
      cardTotal: cardTotal,
      vatBreakdown: vatBreakdown,
    );
  }
}
