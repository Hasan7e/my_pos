import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:my_pos/models/app_config.dart';

class AppSettings {
  final String currencySymbol;
  final String dateFormat;
  final String timeFormat;

  const AppSettings({
    required this.currencySymbol,
    required this.dateFormat,
    required this.timeFormat,
  });
}

class AppSettingsStore {
  AppSettingsStore._();

  static final AppSettingsStore instance = AppSettingsStore._();

  static const _currencySymbolKey = 'app_currency_symbol';
  static const _dateFormatKey = 'app_date_format';
  static const _timeFormatKey = 'app_time_format';

  Box<AppConfig> get _box => Hive.box<AppConfig>('app_config');

  AppSettings getSettings() {
    return AppSettings(
      currencySymbol: _box.get(_currencySymbolKey)?.value ?? '€',
      dateFormat: _box.get(_dateFormatKey)?.value ?? 'dd/mm/yyyy',
      timeFormat: _box.get(_timeFormatKey)?.value ?? '24-hour',
    );
  }

  String get currencySymbol => getSettings().currencySymbol;

  Future<void> saveSettings(AppSettings settings) async {
    await _box.put(
      _currencySymbolKey,
      AppConfig(key: _currencySymbolKey, value: settings.currencySymbol),
    );
    await _box.put(
      _dateFormatKey,
      AppConfig(key: _dateFormatKey, value: settings.dateFormat),
    );
    await _box.put(
      _timeFormatKey,
      AppConfig(key: _timeFormatKey, value: settings.timeFormat),
    );
    await _box.flush();
  }

  String formatMoney(double amount) {
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  String formatDateTime(DateTime value) {
    final settings = getSettings();
    final date = _formatDate(value, settings.dateFormat);
    final time = _formatTime(value, settings.timeFormat);
    return '$date $time';
  }

  String _formatDate(DateTime value, String format) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();

    switch (format) {
      case 'mm/dd/yyyy':
        return '$month/$day/$year';
      case 'yyyy-mm-dd':
        return '$year-$month-$day';
      case 'dd/mm/yyyy':
      default:
        return '$day/$month/$year';
    }
  }

  String _formatTime(DateTime value, String format) {
    final minute = value.minute.toString().padLeft(2, '0');

    if (format == '12-hour') {
      final period = value.hour >= 12 ? 'PM' : 'AM';
      final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
      return '${hour.toString().padLeft(2, '0')}:$minute $period';
    }

    return '${value.hour.toString().padLeft(2, '0')}:$minute';
  }
}
