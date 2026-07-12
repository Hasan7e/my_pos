import 'package:flutter/material.dart';
import 'package:my_pos/models/app_user.dart';
import 'package:my_pos/screens/x_report_page.dart';
import 'package:my_pos/screens/z_report_history_page.dart';
import 'package:my_pos/screens/z_report_page.dart';

class SalesReportPage extends StatelessWidget {
  final AppUser? currentUser;

  const SalesReportPage({super.key, this.currentUser});

  @override
  Widget build(BuildContext context) {
    final options = [
      _ReportOption(
        title: 'X Report',
        subtitle: 'View current sales summary without closing the day',
        icon: Icons.analytics_outlined,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const XReportPage()),
          );
        },
      ),
      _ReportOption(
        title: 'Z Report',
        subtitle: 'View end-of-day report and close the trading period',
        icon: Icons.assignment_turned_in_outlined,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ZReportPage(currentUser: currentUser),
            ),
          );
        },
      ),
      _ReportOption(
        title: 'Z Report History',
        subtitle: 'View and reprint previous Z reports',
        icon: Icons.history_outlined,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ZReportHistoryPage()),
          );
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Sales Report'), centerTitle: true),
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

class _ReportOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ReportOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}
