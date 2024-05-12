import 'package:flutter/material.dart';
import 'dart:async';

class ExerciseProgressIndicator extends StatefulWidget {
  const ExerciseProgressIndicator({Key key, @required this.duration})
      : super(key: key);
  final Duration duration;
  @override
  State<ExerciseProgressIndicator> createState() =>
      _ExerciseProgressIndicatorState();
}

class _ExerciseProgressIndicatorState extends State<ExerciseProgressIndicator>
    with TickerProviderStateMixin {
  Timer timer;
  Duration _timeLeft;
  @override
  void initState() {
    print(widget.duration);
    _timeLeft = widget.duration;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft -= Duration(seconds: 1);
        if (_timeLeft.inSeconds == 0) {
          timer.cancel();
          print("time's up");
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  String format(Duration d) {
    if (d.inMinutes == 0) return _timeLeft.inSeconds.toString();
    int seconds = d.inSeconds - (d.inMinutes * Duration.secondsPerMinute);
    return '${_timeLeft.inMinutes.toString().padLeft(2, '0')} : $seconds';
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
