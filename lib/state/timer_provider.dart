import 'dart:async';
import 'package:exercise_timer/widgets/timer_widget.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

enum AudioStatus { playing, paused, stopped }

class TimerProvider extends StatefulWidget {
  final Duration duration;
  final String name;
  final String? nextName;
  final String workoutProgress;
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
      required this.player,
      required this.workoutProgress,
      this.nextName})
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
  var oneSec = Duration(seconds: 1);
  @override
  void initState() {
    super.initState();
    _timeLeft = widget.duration;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration + oneSec,
    )..addListener(() {
        setState(() {});
      });
    startTimer();
  }

  Future<void> startTimer() async {
    _controller.forward();
    await widget.player.load('audio/exercise_change.mp3');
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft -= Duration(seconds: 1);
        if (_timeLeft.inSeconds == 3) {
          playSound();
        }
        if (_timeLeft.inSeconds <= -1) {
          timer.cancel();
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
  }

  Future<void> resumeTimer() async {
    startTimer();
    _controller.forward(from: _controller.value);
    await resumeSoundIfPaused();
  }

  Future<void> restartTimer() async {
    if (!_isPaused) {
      _timer.cancel();
      _controller.stop();
    }
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

  void togglePauseResume() {
    if (_isPaused) {
      resumeTimer();
    } else {
      pauseTimer();
    }
    setState(() {
      _isPaused = !_isPaused;
    });
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
    _controller.dispose();
    stopSoundIfPlaying();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Workout Incomplete!',
              ),
              content: Text(
                'Current workout progress will be lost. Are you sure you want to exit?',
              ),
              actions: <Widget>[
                TextButton(
                    child: Text('Yes'),
                    onPressed: () => Navigator.of(context).pop(true)),
                TextButton(
                    child: Text('No'),
                    onPressed: () => Navigator.of(context).pop(false)),
              ],
              elevation: 20,
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          setState(() {
            _isPaused = true;
          });
          pauseTimer();
          return _onWillPop();
        },
        child: TimerWidget(
          name: widget.name,
          nextName: widget.nextName,
          nextBtnFunction:
              widget.currentIndex == widget.noOfExercises ? null : goNext,
          pauseResume: _isPaused ? Icons.play_arrow : Icons.pause,
          togglePauseResume: togglePauseResume,
          timeLeft: _timeLeft,
          workoutProgress: widget.workoutProgress,
          prevBtnFunction: goPrevious,
          controller: _controller,
        ));
  }
}
