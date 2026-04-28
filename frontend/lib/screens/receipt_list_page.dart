import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:my_pos/data/sales_store.dart';
import 'package:my_pos/models/receipt_record.dart';
import 'package:my_pos/screens/receipt_view_page.dart';

class ReceiptListPage extends StatelessWidget {
  const ReceiptListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receipts'), centerTitle: true),
      body: ValueListenableBuilder<Box<ReceiptRecord>>(
        valueListenable: SalesStore.instance.receiptsListenable(),
        builder: (context, box, _) {
          final receipts = SalesStore.instance.getReceipts();

          if (receipts.isEmpty) {
            return const Center(child: Text('No receipts available'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: receipts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final receipt = receipts[index];
              return Card(
                child: ListTile(
                  title: Text('Receipt ${receipt.id}'),
                  subtitle: Text(
                    '${receipt.createdAt} | ${receipt.paymentMethod}',
                  ),
                  trailing: Text(
                    '€${receipt.total.toStringAsFixed(2)}',
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
      ),
    );
  }
}
