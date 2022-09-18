import 'package:connects_you/constants/secureStorageKeys.dart';
import 'package:connects_you/helpers/secureStorage.dart';

class SecureStorageDataSource {
  const SecureStorageDataSource._();
  static const _instance = SecureStorageDataSource._();
  static const instance = _instance;

  Future<String?> fetchUserThemePreference() async {
    return await SecureStorage.instance.read(key: SecureStorageKeys.THEME);
  }

  Future setUserThemePreference(String mode) async {
    return await SecureStorage.instance
        .write(key: SecureStorageKeys.THEME, value: mode);
  }

  Future fetchAuthenticatedUser() async {
    return await SecureStorage.instance.read(key: SecureStorageKeys.AUTH_USER);
  }
}
