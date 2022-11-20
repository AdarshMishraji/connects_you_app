import 'package:connects_you/data/models/setting.dart';
import 'package:connects_you/logic/settings/settings_events.dart';
import 'package:connects_you/repository/secureStorage/secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsBloc extends Bloc<SettingsEvents, Setting> {
  final SecureStorageRepository secureStorageRepository;

  SettingsBloc({required this.secureStorageRepository})
      : super(const Setting()) {
    on<FetchSettingsEvent>(_fetchSettings);
    on<SetSettingsEvent>(_setSettings);
  }

  Future _fetchSettings(FetchSettingsEvent _, Emitter emit) async {
    final settings = await secureStorageRepository.fetchUserThemePreference();
    emit(settings);
  }

  Future _setSettings(SetSettingsEvent event, Emitter emit) async {
    await secureStorageRepository
        .setUserThemePreference(event.setting.themeMode);
    emit(event.setting);
  }
}
