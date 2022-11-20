import 'package:connects_you/constants/secure_storage_keys.dart';
import 'package:connects_you/helpers/secureStorage.dart';

class SecureStorageDataSource {
  const SecureStorageDataSource._();
  static const _instance = SecureStorageDataSource._();

  factory SecureStorageDataSource() {
    return _instance;
  }

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
