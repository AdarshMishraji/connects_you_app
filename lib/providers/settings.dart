import 'package:connects_you/constants/encryptedStorageKeys.dart';
import 'package:connects_you/helpers/secureStorage.dart';
import 'package:flutter/material.dart';

class Settings with ChangeNotifier {
  ThemeMode? _themeMode;

  void _initSettings() async {
    try {
      final value =
          await SecureStorage.instance.read(key: EncryptedStorageKeys.THEME);
      if (value == null) {
        _themeMode = ThemeMode.system;
      } else {
        _themeMode = value == 'dark'
            ? ThemeMode.dark
            : value == 'light'
                ? ThemeMode.light
                : ThemeMode.system;
        if (_themeMode != ThemeMode.system) {
          notifyListeners();
        }
      }
    } catch (_) {
      _themeMode = ThemeMode.system;
    }
  }

  Settings() {
    _initSettings();
  }

  ThemeMode? get theme {
    return _themeMode;
  }

  set theme(ThemeMode? mode) {
    _themeMode = mode;
    SecureStorage.instance
        .write(key: EncryptedStorageKeys.THEME, value: mode!.name);
    notifyListeners();
  }
}
