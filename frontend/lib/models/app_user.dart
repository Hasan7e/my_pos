import 'package:hive_ce/hive.dart';

part 'app_user.g.dart';

@HiveType(typeId: 5)
class AppUser extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String username;

  @HiveField(2)
  String fullName;

  @HiveField(3)
  String? phone;

  @HiveField(4)
  String role;

  @HiveField(5)
  String passwordHash;

  @HiveField(6)
  String passwordSalt;

  @HiveField(7)
  bool isActive;

  @HiveField(8)
  DateTime createdAt;

  AppUser({
    required this.id,
    required this.username,
    required this.fullName,
    this.phone,
    required this.role,
    required this.passwordHash,
    required this.passwordSalt,
    required this.isActive,
    required this.createdAt,
  });

  bool get isAdmin => role == 'Admin';
  bool get isStaff => role == 'Staff';
}
