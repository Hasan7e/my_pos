import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:my_pos/models/app_config.dart';

class ReceiptSettings {
  final String shopName;
  final String shopAddress;
  final String vatNumber;
  final String footerMessage;

  const ReceiptSettings({
    required this.shopName,
    required this.shopAddress,
    required this.vatNumber,
    required this.footerMessage,
  });
}

class ReceiptSettingsStore {
  ReceiptSettingsStore._();

  static final ReceiptSettingsStore instance = ReceiptSettingsStore._();

  Box<AppConfig> get _box => Hive.box<AppConfig>('app_config');

  static const _shopNameKey = 'receipt_shop_name';
  static const _shopAddressKey = 'receipt_shop_address';
  static const _vatNumberKey = 'receipt_vat_number';
  static const _footerMessageKey = 'receipt_footer_message';

  ReceiptSettings getSettings() {
    return ReceiptSettings(
      shopName: _box.get(_shopNameKey)?.value ?? 'MyPOS-Store',
      shopAddress: _box.get(_shopAddressKey)?.value ?? 'Shop Address Here',
      vatNumber: _box.get(_vatNumberKey)?.value ?? 'VAT123456',
      footerMessage:
          _box.get(_footerMessageKey)?.value ??
          'Thank you for shopping with us',
    );
  }

  Future<void> saveSettings(ReceiptSettings settings) async {
    await _box.put(
      _shopNameKey,
      AppConfig(key: _shopNameKey, value: settings.shopName),
    );
    await _box.put(
      _shopAddressKey,
      AppConfig(key: _shopAddressKey, value: settings.shopAddress),
    );
    await _box.put(
      _vatNumberKey,
      AppConfig(key: _vatNumberKey, value: settings.vatNumber),
    );
    await _box.put(
      _footerMessageKey,
      AppConfig(key: _footerMessageKey, value: settings.footerMessage),
    );
    await _box.flush();
  }
}
