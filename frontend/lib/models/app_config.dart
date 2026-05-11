import 'package:hive_ce/hive.dart';

part 'app_config.g.dart';

@HiveType(typeId: 6)
class AppConfig extends HiveObject {
  @HiveField(0)
  String key;

  @HiveField(1)
  String value;

  AppConfig({required this.key, required this.value});
}
