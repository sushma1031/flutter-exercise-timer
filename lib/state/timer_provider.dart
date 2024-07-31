import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../utils/duration_format.dart';

class TimerProvider extends StatefulWidget {
  final Duration duration;
  final int currentIndex;
  final ValueChanged<void> nextExercise;
  final ValueChanged<void> previousExercise;
  final AudioCache player;
  const TimerProvider(
      {Key? key,
      required this.duration,
      required this.currentIndex,
      required this.nextExercise,
      required this.previousExercise,
      required this.player})
      : super(key: key);
  @override
  State<TimerProvider> createState() => _TimerProviderState();
}

class _TimerProviderState extends State<TimerProvider> {
  late Timer _timer;
  late Duration _timeLeft;
  late AudioPlayer _playerInstance;
  bool _isPaused = false;
  bool _isAudioPlaying = false;
  @override
  void initState() {
    super.initState();
    _timeLeft = widget.duration;
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft -= Duration(seconds: 1);
        if (_timeLeft.inSeconds == 3) {
          playSound();
        }
        if (_timeLeft.inSeconds <= -1) {
          timer.cancel();
          print("Finished");
          widget.nextExercise(null);
        }
      });
    });
  }

  void pauseTimer() {
    _timer.cancel();
    print("Paused.");
  }

  void resumeTimer() {
    print("Resumed.");
    startTimer();
  }

  void restartTimer() async {
    stopAudioIfPlaying();
    if (!_isPaused) _timer.cancel();
    print("Restarting...");
    setState(() {
      _timeLeft = widget.duration;
    });
    if (!_isPaused) startTimer();
  }

  void playSound() async {
    print("Playing audio...");
    _playerInstance = await widget.player.play('audio/exercise_change.mp3');
    _isAudioPlaying = true;
  }

  void stopAudioIfPlaying() async {
    if (_isAudioPlaying) {
      await _playerInstance.stop();
      _isAudioPlaying = false;
    }
  }

  @override
  void didUpdateWidget(old) {
    super.didUpdateWidget(old);
    _timeLeft = widget.duration;

    // perform any other operations here, like setting a short break, etc.

    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    stopAudioIfPlaying();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // all this should go into other widgets, including ReverseCircular...
    return SizedBox(
        height: 300,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                  child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: <Widget>[
                    Center(
                      child: Text('${formatDuration(_timeLeft)}',
                          style: TextStyle(
                            fontSize: 55,
                            fontWeight: FontWeight.w300,
                          )),
                    )
                  ])),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                      tooltip: 'Pause/Resume',
                      onPressed: () {
                        setState(() {
                          _isPaused = !_isPaused;
                          if (_isPaused) {
                            pauseTimer();
                          } else {
                            resumeTimer();
                          }
                        });
                      },
                      icon: Icon((_isPaused ? Icons.play_arrow : Icons.pause),
                          color: Colors.blueGrey)),
                  IconButton(
                      tooltip: 'Replay',
                      onPressed: () {
                        restartTimer();
                      },
                      icon: Icon(Icons.replay, color: Colors.blueGrey)),
                ],
              )
            ]));
  }
}
