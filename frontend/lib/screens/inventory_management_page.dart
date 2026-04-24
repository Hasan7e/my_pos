import 'package:flutter/material.dart';
import 'package:my_pos/screens/product_form_page.dart';
import 'package:my_pos/screens/product_management_page.dart';

class InventoryManagementPage extends StatelessWidget {
  const InventoryManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final options = [
      _InventoryOption(
        title: 'Add Product',
        subtitle: 'Create a new product with barcode, name and price',
        icon: Icons.add_box_outlined,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductFormPage()),
          );
        },
      ),
      _InventoryOption(
        title: 'Product Management',
        subtitle: 'Search, edit or delete products by barcode or name',
        icon: Icons.edit_note,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductManagementPage()),
          );
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: options.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemBuilder: (context, index) {
            final option = options[index];
            return Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: option.onTap,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(option.icon, size: 36),
                      const SizedBox(height: 12),
                      Text(
                        option.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        option.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InventoryOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _InventoryOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}
