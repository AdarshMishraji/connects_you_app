import 'package:connects_you/data/models/setting.dart';

abstract class SettingsEvents {
  const SettingsEvents();
}

class FetchSettingsEvent extends SettingsEvents {
  const FetchSettingsEvent();
}

class SetSettingsEvent extends SettingsEvents {
  final Setting setting;

  const SetSettingsEvent({required this.setting});
}
