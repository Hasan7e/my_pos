import 'dart:io' show Directory;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:my_pos/models/product.dart';
import 'package:my_pos/screens/signup_page.dart';
import 'package:my_pos/screens/settings_page.dart';
import 'package:my_pos/data/product_store.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:my_pos/data/sales_store.dart';
import 'package:my_pos/models/receipt_record.dart';
import 'package:my_pos/models/sale_line_item.dart';
import 'package:my_pos/models/sale_record.dart';
import 'package:my_pos/data/quick_sale_store.dart';
import 'package:my_pos/models/quick_sale_config.dart';
import 'package:my_pos/screens/receipt_view_page.dart';

// this is the code that only works for desktop or mac for saving data
/*
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appSupportDir = await getApplicationSupportDirectory();
  final hiveDir = Directory('${appSupportDir.path}/my_pos_hive');
  await hiveDir.create(recursive: true);

  debugPrint('Hive directory: ${hiveDir.path}');

  Hive.init(hiveDir.path);
  Hive.registerAdapter(ProductAdapter());

  final box = await Hive.openBox<Product>('products');
  debugPrint('Opened products box with ${box.length} products');

  runApp(const MyPosApp());
} */

//new code for web and desktop
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    final appSupportDir = await getApplicationSupportDirectory();
    final hiveDir = Directory('${appSupportDir.path}/my_pos_hive');
    await hiveDir.create(recursive: true);
    Hive.init(hiveDir.path);
  }

  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(SaleLineItemAdapter());
  Hive.registerAdapter(SaleRecordAdapter());
  Hive.registerAdapter(ReceiptRecordAdapter());
  Hive.registerAdapter(QuickSaleConfigAdapter());
  await Hive.openBox<Product>('products');
  await Hive.openBox<SaleRecord>('sales');
  await Hive.openBox<ReceiptRecord>('receipts');
  await Hive.openBox<QuickSaleConfig>('quick_sales');
  await QuickSaleStore.instance.ensureDefaults();
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
  int _currentInputCents = 0;

  double get _currentInputAmount => _currentInputCents / 100;

  int? _selectedCartIndex;

  final TextEditingController _barcodeController = TextEditingController();

  final List<CartItem> cart = [];

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _handleCashPayment() async {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add items to the basket first')),
      );
      return;
    }

    final total = _cartTotal;
    final tenderedAmount = _hasAmount ? _currentInputAmount : total;

    if (tenderedAmount < total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cash received is less than the sale total'),
        ),
      );
      return;
    }

    final changeDue = tenderedAmount - total;

    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Due'),
          content: Text(
            'Total: €${total.toStringAsFixed(2)}\n'
            'Cash Received: €${tenderedAmount.toStringAsFixed(2)}\n'
            'Change Due: €${changeDue.toStringAsFixed(2)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    if (shouldContinue != true) return;

    await _completeSale('Cash');
  }

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

  void _appendDigit(String digit) {
    setState(() {
      _currentInputCents = (_currentInputCents * 10) + int.parse(digit);
    });
  }

  void _appendDoubleZero() {
    setState(() {
      _currentInputCents = _currentInputCents * 100;
    });
  }

  void _appendInput(String value) {
    setState(() {
      if (value == '.') {
        // Decimal point - multiply by 100 to convert existing cents to euros with decimal
        _currentInputCents = _currentInputCents * 100;
      } else {
        _currentInputCents = (_currentInputCents * 10) + int.parse(value);
      }
    });
  }

  void _backspaceInput() {
    setState(() {
      _currentInputCents = _currentInputCents ~/ 10;
    });
  }

  void _clearInput() {
    setState(() {
      _currentInputCents = 0;
    });
  }

  Future<void> _cancelSale() async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Transaction'),
          content: const Text(
            'Are you sure you want to cancel this transaction? All items will be removed from the basket.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true) return;

    setState(() {
      _currentInputCents = 0;
      _selectedCartIndex = null;
      cart.clear();
      _barcodeController.clear();
    });

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sale cancelled')));
  }

  void _setCashNote(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) return;

    setState(() {
      _currentInputCents = (parsed * 100).round();
    });
  }

  void addItem(String name, double price) {
    setState(() {
      final existingIndex = cart.indexWhere(
        (item) => item.name == name && item.price == price,
      );

      if (existingIndex != -1) {
        cart[existingIndex].quantity++;
        _selectedCartIndex = existingIndex;
      } else {
        cart.add(CartItem(name: name, price: price, quantity: 1));
        _selectedCartIndex = cart.length - 1;
      }
    });
  }

  void _increaseQuantity(int index) {
    setState(() {
      cart[index].quantity++;
      _selectedCartIndex = index;
    });
  }

  void _decreaseQuantity(int index) {
    setState(() {
      cart[index].quantity--;

      if (cart[index].quantity <= 0) {
        cart.removeAt(index);
        _selectedCartIndex = null;
      } else {
        _selectedCartIndex = index;
      }
    });
  }

  void _removeCartItem(int index) {
    setState(() {
      cart.removeAt(index);
      _selectedCartIndex = null;
    });
  }

  void _handleBarcodeSubmitted(String rawBarcode) {
    final barcode = rawBarcode.trim();
    if (barcode.isEmpty) return;

    final matchedProduct = ProductStore.instance.findByBarcode(barcode);

    if (matchedProduct != null) {
      addItem(matchedProduct.name, matchedProduct.salePrice);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Scanned ${matchedProduct.name}')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No product found for barcode: $barcode')),
      );
    }
  }

  double get _cartTotal {
    return cart.fold(0, (sum, item) => sum + item.total);
  }

  bool get _hasAmount {
    return _currentInputCents > 0;
  }

  String get _displayValue {
    return (_currentInputCents / 100).toStringAsFixed(2);
  }

  void _handleTender() {
    final amount = _currentInputAmount;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount first')),
      );
      return;
    }

    addItem('Open Item', amount);
    setState(() {
      _currentInputCents = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Open Item added: €${amount.toStringAsFixed(2)}')),
    );
  }

  /* old code only text pop up for receipt 
  Future<void> _offerReceipt(String paymentMethod, double total) async {
    final shouldPrint = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Print Receipt?'),
          content: Text(
            '$paymentMethod payment completed for €${total.toStringAsFixed(2)}.\nWould you like to print a receipt?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Print'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          shouldPrint == true
              ? 'Printing receipt...'
              : 'Sale completed without receipt',
        ),
      ),
    );
  } */

  // new code to show receipt view page after sale completion with the receipt details
  Future<void> _offerReceipt(ReceiptRecord receipt) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptViewPage(receipt: receipt, askToPrint: true),
      ),
    );
  }

  Future<void> _completeSale(String paymentMethod) async {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add items to the basket first')),
      );
      return;
    }

    final now = DateTime.now();
    final saleId = now.microsecondsSinceEpoch.toString();
    final lineItems = _buildSaleLineItems();
    final vatBreakdown = _buildVatBreakdown(lineItems);
    final serverName = _loggedInUser.isEmpty ? 'Unknown Server' : _loggedInUser;
    final total = _cartTotal;

    final sale = SaleRecord(
      id: saleId,
      createdAt: now,
      serverName: serverName,
      paymentMethod: paymentMethod,
      total: total,
      items: lineItems,
      vatBreakdown: vatBreakdown,
    );

    final receipt = ReceiptRecord(
      id: 'R$saleId',
      saleId: saleId,
      shopName: 'MyPOS-Store',
      shopAddress: 'Shop Address Here',
      vatNumber: 'VAT123456',
      createdAt: now,
      serverName: serverName,
      paymentMethod: paymentMethod,
      total: total,
      items: lineItems,
      vatBreakdown: vatBreakdown,
    );

    await SalesStore.instance.saveSale(sale);
    await SalesStore.instance.saveReceipt(receipt);

    setState(() {
      cart.clear();
      _currentInputCents = 0;
      _selectedCartIndex = null;
      _barcodeController.clear();
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sale completed by $paymentMethod: €${total.toStringAsFixed(2)}',
        ),
      ),
    );

    await _offerReceipt(receipt);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final showSideBySide = screenWidth >= 900;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 120,
        leading: TextButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            );
          },
          icon: const Icon(Icons.settings),
          label: const Text('Settings'),
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
        child: Column(
          children: [
            _buildBarcodeEntry(),
            const SizedBox(height: 16),
            Expanded(
              child: showSideBySide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 7,
                          child: CartPanel(
                            cart: cart,
                            total: _cartTotal,
                            selectedIndex: _selectedCartIndex,
                            onIncrease: _increaseQuantity,
                            onDecrease: _decreaseQuantity,
                            onDelete: _removeCartItem,
                            onAddSampleItem: addItem,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(flex: 3, child: _buildPosKeypadPanel()),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: CartPanel(
                            cart: cart,
                            total: _cartTotal,
                            selectedIndex: _selectedCartIndex,
                            onIncrease: _increaseQuantity,
                            onDecrease: _decreaseQuantity,
                            onDelete: _removeCartItem,
                            onAddSampleItem: addItem,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(height: 520, child: _buildPosKeypadPanel()),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarcodeEntry() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.qr_code_scanner, size: 28),
            const SizedBox(width: 12),
            const Text(
              'Item Barcode',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _barcodeController,
                onSubmitted: _handleBarcodeSubmitted,
                decoration: const InputDecoration(
                  hintText: 'Enter or scan barcode',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: () => _handleBarcodeSubmitted(_barcodeController.text),
              child: const Text('Add'),
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
                                onTap: () => _appendDigit('7'),
                              ),
                              KeypadButton(
                                label: '8',
                                onTap: () => _appendDigit('8'),
                              ),
                              KeypadButton(
                                label: '9',
                                onTap: () => _appendDigit('9'),
                              ),
                              KeypadButton(
                                label: '4',
                                onTap: () => _appendDigit('4'),
                              ),
                              KeypadButton(
                                label: '5',
                                onTap: () => _appendDigit('5'),
                              ),
                              KeypadButton(
                                label: '6',
                                onTap: () => _appendDigit('6'),
                              ),
                              KeypadButton(
                                label: '1',
                                onTap: () => _appendDigit('1'),
                              ),
                              KeypadButton(
                                label: '2',
                                onTap: () => _appendDigit('2'),
                              ),
                              KeypadButton(
                                label: '3',
                                onTap: () => _appendDigit('3'),
                              ),
                              KeypadButton(
                                label: '0',
                                onTap: () => _appendDigit('0'),
                              ),
                              KeypadButton(
                                label: '00',
                                onTap: _appendDoubleZero,
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
                            label: 'TENDER',
                            color: Colors.blueGrey,
                            onTap: _handleTender,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ActionButton(
                            label: 'CARD',
                            color: Colors.indigo,
                            onTap: () => _completeSale('Card'),
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
                            onTap: _cancelSale,
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
                onTap: _handleCashPayment,
                isLarge: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<SaleLineItem> _buildSaleLineItems() {
    return cart.map((item) {
      final matchedProduct = ProductStore.instance.products.firstWhere(
        (product) => product.name == item.name,
        orElse: () => Product(
          id: '',
          barcode: '',
          name: item.name,
          salePrice: item.price,
          vatRate: 23,
        ),
      );

      return SaleLineItem(
        name: item.name,
        barcode: matchedProduct.barcode.isEmpty ? null : matchedProduct.barcode,
        quantity: item.quantity,
        unitPrice: item.price,
        vatRate: matchedProduct.vatRate,
      );
    }).toList();
  }

  Map<String, double> _buildVatBreakdown(List<SaleLineItem> items) {
    final Map<String, double> breakdown = {};

    for (final item in items) {
      final rateKey = item.vatRate.toStringAsFixed(
        item.vatRate % 1 == 0 ? 0 : 1,
      );
      final vatAmount = item.lineTotal * item.vatRate / (100 + item.vatRate);
      breakdown[rateKey] = (breakdown[rateKey] ?? 0) + vatAmount;
    }

    return breakdown;
  }
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

class CartItem {
  final String name;
  final double price;
  int quantity;

  CartItem({required this.name, required this.price, required this.quantity});

  double get total => price * quantity;
}

class CartPanel extends StatelessWidget {
  final List<CartItem> cart;
  final double total;
  final int? selectedIndex;
  final void Function(int index) onIncrease;
  final void Function(int index) onDecrease;
  final void Function(int index) onDelete;
  final void Function(String name, double price) onAddSampleItem;

  const CartPanel({
    super.key,
    required this.cart,
    required this.total,
    required this.selectedIndex,
    required this.onIncrease,
    required this.onDecrease,
    required this.onDelete,
    required this.onAddSampleItem,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Cart',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                ValueListenableBuilder<Box<QuickSaleConfig>>(
                  valueListenable: QuickSaleStore.instance.listenable(),
                  builder: (context, box, _) {
                    final buttons = QuickSaleStore.instance.getButtons();

                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: buttons.map((button) {
                        return OutlinedButton(
                          onPressed: () =>
                              onAddSampleItem(button.label, button.price),
                          child: Text('Add ${button.label}'),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: cart.isEmpty
                  ? Center(
                      child: Text(
                        'No items in cart',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    )
                  : ListView.builder(
                      itemCount: cart.length,
                      itemBuilder: (context, index) {
                        final item = cart[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Dismissible(
                            key: ValueKey('${item.name}-${item.price}-$index'),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => onDelete(index),
                            background: Container(
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            child: CartItemTile(
                              index: index,
                              item: item,
                              isSelected: selectedIndex == index,
                              onIncrease: () => onIncrease(index),
                              onDecrease: () => onDecrease(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '€${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartItemTile extends StatelessWidget {
  final int index;
  final CartItem item;
  final bool isSelected;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const CartItemTile({
    super.key,
    required this.index,
    required this.item,
    required this.isSelected,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '${index + 1}.',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              item.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: onDecrease,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: onIncrease,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '€${item.total.toStringAsFixed(2)}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginResult {
  final String username;
  final String password;

  _LoginResult({required this.username, required this.password});
}
