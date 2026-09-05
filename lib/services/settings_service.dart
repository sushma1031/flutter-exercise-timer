
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'settings_service_interface.dart';

class HiveSettingsService implements SettingsService {
  static const String _boxName = 'settings';

  static const String _timerVolume = 'timerVolume';
  static const String _preWorkoutCountdownSeconds =
      'preWorkoutCountdownSeconds';

  late Box settingsBox;

  Future<void> init() async {
    try {
      settingsBox = await Hive.openBox(_boxName);
    } on HiveError catch (e, stackTrace) {
      debugPrint("Could not load data from Hive: Hive Error: $e\n$stackTrace");
      rethrow;
    } on Exception catch (e, stackTrace) {
      debugPrint("Could not load data from Hive: Error: $e\n$stackTrace");
      rethrow;
    }
  }

  @override
  double get timerVolume {
    return settingsBox.get(_timerVolume, defaultValue: 0.5) as double;
  }

  @override
  int get preWorkoutCountdownSeconds {
    return settingsBox.get(
      _preWorkoutCountdownSeconds,
      defaultValue: SettingsService.defaultPreWorkoutCountdownSeconds,
    ) as int;
  }

  @override
  Future<void> setTimerVolume(double value) async {
    await settingsBox.put(_timerVolume, value.clamp(0.2, 1.0));
  }

  @override
  Future<void> setPreWorkoutCountdownSeconds(int value) async {
    await settingsBox.put(
      _preWorkoutCountdownSeconds,
      value.clamp(
        SettingsService.minPreWorkoutCountdownSeconds,
        SettingsService.maxPreWorkoutCountdownSeconds,
      ),
    );
  }
}
