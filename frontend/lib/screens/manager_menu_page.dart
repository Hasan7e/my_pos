import 'package:flutter/material.dart';
import 'package:my_pos/screens/sales_history_page.dart';
import 'package:my_pos/screens/quick_sale_buttons_page.dart';

class ManagerMenuPage extends StatelessWidget {
  const ManagerMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final options = [
      _ManagerOption(
        title: 'Sales History',
        subtitle: 'View completed sales records',
        icon: Icons.receipt_long,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SalesHistoryPage()),
          );
        },
      ),
      _ManagerOption(
        title: 'Edit Quick Sale Buttons',
        subtitle: 'Change button names and prices',
        icon: Icons.tune,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const QuickSaleButtonsPage()),
          );
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Manager\'s Menu'), centerTitle: true),
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

class _ManagerOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ManagerOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}
