import 'package:flutter/material.dart';
import 'screens/signup_page.dart';

void main() {
  runApp(const MyPosApp());
}

class MyPosApp extends StatelessWidget {
  const MyPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPOS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const SalesDashboardPage(),
    );
  }
}

class SalesDashboardPage extends StatefulWidget {
  const SalesDashboardPage({super.key});

  @override
  State<SalesDashboardPage> createState() => _SalesDashboardPageState();
}

class _SalesDashboardPageState extends State<SalesDashboardPage> {
  bool _isLoggedIn = false;
  String _loggedInUser = '';

  Future<void> _showLoginDialog() async {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<_LoginResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Login'),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: 350,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.trim().length < 4) {
                        return 'Password must be at least 4 characters';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),

            // 👇 ADD THIS BUTTON HERE
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close login dialog

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupPage()),
                );
              },
              child: const Text('Create Account'),
            ),

            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(
                    _LoginResult(
                      username: usernameController.text.trim(),
                      password: passwordController.text.trim(),
                    ),
                  );
                }
              },
              child: const Text('Login'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _isLoggedIn = true;
        _loggedInUser = result.username;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged in as ${result.username}')),
      );
    }
  }

  Future<void> _requireLoginThenRun(VoidCallback action) async {
    if (!_isLoggedIn) {
      await _showLoginDialog();
    }

    if (_isLoggedIn) {
      action();
    }
  }

  void _logout() {
    setState(() {
      _isLoggedIn = false;
      _loggedInUser = '';
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logged out')));
  }

  void _showActionMessage(String actionName) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$actionName action opened')));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 900;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        leadingWidth: 320,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Row(
            children: [
              TextButton(
                onPressed: () => _showActionMessage('Settings'),
                child: const Text('Settings'),
              ),
              TextButton(
                onPressed: () => _requireLoginThenRun(
                  () => _showActionMessage('Manage Products'),
                ),
                child: const Text('Manage Products'),
              ),
              TextButton(
                onPressed: () => _requireLoginThenRun(
                  () => _showActionMessage('Quick Sale'),
                ),
                child: const Text('Quick Sale'),
              ),
            ],
          ),
        ),
        centerTitle: true,
        title: const Text('MyPOS-Store'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: _isLoggedIn
                  ? Text(
                      'Signed in: $_loggedInUser',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    )
                  : const Text('Not signed in'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isLoggedIn
                ? OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                  )
                : FilledButton.icon(
                    onPressed: _showLoginDialog,
                    icon: const Icon(Icons.login),
                    label: const Text('Login'),
                  ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildSalesPanel()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildCartPanel()),
                ],
              )
            : Column(
                children: [
                  _buildSalesPanel(),
                  const SizedBox(height: 16),
                  _buildCartPanel(),
                ],
              ),
      ),
    );
  }

  Widget _buildSalesPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sales', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              _isLoggedIn
                  ? 'You can start and process sales.'
                  : 'Dashboard is visible, but selling actions require login.',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: () => _requireLoginThenRun(
                    () => _showActionMessage('New Sale'),
                  ),
                  icon: const Icon(Icons.point_of_sale),
                  label: const Text('New Sale'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _requireLoginThenRun(
                    () => _showActionMessage('Add Item'),
                  ),
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Add Item'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _requireLoginThenRun(
                    () => _showActionMessage('Checkout'),
                  ),
                  icon: const Icon(Icons.payment),
                  label: const Text('Checkout'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            Text('Products', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.2,
              children: const [
                _ProductTile(name: 'Coffee', price: 3.50),
                _ProductTile(name: 'Tea', price: 2.80),
                _ProductTile(name: 'Milk', price: 1.90),
                _ProductTile(name: 'Sandwich', price: 5.20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Sale',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Coffee'),
              trailing: Text('€3.50'),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Tea'),
              trailing: Text('€2.80'),
            ),
            const Divider(),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('€6.30', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () =>
                    _requireLoginThenRun(() => _showActionMessage('Checkout')),
                child: const Text('Proceed to Checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final String name;
  final double price;

  const _ProductTile({required this.name, required this.price});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('€${price.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}

class _LoginResult {
  final String username;
  final String password;

  _LoginResult({required this.username, required this.password});
}
