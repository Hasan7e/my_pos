import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:my_pos/data/report_store.dart';
import 'package:my_pos/models/z_report_record.dart';
import 'package:my_pos/screens/z_report_print_page.dart';

class ZReportHistoryPage extends StatelessWidget {
  const ZReportHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Z Report History'), centerTitle: true),
      body: ValueListenableBuilder<Box<ZReportRecord>>(
        valueListenable: ReportStore.instance.zReportsListenable(),
        builder: (context, box, _) {
          final reports = ReportStore.instance.getZReports();

          if (reports.isEmpty) {
            return const Center(child: Text('No Z reports generated yet'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final report = reports[index];
              final reportDate = report.closedAt ?? report.endTime;

              return Card(
                child: ListTile(
                  title: Text('Z Report ${report.id}'),
                  subtitle: Text(
                    '${reportDate.toLocal()} | ${report.transactionCount} transactions',
                  ),
                  trailing: Text(
                    '€${report.totalSales.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ZReportPrintPage(report: report),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
