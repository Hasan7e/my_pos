import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_pos/data/user_store.dart';
import 'package:my_pos/main.dart';
import 'package:my_pos/models/app_config.dart';
import 'package:my_pos/models/app_user.dart';
import 'package:my_pos/models/product.dart';
import 'package:my_pos/models/quick_sale_config.dart';
import 'package:my_pos/models/receipt_record.dart';
import 'package:my_pos/models/sale_line_item.dart';
import 'package:my_pos/models/sale_record.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Directory testDirectory;

  setUpAll(() async {
    testDirectory = await Directory.systemTemp.createTemp('my_pos_it_');
    Hive.init(testDirectory.path);
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(SaleLineItemAdapter());
    Hive.registerAdapter(SaleRecordAdapter());
    Hive.registerAdapter(ReceiptRecordAdapter());
    Hive.registerAdapter(QuickSaleConfigAdapter());
    Hive.registerAdapter(AppUserAdapter());
    Hive.registerAdapter(AppConfigAdapter());

    await Hive.openBox<Product>('products');
    await Hive.openBox<SaleRecord>('sales');
    await Hive.openBox<ReceiptRecord>('receipts');
    await Hive.openBox<QuickSaleConfig>('quick_sales');
    await Hive.openBox<AppUser>('users');
    await Hive.openBox<AppConfig>('app_config');

    await Hive.box<Product>('products').put(
      'coffee',
      Product(
        id: 'coffee',
        barcode: '123456789',
        name: 'Coffee',
        salePrice: 3.50,
        vatRate: 13.5,
        stockAmount: 10,
      ),
    );
    await UserStore.instance.registerUser(
      username: 'testcashier',
      fullName: 'Test Cashier',
      password: 'test1234',
      role: 'Staff',
    );
  });

  tearDownAll(() async {
    await Hive.close();
    await testDirectory.delete(recursive: true);
  });

  testWidgets('IT01: completes an authenticated card sale', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyPosApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Coffee'));
    await tester.pump();
    await tester.tap(find.text('CARD'));
    await tester.pumpAndSettle();

    final loginDialog = find.byType(AlertDialog);
    final loginFields = find.descendant(
      of: loginDialog,
      matching: find.byType(TextFormField),
    );
    await tester.enterText(loginFields.at(0), 'testcashier');
    await tester.enterText(loginFields.at(1), 'test1234');
    await tester.tap(
      find.descendant(
        of: loginDialog,
        matching: find.widgetWithText(FilledButton, 'Login'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Receipt No:'), findsOneWidget);

    final receiptDialog = find.byType(AlertDialog);
    expect(receiptDialog, findsOneWidget);
    expect(find.text('Would the customer like a receipt?'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: receiptDialog,
        matching: find.widgetWithText(TextButton, 'No'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('MyPOS-Store'), findsOneWidget);

    final sales = Hive.box<SaleRecord>('sales').values.toList();
    final receipts = Hive.box<ReceiptRecord>('receipts').values.toList();
    final coffee = Hive.box<Product>('products').get('coffee');

    expect(sales, hasLength(1));
    expect(sales.single.paymentMethod, 'Card');
    expect(sales.single.total, 3.50);
    expect(receipts, hasLength(1));
    expect(receipts.single.saleId, sales.single.id);
    expect(coffee?.stockAmount, 9);
  });
}
