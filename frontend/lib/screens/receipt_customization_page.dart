import 'package:flutter/material.dart';
import 'package:my_pos/data/receipt_settings_store.dart';

class ReceiptCustomizationPage extends StatefulWidget {
  const ReceiptCustomizationPage({super.key});

  @override
  State<ReceiptCustomizationPage> createState() =>
      _ReceiptCustomizationPageState();
}

class _ReceiptCustomizationPageState extends State<ReceiptCustomizationPage> {
  final _shopNameController = TextEditingController();
  final _shopAddressController = TextEditingController();
  final _vatNumberController = TextEditingController();
  final _footerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final settings = ReceiptSettingsStore.instance.getSettings();
    _shopNameController.text = settings.shopName;
    _shopAddressController.text = settings.shopAddress;
    _vatNumberController.text = settings.vatNumber;
    _footerController.text = settings.footerMessage;
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _shopAddressController.dispose();
    _vatNumberController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ReceiptSettingsStore.instance.saveSettings(
      ReceiptSettings(
        shopName: _shopNameController.text.trim(),
        shopAddress: _shopAddressController.text.trim(),
        vatNumber: _vatNumberController.text.trim(),
        footerMessage: _footerController.text.trim(),
      ),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Receipt customization saved')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Customization'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _shopNameController,
            decoration: const InputDecoration(
              labelText: 'Shop Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _shopAddressController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Shop Address',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _vatNumberController,
            decoration: const InputDecoration(
              labelText: 'VAT Number',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _footerController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Receipt Footer Message',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Save Receipt Details'),
          ),
        ],
      ),
    );
  }
}
