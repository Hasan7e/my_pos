import 'package:flutter/material.dart';
import 'package:my_pos/data/app_settings_store.dart';
import 'package:my_pos/data/receipt_settings_store.dart';
import 'package:my_pos/models/return_record.dart';

class ReturnReceiptPage extends StatelessWidget {
  final ReturnRecord returnRecord;
  final bool askToPrint;

  const ReturnReceiptPage({
    super.key,
    required this.returnRecord,
    this.askToPrint = false,
  });

  @override
  Widget build(BuildContext context) {
    final receiptSettings = ReceiptSettingsStore.instance.getSettings();
    final appSettings = AppSettingsStore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Return Receipt'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Printing return receipt...')),
              );
            },
            icon: const Icon(Icons.print),
            tooltip: 'Print Return Receipt',
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
                    'RETURN RECEIPT',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text('Return No: ${returnRecord.id}'),
                  Text('Original Sale ID: ${returnRecord.originalSaleId}'),
                  Text(
                    'Original Receipt No: ${returnRecord.originalReceiptId ?? 'Not found'}',
                  ),
                  Text(
                    'Date/Time: ${appSettings.formatDateTime(returnRecord.createdAt)}',
                  ),
                  Text('Manager: ${returnRecord.managerName}'),
                  Text('Refund Method: ${returnRecord.refundMethod}'),
                  if (returnRecord.reason.trim().isNotEmpty)
                    Text('Reason: ${returnRecord.reason}'),
                  const Divider(height: 24),
                  ...returnRecord.items.map(
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
                          'Refund Total',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        appSettings.formatMoney(returnRecord.refundTotal),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (askToPrint) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 12),
                    const Text(
                      'Would the customer like a printed return receipt?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('No Copy'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Printing return receipt...'),
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
