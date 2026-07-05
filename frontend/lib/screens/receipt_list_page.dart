import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:my_pos/data/app_settings_store.dart';
import 'package:my_pos/data/sales_store.dart';
import 'package:my_pos/models/receipt_record.dart';
import 'package:my_pos/models/return_record.dart';
import 'package:my_pos/screens/receipt_view_page.dart';
import 'package:my_pos/screens/return_receipt_page.dart';

class ReceiptListPage extends StatelessWidget {
  const ReceiptListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Receipts'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.receipt_long), text: 'Sales Receipts'),
              Tab(
                icon: Icon(Icons.assignment_return_outlined),
                text: 'Return Receipts',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_SalesReceiptsTab(), _ReturnReceiptsTab()],
        ),
      ),
    );
  }
}

class _SalesReceiptsTab extends StatelessWidget {
  const _SalesReceiptsTab();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<ReceiptRecord>>(
      valueListenable: SalesStore.instance.receiptsListenable(),
      builder: (context, box, _) {
        final appSettings = AppSettingsStore.instance;
        final receipts = SalesStore.instance.getReceipts();

        if (receipts.isEmpty) {
          return const Center(child: Text('No sales receipts available'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: receipts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final receipt = receipts[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.receipt_long),
                title: Text('Receipt No: ${receipt.id}'),
                subtitle: Text(
                  '${appSettings.formatDateTime(receipt.createdAt)} | ${receipt.paymentMethod}',
                ),
                trailing: Text(
                  appSettings.formatMoney(receipt.total),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReceiptViewPage(receipt: receipt),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _ReturnReceiptsTab extends StatelessWidget {
  const _ReturnReceiptsTab();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<ReturnRecord>>(
      valueListenable: SalesStore.instance.returnsListenable(),
      builder: (context, box, _) {
        final appSettings = AppSettingsStore.instance;
        final returns = SalesStore.instance.getReturns();

        if (returns.isEmpty) {
          return const Center(child: Text('No return receipts available'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: returns.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final returnRecord = returns[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.assignment_return_outlined),
                title: Text('Return No: ${returnRecord.id}'),
                subtitle: Text(
                  '${appSettings.formatDateTime(returnRecord.createdAt)} | Original Receipt: ${returnRecord.originalReceiptId ?? 'Not found'}',
                ),
                trailing: Text(
                  appSettings.formatMoney(returnRecord.refundTotal),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ReturnReceiptPage(returnRecord: returnRecord),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
