import 'package:count_up/services/settings_service_interface.dart';

class MockSettingsService implements SettingsService {
  double _timerVolume;

  MockSettingsService({double timerVolume = 0.5}) : _timerVolume = timerVolume;

  @override
  double get timerVolume => _timerVolume;

  @override
  Future<void> setTimerVolume(double value) async {
    _timerVolume = value.clamp(0.0, 1.0);
  }
}
