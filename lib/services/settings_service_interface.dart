abstract class SettingsService {
  double get timerVolume;

  Future<void> setTimerVolume(double value);
}
