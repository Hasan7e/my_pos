import 'package:flutter/material.dart';
import 'package:my_pos/screens/inventory_management_page.dart';
import 'package:my_pos/screens/manager_menu_page.dart';
import 'package:my_pos/screens/receipt_list_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final options = [
      _SettingsOption(
        title: 'Manage Inventory',
        icon: Icons.inventory_2_outlined,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InventoryManagementPage()),
          );
        },
      ),
      _SettingsOption(
        title: 'Receipts',
        icon: Icons.receipt,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReceiptListPage()),
          );
        },
      ),
      _SettingsOption(
        title: 'Date and Time',
        icon: Icons.access_time,
        onTap: () {},
      ),
      _SettingsOption(
        title: 'Managers Menu',
        icon: Icons.admin_panel_settings_outlined,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ManagerMenuPage()),
          );
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: options.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.35,
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
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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

class _SettingsOption {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _SettingsOption({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}
