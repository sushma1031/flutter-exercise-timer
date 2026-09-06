import 'package:count_up/services/settings_service.dart';

class MockSettingsService implements SettingsService {
  double _timerVolume;
  int _preWorkoutCountdownSeconds;

  @override
  final bool isPersistenceAvailable;

  MockSettingsService({
    double timerVolume = 0.5,
    this.isPersistenceAvailable = true,
    int preWorkoutCountdownSeconds = SettingsService.defaultPreWorkoutCountdownSeconds,
  })  : _timerVolume = timerVolume,
        _preWorkoutCountdownSeconds = preWorkoutCountdownSeconds;

  @override
  double get timerVolume => _timerVolume;

  @override
  int get preWorkoutCountdownSeconds => _preWorkoutCountdownSeconds;

  @override
  Future<void> setTimerVolume(double value) async {
    _timerVolume = value.clamp(0.0, 1.0);
  }

  @override
  Future<void> setPreWorkoutCountdownSeconds(int value) async {
    _preWorkoutCountdownSeconds = value.clamp(
      SettingsService.minPreWorkoutCountdownSeconds,
      SettingsService.maxPreWorkoutCountdownSeconds,
    );
  }
}
