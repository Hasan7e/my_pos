import 'package:flutter/material.dart';
import 'package:my_pos/models/app_user.dart';
import 'package:my_pos/screens/sales_history_page.dart';
import 'package:my_pos/screens/quick_sale_buttons_page.dart';
import 'package:my_pos/screens/sales_report_page.dart';
import 'package:my_pos/screens/customization_page.dart';
import 'package:my_pos/screens/returns_page.dart';
import 'package:my_pos/screens/user_management_page.dart';

class ManagerMenuPage extends StatelessWidget {
  final AppUser? currentUser;

  const ManagerMenuPage({super.key, this.currentUser});

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
      _ManagerOption(
        title: 'Sales Report',
        subtitle: 'View X and Z reports',
        icon: Icons.bar_chart_outlined,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SalesReportPage(currentUser: currentUser),
            ),
          );
        },
      ),
      _ManagerOption(
        title: 'Customization',
        subtitle: 'Adjust store and POS settings',
        icon: Icons.dashboard_customize_outlined,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CustomizationPage()),
          );
        },
      ),
      _ManagerOption(
        title: 'Returns',
        subtitle: 'Find a sale and process returned items',
        icon: Icons.assignment_return_outlined,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ReturnsPage(managerName: currentUser?.username ?? 'Manager'),
            ),
          );
        },
      ),
      _ManagerOption(
        title: 'User Management',
        subtitle: 'Deactivate or reactivate staff accounts',
        icon: Icons.manage_accounts_outlined,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserManagementPage()),
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
