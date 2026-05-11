import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:my_pos/models/app_config.dart';
import 'package:my_pos/models/app_user.dart';

class UserStore {
  UserStore._();

  static final UserStore instance = UserStore._();

  static const String _adminPasskeyHashKey = 'admin_passkey_hash';
  static const String _adminPasskeySaltKey = 'admin_passkey_salt';

  Box<AppUser> get _usersBox => Hive.box<AppUser>('users');
  Box<AppConfig> get _configBox => Hive.box<AppConfig>('app_config');

  ValueListenable<Box<AppUser>> usersListenable() => _usersBox.listenable();

  List<AppUser> getUsers() => _usersBox.values.toList();

  AppUser? findByUsername(String username) {
    final normalized = username.trim().toLowerCase();
    for (final user in _usersBox.values) {
      if (user.username.toLowerCase() == normalized) {
        return user;
      }
    }
    return null;
  }

  bool usernameExists(String username, {String? ignoreId}) {
    final normalized = username.trim().toLowerCase();
    for (final user in _usersBox.values) {
      if (user.username.toLowerCase() == normalized && user.id != ignoreId) {
        return true;
      }
    }
    return false;
  }

  bool get hasAdminPasskey =>
      _configBox.containsKey(_adminPasskeyHashKey) &&
      _configBox.containsKey(_adminPasskeySaltKey);

  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  String _hashWithSalt(String value, String salt) {
    final bytes = utf8.encode('$salt::$value');
    return sha256.convert(bytes).toString();
  }

  Future<void> _setAdminPasskey(String passkey) async {
    final salt = _generateSalt();
    final hash = _hashWithSalt(passkey, salt);

    await _configBox.put(
      _adminPasskeyHashKey,
      AppConfig(key: _adminPasskeyHashKey, value: hash),
    );
    await _configBox.put(
      _adminPasskeySaltKey,
      AppConfig(key: _adminPasskeySaltKey, value: salt),
    );
    await _configBox.flush();
  }

  bool validateAdminPasskey(String passkey) {
    final hashConfig = _configBox.get(_adminPasskeyHashKey);
    final saltConfig = _configBox.get(_adminPasskeySaltKey);

    if (hashConfig == null || saltConfig == null) {
      return false;
    }

    final computed = _hashWithSalt(passkey, saltConfig.value);
    return computed == hashConfig.value;
  }

  Future<(bool success, String message)> registerUser({
    required String username,
    required String fullName,
    String? phone,
    required String password,
    required String role,
    String? adminPasskey,
  }) async {
    if (usernameExists(username)) {
      return (false, 'Username already exists');
    }

    if (role == 'Admin') {
      if (adminPasskey == null || adminPasskey.trim().isEmpty) {
        return (false, 'Admin passkey is required');
      }

      if (!hasAdminPasskey) {
        await _setAdminPasskey(adminPasskey.trim());
      } else if (!validateAdminPasskey(adminPasskey.trim())) {
        return (false, 'Invalid admin passkey');
      }
    }

    final passwordSalt = _generateSalt();
    final passwordHash = _hashWithSalt(password, passwordSalt);

    final user = AppUser(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      username: username.trim(),
      fullName: fullName.trim(),
      phone: phone?.trim().isEmpty == true ? null : phone?.trim(),
      role: role,
      passwordHash: passwordHash,
      passwordSalt: passwordSalt,
      isActive: true,
      createdAt: DateTime.now(),
    );

    await _usersBox.put(user.id, user);
    await _usersBox.flush();

    return (true, '$role account created successfully');
  }

  AppUser? authenticate({required String username, required String password}) {
    final user = findByUsername(username);
    if (user == null || !user.isActive) {
      return null;
    }

    final computed = _hashWithSalt(password, user.passwordSalt);
    if (computed != user.passwordHash) {
      return null;
    }

    return user;
  }

  Future<void> setUserActive(String userId, bool isActive) async {
    final user = _usersBox.get(userId);
    if (user == null) return;

    user.isActive = isActive;
    await user.save();
    await _usersBox.flush();
  }
}
