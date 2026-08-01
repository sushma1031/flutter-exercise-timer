import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'settings_service_interface.dart';

class HiveSettingsService implements SettingsService {
  static const String _boxName = 'settings';

  static const String _timerVolume = 'timerVolume';

  late Box settingsBox;

  Future<void> init() async {
    try {
      settingsBox = await Hive.openBox(_boxName);
    } on HiveError catch (e, stackTrace) {
      debugPrint("Error: Could not load data from Hive: $e\n$stackTrace");
      rethrow;
    } on Exception catch (e, stackTrace) {
      debugPrint("Error: Could not load data from Hive: $e\n$stackTrace");
      rethrow;
    }
  }

  @override
  double get timerVolume {
    return settingsBox.get(_timerVolume, defaultValue: 0.5) as double;
  }

  @override
  Future<void> setTimerVolume(double value) async {
    await settingsBox.put(_timerVolume, value.clamp(0.0, 1.0));
  }
}
