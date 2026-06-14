import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:my_pos/models/app_config.dart';
import 'package:my_pos/models/sale_record.dart';
import 'package:my_pos/models/z_report_record.dart';

class ReportStore {
  ReportStore._();

  static final ReportStore instance = ReportStore._();

  static const _lastZCloseKey = 'last_z_report_close_time';

  Box<AppConfig> get _configBox => Hive.box<AppConfig>('app_config');
  Box<ZReportRecord> get _zReportsBox => Hive.box<ZReportRecord>('z_reports');

  ValueListenable<Box<ZReportRecord>> zReportsListenable() =>
      _zReportsBox.listenable();

  DateTime? getLastZCloseTime() {
    final config = _configBox.get(_lastZCloseKey);
    if (config == null || config.value.trim().isEmpty) return null;
    return DateTime.tryParse(config.value);
  }

  List<SaleRecord> getCurrentPeriodSales(List<SaleRecord> sales) {
    final lastClose = getLastZCloseTime();
    if (lastClose == null) return sales;

    return sales.where((sale) => sale.createdAt.isAfter(lastClose)).toList();
  }

  Future<void> closeCurrentPeriod(DateTime closedAt) async {
    await _configBox.put(
      _lastZCloseKey,
      AppConfig(key: _lastZCloseKey, value: closedAt.toIso8601String()),
    );
    await _configBox.flush();
  }

  List<ZReportRecord> getZReports() {
    final reports = _zReportsBox.values.toList()
      ..sort((a, b) {
        final aDate = a.closedAt ?? a.endTime;
        final bDate = b.closedAt ?? b.endTime;
        return bDate.compareTo(aDate);
      });
    return reports;
  }

  Future<void> saveZReport(ZReportRecord report) async {
    await _zReportsBox.put(report.id, report);
    await _zReportsBox.flush();
  }
}
