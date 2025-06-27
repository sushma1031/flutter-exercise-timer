import 'package:count_up/services/audio_service.dart';

class MockAudioService extends AudioService {
  bool configured = false;

  AudioStatus _status = AudioStatus.stopped;

  @override
  Future<void> configure() async {
    configured = true;
  }

  @override
  Future<void> play() async {
    _status = AudioStatus.playing;
  }

  @override
  Future<void> pause() async {
    _status = AudioStatus.paused;
  }

  @override
  Future<void> resume() async {
    _status = AudioStatus.playing;
  }

  @override
  Future<void> stop() async {
    _status = AudioStatus.stopped;
  }

  @override
  Future<void> dispose() async {}

  @override
  AudioStatus get status => _status;

  @override
  set status(AudioStatus value) {
    _status = value;
  }
}
