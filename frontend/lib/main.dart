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

class KeypadButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isAccent;

  const KeypadButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isAccent
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isLarge;

  const ActionButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: isLarge ? 18 : 14,
            horizontal: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isLarge ? 20 : 16,
            fontWeight: FontWeight.bold,
          ),
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

class _SalesDashboardPageState extends State<SalesDashboardPage> {
  bool _isLoggedIn = false;
  String _loggedInUser = '';
  String _currentInput = '';

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
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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

  void _appendInput(String value) {
    setState(() {
      if (value == '.') {
        if (_currentInput.contains('.')) return;
        if (_currentInput.isEmpty) {
          _currentInput = '0.';
          return;
        }
      }
      _currentInput += value;
    });
  }

  void _backspaceInput() {
    if (_currentInput.isEmpty) return;

    setState(() {
      _currentInput = _currentInput.substring(0, _currentInput.length - 1);
    });
  }

  void _clearInput() {
    setState(() {
      _currentInput = '';
    });
  }

  void _cancelInput() {
    setState(() {
      _currentInput = '';
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Transaction cancelled')));
  }

  void _setCashNote(String value) {
    setState(() {
      _currentInput = value;
    });
  }

  bool get _hasAmount {
    return _currentInput.isNotEmpty &&
        _currentInput != '.' &&
        double.tryParse(_currentInput) != null;
  }

  String get _displayValue {
    return _currentInput.isEmpty ? '0.00' : _currentInput;
  }

  void _handleSale() {
    final amount = _hasAmount ? _currentInput : '0.00';
    debugPrint('sale processed with amount $amount');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Sale processed: €$amount')));
  }

  void _handleCard() {
    final amount = _hasAmount ? _currentInput : '0.00';
    debugPrint('paid by card: $amount');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Paid by card: €$amount')));
  }

  void _handleCash() {
    final amount = _hasAmount ? _currentInput : '0.00';
    debugPrint('paid by cash: $amount');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Paid by cash: €$amount')));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final showSideBySide = screenWidth >= 900;

    return Scaffold(
      appBar: AppBar(
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
        child: showSideBySide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: _buildSalesPanel()),
                  const SizedBox(width: 16),
                  Expanded(flex: 3, child: _buildPosKeypadPanel()),
                ],
              )
            : Column(
                children: [
                  _buildSalesPanel(),
                  const SizedBox(height: 16),
                  _buildPosKeypadPanel(),
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
            Text(
              'Sales Dashboard',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
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
                    () => _showActionMessage('Manage Products'),
                  ),
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text('Manage Products'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _requireLoginThenRun(
                    () => _showActionMessage('Quick Sale'),
                  ),
                  icon: const Icon(Icons.flash_on_outlined),
                  label: const Text('Quick Sale'),
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

  Widget _buildPosKeypadPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Amount', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Text(
                    _displayValue,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: GridView.count(
                            crossAxisCount: 3,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.15,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              KeypadButton(
                                label: '7',
                                onTap: () => _appendInput('7'),
                              ),
                              KeypadButton(
                                label: '8',
                                onTap: () => _appendInput('8'),
                              ),
                              KeypadButton(
                                label: '9',
                                onTap: () => _appendInput('9'),
                              ),
                              KeypadButton(
                                label: '4',
                                onTap: () => _appendInput('4'),
                              ),
                              KeypadButton(
                                label: '5',
                                onTap: () => _appendInput('5'),
                              ),
                              KeypadButton(
                                label: '6',
                                onTap: () => _appendInput('6'),
                              ),
                              KeypadButton(
                                label: '1',
                                onTap: () => _appendInput('1'),
                              ),
                              KeypadButton(
                                label: '2',
                                onTap: () => _appendInput('2'),
                              ),
                              KeypadButton(
                                label: '3',
                                onTap: () => _appendInput('3'),
                              ),
                              KeypadButton(
                                label: '.',
                                onTap: () => _appendInput('.'),
                              ),
                              KeypadButton(
                                label: '0',
                                onTap: () => _appendInput('0'),
                              ),
                              KeypadButton(
                                label: '⌫',
                                onTap: _backspaceInput,
                                isAccent: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          flex: 2,
                          child: GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.4,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              ActionButton(
                                label: '10',
                                color: Colors.teal,
                                onTap: () => _setCashNote('10'),
                              ),
                              ActionButton(
                                label: '20',
                                color: Colors.teal,
                                onTap: () => _setCashNote('20'),
                              ),
                              ActionButton(
                                label: '50',
                                color: Colors.teal,
                                onTap: () => _setCashNote('50'),
                              ),
                              ActionButton(
                                label: '100',
                                color: Colors.teal,
                                onTap: () => _setCashNote('100'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Expanded(
                          child: ActionButton(
                            label: 'SALE',
                            color: Colors.blueGrey,
                            onTap: _handleSale,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ActionButton(
                            label: 'CARD',
                            color: Colors.indigo,
                            onTap: _handleCard,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ActionButton(
                            label: 'CLEAR',
                            color: Colors.orange,
                            onTap: _clearInput,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ActionButton(
                            label: 'CANCEL',
                            color: Colors.redAccent,
                            onTap: _cancelInput,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ActionButton(
                label: 'CASH',
                color: Colors.green,
                onTap: _handleCash,
                isLarge: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
