import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:my_pos/models/app_config.dart';
import 'package:my_pos/models/product.dart';
import 'package:my_pos/models/quick_sale_config.dart';

import 'package:my_pos/main.dart';

void main() {
  late Directory testDirectory;

  setUpAll(() async {
    testDirectory = await Directory.systemTemp.createTemp('my_pos_test_');
    Hive.init(testDirectory.path);
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(QuickSaleConfigAdapter());
    Hive.registerAdapter(AppConfigAdapter());

    await Hive.openBox<Product>('products');
    await Hive.openBox<QuickSaleConfig>('quick_sales');
    await Hive.openBox<AppConfig>('app_config');
  });

  tearDownAll(() async {
    await Hive.close();
    await testDirectory.delete(recursive: true);
  });

  testWidgets('MyPOS app builds', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyPosApp());
    await tester.pump();

    expect(find.text('MyPOS-Store'), findsOneWidget);
  });

  testWidgets('FT01: card payment requires login', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyPosApp());
    await tester.pump();

    await tester.tap(find.text('Add Coffee'));
    await tester.pump();

    await tester.tap(find.text('CARD'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
  });

  testWidgets('FT02: basket quantity and total update', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyPosApp());
    await tester.pump();

    await tester.tap(find.text('Add Coffee'));
    await tester.pump();

    final cartItem = find.byType(CartItemTile);
    await tester.tap(
      find.descendant(
        of: cartItem,
        matching: find.byIcon(Icons.add_circle_outline),
      ),
    );
    await tester.pump();

    expect(
      find.descendant(of: cartItem, matching: find.text('2')),
      findsOneWidget,
    );
    expect(find.text('€7.00'), findsNWidgets(2));
  });
}
