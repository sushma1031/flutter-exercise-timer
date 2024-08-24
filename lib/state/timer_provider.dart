import 'dart:async';
import 'package:exercise_timer/widgets/reverse_circular_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../utils/duration_format.dart';

enum AudioStatus { playing, paused, stopped }

class TimerProvider extends StatefulWidget {
  final Duration duration;
  final String name;
  final int currentIndex;
  final int noOfExercises;
  final ValueChanged<void> nextExercise;
  final ValueChanged<void> previousExercise;
  final AudioCache player;
  const TimerProvider(
      {Key? key,
      required this.name,
      required this.duration,
      required this.currentIndex,
      required this.noOfExercises,
      required this.nextExercise,
      required this.previousExercise,
      required this.player})
      : super(key: key);
  @override
  State<TimerProvider> createState() => _TimerProviderState();
}

class _TimerProviderState extends State<TimerProvider>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late Duration _timeLeft;
  late AnimationController _controller;
  AudioPlayer? _playerInstance;
  bool _isPaused = false;
  AudioStatus _audioStatus = AudioStatus.stopped;
  @override
  void initState() {
    super.initState();
    _timeLeft = widget.duration;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..addListener(() {
        setState(() {});
      });
    startTimer();
  }

  void startTimer() {
    _controller.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft -= Duration(seconds: 1);
        if (_timeLeft.inSeconds == 3) {
          playSound();
        }
        if (_timeLeft.inSeconds <= -1) {
          timer.cancel();
          print("Finished");
          _audioStatus = AudioStatus.stopped;
          widget.nextExercise(null);
        }
      });
    });
  }

  Future<void> pauseTimer() async {
    _timer.cancel();
    _controller.stop();
    await pauseSoundIfPlaying();
    print("Paused.");
  }

  Future<void> resumeTimer() async {
    print("Resumed.");
    startTimer();
    _controller.forward(from: _controller.value);
    await resumeSoundIfPaused();
  }

  Future<void> restartTimer() async {
    if (!_isPaused) {
      _timer.cancel();
      _controller.stop();
    }
    print("Restarting...");
    setState(() {
      _timeLeft = widget.duration;
      _controller.duration = widget.duration;
      _controller.reset();
    });
    if (!_isPaused) {
      startTimer();
      _controller.forward();
    }
  }

  Future<void> playSound() async {
    print("Playing audio...");
    _playerInstance = await widget.player.play('audio/exercise_change.mp3');
    _audioStatus = AudioStatus.playing;
  }

  Future<void> pauseSoundIfPlaying() async {
    if (_audioStatus == AudioStatus.playing) {
      _audioStatus = AudioStatus.paused;
      await _playerInstance?.pause();
    }
  }

  Future<void> resumeSoundIfPaused() async {
    if (_audioStatus == AudioStatus.paused) {
      _audioStatus = AudioStatus.playing;
      await _playerInstance?.resume();
    }
  }

  Future<void> stopSoundIfPlaying() async {
    _audioStatus = AudioStatus.stopped;
    await _playerInstance?.stop();
    _playerInstance = null;
  }

  Future<void> goPrevious() async {
    await stopSoundIfPlaying();

    if (widget.duration.inSeconds - _timeLeft.inSeconds > 2) {
      restartTimer();
    } else {
      _timer.cancel();
      _controller.stop();
      widget.previousExercise(null);
      if (_isPaused) {
        setState(() {
          _isPaused = false;
        });
      }
    }
  }

  Future<void> goNext() async {
    await stopSoundIfPlaying();
    _timer.cancel();
    _controller.stop();
    widget.nextExercise(null);
    if (_isPaused) {
      setState(() {
        _isPaused = false;
      });
    }
  }

  @override
  void didUpdateWidget(old) {
    super.didUpdateWidget(old);
    _timeLeft = widget.duration;
    _controller.duration = widget.duration;
    _controller.reset();

    // perform any other operations here, like setting a short break, etc.

    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    stopSoundIfPlaying();
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
                    ReverseCircularProgressIndicator(
                      controller: _controller,
                    ),
                    Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('${widget.name}',
                                style: TextStyle(
                                  fontSize: 20,
                                )),
                            Text('${formatDuration(_timeLeft)}',
                                style: TextStyle(
                                  fontSize: 55,
                                  fontWeight: FontWeight.w300,
                                ))
                          ]),
                    )
                  ])),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                      tooltip: 'Previous',
                      onPressed: goPrevious,
                      icon: Icon(Icons.skip_previous, color: Colors.blueGrey),
                      disabledColor: Colors.grey),
                  IconButton(
                      tooltip: 'Pause/Resume',
                      onPressed: () {
                        if (_isPaused) {
                          resumeTimer();
                        } else {
                          pauseTimer();
                        }
                        setState(() {
                          _isPaused = !_isPaused;
                        });
                      },
                      icon: Icon((_isPaused ? Icons.play_arrow : Icons.pause),
                          color: Colors.blueGrey)),
                  IconButton(
                      tooltip: 'Next',
                      onPressed: widget.currentIndex == widget.noOfExercises
                          ? null
                          : goNext,
                      icon: Icon(Icons.skip_next, color: Colors.blueGrey),
                      disabledColor: Colors.grey)
                ],
              )
            ]));
  }
}
