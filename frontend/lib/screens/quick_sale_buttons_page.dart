import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:my_pos/data/quick_sale_store.dart';
import 'package:my_pos/models/quick_sale_config.dart';

class QuickSaleButtonsPage extends StatelessWidget {
  const QuickSaleButtonsPage({super.key});

  Future<void> _editButton(BuildContext context, QuickSaleConfig config) async {
    final labelController = TextEditingController(text: config.label);
    final priceController = TextEditingController(
      text: config.price.toStringAsFixed(2),
    );

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Quick Sale Button'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: const InputDecoration(
                  labelText: 'Button Label',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (shouldSave != true) return;

    final price = double.tryParse(priceController.text.trim());
    if (labelController.text.trim().isEmpty || price == null) return;

    await QuickSaleStore.instance.saveButton(
      QuickSaleConfig(
        id: config.id,
        label: labelController.text.trim(),
        price: price,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Quick Sale Buttons'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<Box<QuickSaleConfig>>(
        valueListenable: QuickSaleStore.instance.listenable(),
        builder: (context, box, _) {
          final buttons = QuickSaleStore.instance.getButtons();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: buttons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final button = buttons[index];

              return Card(
                child: ListTile(
                  title: Text(button.label),
                  subtitle: Text('€${button.price.toStringAsFixed(2)}'),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _editButton(context, button),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
