import 'package:flutter/material.dart';
import 'package:my_pos/data/app_settings_store.dart';
import 'package:my_pos/data/product_store.dart';
import 'package:my_pos/data/sales_store.dart';
import 'package:my_pos/models/return_line_item.dart';
import 'package:my_pos/models/return_record.dart';
import 'package:my_pos/models/sale_record.dart';
import 'package:my_pos/screens/return_receipt_page.dart';

class ReturnsPage extends StatefulWidget {
  final String managerName;

  const ReturnsPage({super.key, required this.managerName});

  @override
  State<ReturnsPage> createState() => _ReturnsPageState();
}

class _ReturnsPageState extends State<ReturnsPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  String _refundMethod = 'Cash Refund';
  List<SaleRecord> _matches = [];
  SaleRecord? _selectedSale;
  final Map<int, int> _returnQuantities = {};

  @override
  void dispose() {
    _searchController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _searchSales() {
    setState(() {
      _matches = SalesStore.instance.searchSalesForReturn(
        _searchController.text,
      );
      _selectedSale = null;
      _returnQuantities.clear();
    });
  }

  void _selectSale(SaleRecord sale) {
    setState(() {
      _selectedSale = sale;
      _returnQuantities.clear();
    });
  }

  double get _refundTotal {
    final sale = _selectedSale;
    if (sale == null) return 0;

    var total = 0.0;
    for (final entry in _returnQuantities.entries) {
      total += sale.items[entry.key].unitPrice * entry.value;
    }
    return total;
  }

  void _changeReturnQuantity(int itemIndex, int delta) {
    final sale = _selectedSale;
    if (sale == null) return;

    final item = sale.items[itemIndex];
    final alreadyReturned = SalesStore.instance.returnedQuantityForSaleItem(
      saleId: sale.id,
      itemName: item.name,
      barcode: item.barcode,
      unitPrice: item.unitPrice,
      vatRate: item.vatRate,
    );
    final maxQuantity = item.quantity - alreadyReturned;

    if (maxQuantity <= 0 && delta > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.name} has already been fully refunded')),
      );
      return;
    }

    final currentQuantity = _returnQuantities[itemIndex] ?? 0;
    final nextQuantity = (currentQuantity + delta).clamp(0, maxQuantity);

    setState(() {
      if (nextQuantity == 0) {
        _returnQuantities.remove(itemIndex);
      } else {
        _returnQuantities[itemIndex] = nextQuantity;
      }
    });
  }

  Future<void> _processReturn() async {
    final sale = _selectedSale;
    if (sale == null || _returnQuantities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one item to return')),
      );
      return;
    }

    final receipt = SalesStore.instance.getReceiptBySaleId(sale.id);
    final refundTotal = _refundTotal;
    final unavailableItems = <String>[];

    for (final entry in _returnQuantities.entries) {
      final item = sale.items[entry.key];
      final alreadyReturned = SalesStore.instance.returnedQuantityForSaleItem(
        saleId: sale.id,
        itemName: item.name,
        barcode: item.barcode,
        unitPrice: item.unitPrice,
        vatRate: item.vatRate,
      );
      final availableQuantity = item.quantity - alreadyReturned;

      if (entry.value > availableQuantity) {
        unavailableItems.add(item.name);
      }
    }

    if (unavailableItems.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${unavailableItems.join(', ')} has already been refunded',
          ),
        ),
      );
      setState(() => _returnQuantities.clear());
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Return'),
          content: Text(
            'Refund ${AppSettingsStore.instance.formatMoney(refundTotal)} using $_refundMethod?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Process Return'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final returnItems = _returnQuantities.entries.map((entry) {
      final item = sale.items[entry.key];
      return ReturnLineItem(
        name: item.name,
        barcode: item.barcode,
        quantity: entry.value,
        unitPrice: item.unitPrice,
        vatRate: item.vatRate,
      );
    }).toList();

    final now = DateTime.now();
    final returnRecord = ReturnRecord(
      id: now.microsecondsSinceEpoch.toString(),
      originalSaleId: sale.id,
      originalReceiptId: receipt?.id,
      createdAt: now,
      managerName: widget.managerName,
      refundMethod: _refundMethod,
      reason: _reasonController.text.trim(),
      refundTotal: refundTotal,
      items: returnItems,
    );

    await SalesStore.instance.saveReturn(returnRecord);
    await ProductStore.instance.increaseStockForReturnItems(returnItems);

    if (!mounted) return;

    setState(() {
      _selectedSale = null;
      _matches = [];
      _returnQuantities.clear();
      _searchController.clear();
      _reasonController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Return processed: ${AppSettingsStore.instance.formatMoney(refundTotal)}',
        ),
      ),
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ReturnReceiptPage(returnRecord: returnRecord, askToPrint: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedSale = _selectedSale;

    return Scaffold(
      appBar: AppBar(title: const Text('Returns'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _searchSales(),
                    decoration: const InputDecoration(
                      labelText: 'Sale ID, receipt ID, barcode or product name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _searchSales,
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: selectedSale == null
                  ? _SalesSearchResults(
                      matches: _matches,
                      onSelectSale: _selectSale,
                    )
                  : _ReturnEditor(
                      sale: selectedSale,
                      returnQuantities: _returnQuantities,
                      refundMethod: _refundMethod,
                      reasonController: _reasonController,
                      onRefundMethodChanged: (value) {
                        if (value == null) return;
                        setState(() => _refundMethod = value);
                      },
                      onQuantityChanged: _changeReturnQuantity,
                      refundTotal: _refundTotal,
                      onBackToSearch: () {
                        setState(() {
                          _selectedSale = null;
                          _returnQuantities.clear();
                        });
                      },
                      onProcessReturn: _processReturn,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SalesSearchResults extends StatelessWidget {
  final List<SaleRecord> matches;
  final void Function(SaleRecord sale) onSelectSale;

  const _SalesSearchResults({
    required this.matches,
    required this.onSelectSale,
  });

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return const Center(
        child: Text('Search for an original sale to begin a return'),
      );
    }

    return ListView.separated(
      itemCount: matches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final sale = matches[index];
        final receipt = SalesStore.instance.getReceiptBySaleId(sale.id);

        return Card(
          child: ListTile(
            title: Text('Sale ${sale.id}'),
            subtitle: Text(
              'Receipt: ${receipt?.id ?? 'Not found'} | ${AppSettingsStore.instance.formatDateTime(sale.createdAt)} | ${sale.paymentMethod}',
            ),
            trailing: Text(
              AppSettingsStore.instance.formatMoney(sale.total),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () => onSelectSale(sale),
          ),
        );
      },
    );
  }
}

class _ReturnEditor extends StatelessWidget {
  final SaleRecord sale;
  final Map<int, int> returnQuantities;
  final String refundMethod;
  final TextEditingController reasonController;
  final ValueChanged<String?> onRefundMethodChanged;
  final void Function(int itemIndex, int delta) onQuantityChanged;
  final double refundTotal;
  final VoidCallback onBackToSearch;
  final VoidCallback onProcessReturn;

  const _ReturnEditor({
    required this.sale,
    required this.returnQuantities,
    required this.refundMethod,
    required this.reasonController,
    required this.onRefundMethodChanged,
    required this.onQuantityChanged,
    required this.refundTotal,
    required this.onBackToSearch,
    required this.onProcessReturn,
  });

  @override
  Widget build(BuildContext context) {
    final receipt = SalesStore.instance.getReceiptBySaleId(sale.id);

    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Original Sale',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text('Sale ID: ${sale.id}'),
                Text('Receipt ID: ${receipt?.id ?? 'Not found'}'),
                Text(
                  'Date/Time: ${AppSettingsStore.instance.formatDateTime(sale.createdAt)}',
                ),
                Text('Payment: ${sale.paymentMethod}'),
                Text('Server: ${sale.serverName}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...sale.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final returnQuantity = returnQuantities[index] ?? 0;
          final alreadyReturned = SalesStore.instance
              .returnedQuantityForSaleItem(
                saleId: sale.id,
                itemName: item.name,
                barcode: item.barcode,
                unitPrice: item.unitPrice,
                vatRate: item.vatRate,
              );
          final availableQuantity = item.quantity - alreadyReturned;
          final isFullyRefunded = availableQuantity <= 0;

          return Card(
            child: ListTile(
              title: Text(item.name),
              subtitle: Text(
                isFullyRefunded
                    ? 'Sold: ${item.quantity} | Already returned: $alreadyReturned | Already fully refunded'
                    : 'Sold: ${item.quantity} | Already returned: $alreadyReturned | Available: $availableQuantity | Barcode: ${item.barcode ?? 'N/A'} | ${AppSettingsStore.instance.formatMoney(item.unitPrice)} each',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => onQuantityChanged(index, -1),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    returnQuantity.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: isFullyRefunded
                        ? null
                        : () => onQuantityChanged(index, 1),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: refundMethod,
          decoration: const InputDecoration(
            labelText: 'Refund Method',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'Cash Refund', child: Text('Cash Refund')),
            DropdownMenuItem(value: 'Card Refund', child: Text('Card Refund')),
          ],
          onChanged: onRefundMethodChanged,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: reasonController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Return Reason (Optional)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Refund Total',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  AppSettingsStore.instance.formatMoney(refundTotal),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onBackToSearch,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: onProcessReturn,
                icon: const Icon(Icons.assignment_return),
                label: const Text('Process Return'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
