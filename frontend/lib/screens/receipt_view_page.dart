import 'package:flutter/material.dart';
import 'package:my_pos/data/app_settings_store.dart';
import 'package:my_pos/models/receipt_record.dart';
import 'package:my_pos/data/receipt_settings_store.dart';

class ReceiptViewPage extends StatelessWidget {
  final ReceiptRecord receipt;
  final bool askToPrint;

  const ReceiptViewPage({
    super.key,
    required this.receipt,
    this.askToPrint = false,
  });

  @override
  Widget build(BuildContext context) {
    final receiptSettings = ReceiptSettingsStore.instance.getSettings();
    final appSettings = AppSettingsStore.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Printing receipt...')),
              );
            },
            icon: const Icon(Icons.print),
            tooltip: 'Print Receipt',
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
                    receipt.shopName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(receipt.shopAddress, textAlign: TextAlign.center),
                  Text(
                    'VAT No: ${receipt.vatNumber}',
                    textAlign: TextAlign.center,
                  ),
                  const Divider(height: 24),
                  Text('Receipt No: ${receipt.id}'),
                  Text('Sale ID: ${receipt.saleId}'),
                  Text(
                    'Date/Time: ${appSettings.formatDateTime(receipt.createdAt)}',
                  ),
                  Text('Server: ${receipt.serverName}'),
                  const Divider(height: 24),
                  ...receipt.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: Text(item.name)),
                          Expanded(
                            child: Text(
                              '${item.quantity} x ${appSettings.formatMoney(item.unitPrice)}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Text(appSettings.formatMoney(item.lineTotal)),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Total',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        appSettings.formatMoney(receipt.total),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ReceiptPaymentSummary(receipt: receipt),
                  const SizedBox(height: 16),
                  const Text(
                    'VAT Breakdown',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...receipt.vatBreakdown.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Expanded(child: Text('VAT ${entry.key}%')),
                          Text(appSettings.formatMoney(entry.value)),
                        ],
                      ),
                    ),
                  ),
                  if (receiptSettings.footerMessage.trim().isNotEmpty) ...[
                    const Divider(height: 24),
                    Text(
                      receiptSettings.footerMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                  if (askToPrint) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 12),
                    const Text(
                      'Would the customer like a printed copy?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('No Copy'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Printing receipt...'),
                                ),
                              );
                              Navigator.pop(context);
                            },
                            child: const Text('Print Copy'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReceiptPaymentSummary extends StatelessWidget {
  final ReceiptRecord receipt;

  const _ReceiptPaymentSummary({required this.receipt});

  @override
  Widget build(BuildContext context) {
    final appSettings = AppSettingsStore.instance;
    final cashPaid = _cashAmountForReceipt(receipt);
    final cardPaid = _cardAmountForReceipt(receipt);
    final isSplit = cashPaid > 0 && cardPaid > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (isSplit) ...[
            _PaymentRow(
              label: 'Card payment',
              value: appSettings.formatMoney(cardPaid),
            ),
            _PaymentRow(
              label: 'Cash payment',
              value: appSettings.formatMoney(cashPaid),
            ),
            const Divider(height: 16),
            _PaymentRow(
              label: 'Total paid',
              value: appSettings.formatMoney(cashPaid + cardPaid),
              isStrong: true,
            ),
          ] else if (cardPaid > 0) ...[
            _PaymentRow(
              label: 'Paid by card',
              value: appSettings.formatMoney(cardPaid),
              isStrong: true,
            ),
          ] else if (cashPaid > 0) ...[
            _PaymentRow(
              label: 'Paid by cash',
              value: appSettings.formatMoney(cashPaid),
              isStrong: true,
            ),
          ] else ...[
            Text(receipt.paymentMethod),
          ],
        ],
      ),
    );
  }

  double _cashAmountForReceipt(ReceiptRecord receipt) {
    if (receipt.cashPaid != null) return receipt.cashPaid!;

    final paymentMethod = receipt.paymentMethod.toLowerCase();
    if (paymentMethod == 'cash') return receipt.total;
    if (!paymentMethod.startsWith('split')) return 0;

    return _splitAmountForLabel(receipt.paymentMethod, 'Cash');
  }

  double _cardAmountForReceipt(ReceiptRecord receipt) {
    if (receipt.cardPaid != null) return receipt.cardPaid!;

    final paymentMethod = receipt.paymentMethod.toLowerCase();
    if (paymentMethod == 'card') return receipt.total;
    if (!paymentMethod.startsWith('split')) return 0;

    return _splitAmountForLabel(receipt.paymentMethod, 'Card');
  }

  double _splitAmountForLabel(String paymentMethod, String label) {
    final regex = RegExp('$label: ([0-9]+(?:\\.[0-9]+)?)');
    final match = regex.firstMatch(paymentMethod);
    if (match == null) return 0;

    return double.tryParse(match.group(1) ?? '') ?? 0;
  }
}

class _PaymentRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isStrong;

  const _PaymentRow({
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
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
