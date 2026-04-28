import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:my_pos/data/sales_store.dart';
import 'package:my_pos/models/sale_record.dart';

class SalesHistoryPage extends StatelessWidget {
  const SalesHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales History'), centerTitle: true),
      body: ValueListenableBuilder<Box<SaleRecord>>(
        valueListenable: SalesStore.instance.salesListenable(),
        builder: (context, box, _) {
          final sales = SalesStore.instance.getSales();

          if (sales.isEmpty) {
            return const Center(child: Text('No sales recorded yet'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sales.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final sale = sales[index];
              return Card(
                child: ListTile(
                  title: Text('Sale ${sale.id}'),
                  subtitle: Text(
                    '${sale.createdAt} | ${sale.paymentMethod} | ${sale.serverName}',
                  ),
                  trailing: Text(
                    '€${sale.total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
