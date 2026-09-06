import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'settings_service.dart';

class HiveSettingsService implements SettingsService {
  static const String _boxName = 'settings';

  static const String _timerVolume = 'timerVolume';
  static const String _preWorkoutCountdownSeconds = 'preWorkoutCountdownSeconds';

  Box? _settingsBox;
  double _fallbackTimerVolume = 0.5;
  int _fallbackPreWorkoutCountdownSeconds = SettingsService.defaultPreWorkoutCountdownSeconds;

  Future<void> init() async {
    try {
      _settingsBox = await Hive.openBox<dynamic>(_boxName);
    } catch (e, stackTrace) {
      _settingsBox = null;
      debugPrint(
        'Could not open the settings box. Using in-memory defaults: '
        '$e\n$stackTrace',
      );
    }
  }

  @override
  bool get isPersistenceAvailable => _settingsBox != null;

  @override
  double get timerVolume {
    final settingsBox = _settingsBox;
    if (settingsBox == null) return _fallbackTimerVolume;
    return (settingsBox.get(
      _timerVolume,
      defaultValue: _fallbackTimerVolume,
    ) as num)
        .toDouble();
  }

  @override
  int get preWorkoutCountdownSeconds {
    final settingsBox = _settingsBox;
    if (settingsBox == null) return _fallbackPreWorkoutCountdownSeconds;
    return settingsBox.get(
      _preWorkoutCountdownSeconds,
      defaultValue: _fallbackPreWorkoutCountdownSeconds,
    ) as int;
  }

  @override
  Future<void> setTimerVolume(double value) async {
    _fallbackTimerVolume = value.clamp(0.2, 1.0);
    await _settingsBox?.put(_timerVolume, _fallbackTimerVolume);
  }

  @override
  Future<void> setPreWorkoutCountdownSeconds(int value) async {
    _fallbackPreWorkoutCountdownSeconds = value.clamp(
      SettingsService.minPreWorkoutCountdownSeconds,
      SettingsService.maxPreWorkoutCountdownSeconds,
    );
    await _settingsBox?.put(
      _preWorkoutCountdownSeconds,
      _fallbackPreWorkoutCountdownSeconds,
    );
  }
}
