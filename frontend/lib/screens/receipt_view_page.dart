import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:my_pos/data/app_settings_store.dart';
import 'package:my_pos/models/receipt_record.dart';
import 'package:my_pos/data/receipt_settings_store.dart';
import 'package:my_pos/services/receipt_pdf_service.dart';
import 'package:printing/printing.dart';

class ReceiptViewPage extends StatefulWidget {
  final ReceiptRecord receipt;
  final bool askToPrint;

  const ReceiptViewPage({
    super.key,
    required this.receipt,
    this.askToPrint = false,
  });

  @override
  State<ReceiptViewPage> createState() => _ReceiptViewPageState();
}

class _ReceiptViewPageState extends State<ReceiptViewPage> {
  @override
  void initState() {
    super.initState();
    if (widget.askToPrint) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showPrintPrompt());
    }
  }

  Future<void> _showPrintPrompt() async {
    final shouldKeepReceiptOpen = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Print Receipt?'),
        content: const Text('Would the customer like a receipt?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (mounted && shouldKeepReceiptOpen != true) {
      Navigator.of(context).pop();
    }
  }

  String get _fileName => 'receipt-${widget.receipt.id}.pdf';

  Future<void> _print(BuildContext context) async {
    try {
      await Printing.layoutPdf(
        name: _fileName,
        onLayout: (_) => ReceiptPdfService.buildPdf(widget.receipt),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open the print dialog.')),
        );
      }
    }
  }

  Future<void> _savePdf(BuildContext context) async {
    try {
      final bytes = await ReceiptPdfService.buildPdf(widget.receipt);
      final location = await getSaveLocation(
        suggestedName: _fileName,
        acceptedTypeGroups: const [
          XTypeGroup(label: 'PDF documents', extensions: ['pdf']),
        ],
      );
      if (location == null) return;

      await XFile.fromData(
        bytes,
        mimeType: 'application/pdf',
        name: _fileName,
      ).saveTo(location.path);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to save the PDF.')),
        );
      }
    }
  }

  Future<void> _sharePdf(BuildContext context) async {
    try {
      await Printing.sharePdf(
        bytes: await ReceiptPdfService.buildPdf(widget.receipt),
        filename: _fileName,
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to share the PDF.')),
        );
      }
    }
  }

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
            onPressed: () => _print(context),
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
                    widget.receipt.shopName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(widget.receipt.shopAddress, textAlign: TextAlign.center),
                  Text(
                    'VAT No: ${widget.receipt.vatNumber}',
                    textAlign: TextAlign.center,
                  ),
                  const Divider(height: 24),
                  Text('Receipt No: ${widget.receipt.id}'),
                  Text('Sale ID: ${widget.receipt.saleId}'),
                  Text(
                    'Date/Time: ${appSettings.formatDateTime(widget.receipt.createdAt)}',
                  ),
                  Text('Server: ${widget.receipt.serverName}'),
                  const Divider(height: 24),
                  ...widget.receipt.items.map(
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
                        appSettings.formatMoney(widget.receipt.total),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ReceiptPaymentSummary(receipt: widget.receipt),
                  const SizedBox(height: 16),
                  const Text(
                    'VAT Breakdown',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...widget.receipt.vatBreakdown.entries.map(
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
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => _print(context),
                    icon: const Icon(Icons.print),
                    label: const Text('Print / Thermal Printer'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _savePdf(context),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('Save PDF'),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => _sharePdf(context),
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Share PDF'),
                  ),
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
