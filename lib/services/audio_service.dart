enum AudioStatus { playing, paused, stopped }

abstract class AudioService {
  Future<void> configure() async {
    // Default no-op implementation
  }
  Future<void> play();
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> dispose();

  AudioStatus get status;
  set status(AudioStatus value);
}
