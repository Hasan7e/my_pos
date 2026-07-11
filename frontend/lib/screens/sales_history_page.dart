import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:my_pos/data/app_settings_store.dart';
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
              return _SaleHistoryCard(sale: sales[index]);
            },
          );
        },
      ),
    );
  }
}

class _SaleHistoryCard extends StatelessWidget {
  final SaleRecord sale;

  const _SaleHistoryCard({required this.sale});

  @override
  Widget build(BuildContext context) {
    final appSettings = AppSettingsStore.instance;
    final receipt = SalesStore.instance.getReceiptBySaleId(sale.id);
    final cashPaid = _cashAmountForSale(sale);
    final cardPaid = _cardAmountForSale(sale);
    final isSplit = cashPaid > 0 && cardPaid > 0;

    return Card(
      child: ExpansionTile(
        leading: Icon(
          isSplit ? Icons.call_split : _paymentIcon(sale.paymentMethod),
        ),
        title: Text('Sale ${sale.id}'),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Receipt No: ${receipt?.id ?? 'Not found'}'),
              Text(
                '${appSettings.formatDateTime(sale.createdAt)} | ${sale.serverName}',
              ),
              Text('Payment: ${_paymentLabel(sale)}'),
              if (cashPaid > 0)
                Text('Cash: ${appSettings.formatMoney(cashPaid)}'),
              if (cardPaid > 0)
                Text('Card: ${appSettings.formatMoney(cardPaid)}'),
            ],
          ),
        ),
        trailing: Text(
          appSettings.formatMoney(sale.total),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Items',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...sale.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(child: Text(item.name)),
                        Text(
                          '${item.quantity} x ${appSettings.formatMoney(item.unitPrice)}',
                        ),
                        const SizedBox(width: 16),
                        Text(appSettings.formatMoney(item.lineTotal)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _paymentIcon(String paymentMethod) {
    final normalized = paymentMethod.toLowerCase();
    if (normalized.contains('card')) return Icons.credit_card;
    if (normalized.contains('cash')) return Icons.payments_outlined;
    return Icons.receipt_long;
  }

  String _paymentLabel(SaleRecord sale) {
    final cashPaid = _cashAmountForSale(sale);
    final cardPaid = _cardAmountForSale(sale);

    if (cashPaid > 0 && cardPaid > 0) return 'Split Payment';
    if (cardPaid > 0) return 'Card';
    if (cashPaid > 0) return 'Cash';

    return sale.paymentMethod;
  }

  double _cashAmountForSale(SaleRecord sale) {
    if (sale.cashPaid != null) return sale.cashPaid!;

    final paymentMethod = sale.paymentMethod.toLowerCase();
    if (paymentMethod == 'cash') return sale.total;
    if (!paymentMethod.startsWith('split')) return 0;

    return _splitAmountForLabel(sale.paymentMethod, 'Cash');
  }

  double _cardAmountForSale(SaleRecord sale) {
    if (sale.cardPaid != null) return sale.cardPaid!;

    final paymentMethod = sale.paymentMethod.toLowerCase();
    if (paymentMethod == 'card') return sale.total;
    if (!paymentMethod.startsWith('split')) return 0;

    return _splitAmountForLabel(sale.paymentMethod, 'Card');
  }

  double _splitAmountForLabel(String paymentMethod, String label) {
    final regex = RegExp('$label: ([0-9]+(?:\\.[0-9]+)?)');
    final match = regex.firstMatch(paymentMethod);
    if (match == null) return 0;

    return double.tryParse(match.group(1) ?? '') ?? 0;
  }
}
