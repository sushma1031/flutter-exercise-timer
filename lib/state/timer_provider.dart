import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class ExerciseTimerManager extends StatefulWidget {
  final Duration duration;
  final int currentIndex;
  final ValueChanged<void> nextExercise;
  final ValueChanged<void> previousExercise;
  const ExerciseTimerManager(
      {Key? key,
      required this.duration,
      required this.currentIndex,
      required this.nextExercise,
      required this.previousExercise})
      : super(key: key);
  @override
  State<ExerciseTimerManager> createState() => _ExerciseTimerManagerState();
}

class _ExerciseTimerManagerState extends State<ExerciseTimerManager> {
  late Timer timer;
  late Duration _timeLeft;
  late AudioCache player;
  @override
  void initState() {
    super.initState();
    _timeLeft = widget.duration;
    player = AudioCache();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft -= Duration(seconds: 1);
        if (_timeLeft.inSeconds == 3) {
          playSound(player);
        }
        if (_timeLeft.inSeconds <= -1) {
          timer.cancel();
          print("time's up!");
          widget.nextExercise(null);
        }
      });
    });
  }

  void playSound(AudioCache player) async {
    await player.play('audio/exercise_change.mp3');
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
    timer.cancel();
    super.dispose();
  }

  String format(Duration d) {
    if (d.inMinutes == 0) return _timeLeft.inSeconds.toString();
    int seconds = d.inSeconds - (d.inMinutes * Duration.secondsPerMinute);
    return '${_timeLeft.inMinutes.toString().padLeft(2, '0')} : ${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 300,
        child: Center(
            child: Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
              Center(
                child: Text('${format(_timeLeft)}',
                    style: TextStyle(
                      fontSize: 55,
                      fontWeight: FontWeight.w300,
                    )),
              )
            ])));
  }
}
