import 'dart:convert';

import 'package:connects_you/data/models/setting.dart';
import 'package:connects_you/data/models/user.dart';
import 'package:connects_you/data/secureStorage/secure_storage.dart';
import 'package:dart_utils/dart_utils.dart';
import 'package:connects_you/repository/localDB/user_ops.dart';
import 'package:flutter/material.dart';

class SecureStorageRepository {
  SecureStorageRepository._();

  static final SecureStorageRepository _instance = SecureStorageRepository._();

  factory SecureStorageRepository() {
    return _instance;
  }

  SecureStorageDataSource secureStorageDataSource = SecureStorageDataSource();

  final UserOpsRepository userOpsRepository = UserOpsRepository();

  Future<Setting> fetchUserThemePreference() async {
    try {
      final response = await secureStorageDataSource.fetchUserThemePreference();
      if (response != null) {
        return Setting(
            themeMode: response == 'dark'
                ? ThemeMode.dark
                : response == 'light'
                    ? ThemeMode.light
                    : ThemeMode.system);
      }
      return const Setting();
    } catch (error) {
      debugPrint(error.toString());
      return const Setting();
    }
  }

  Future setUserThemePreference(ThemeMode mode) async {
    try {
      return await secureStorageDataSource.setUserThemePreference(mode.name);
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<AuthenticatedUser?> fetchAuthenticatedUser() async {
    final authUserString =
        await secureStorageDataSource.fetchAuthenticatedUser();
    if (authUserString != null) {
      final Map<String, dynamic> authUserTokenUserId =
          jsonDecode(authUserString);
      final authUser = await userOpsRepository
          .fetchLocalUserWithUserId(authUserTokenUserId['userId']);
      if (authUser != null && authUser.privateKey != null) {
        final authenticatedUser = AuthenticatedUser(
          userId: authUser.userId,
          name: authUser.name,
          email: authUser.email,
          photoUrl: authUser.photoUrl,
          publicKey: authUser.publicKey,
          privateKey: authUser.privateKey!,
          token: authUserTokenUserId.get('token', ''),
        );
        return authenticatedUser;
      }
    }
    return null;
  }
}
