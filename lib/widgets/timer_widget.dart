import 'package:count_up/utils/duration_format.dart';
import 'package:count_up/widgets/offset_animated_text.dart';
import 'package:count_up/widgets/reverse_circular_progress_indicator.dart';
import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  final AnimationController controller;
  final String name;
  final String? nextName;
  final Duration timeLeft;
  final String workoutProgress;
  final Future<void> Function() prevBtnFunction;
  final Future<void> Function()? nextBtnFunction;
  final void Function() togglePauseResume;
  final IconData pauseResume;

  const TimerWidget(
      {Key? key,
      required this.controller,
      required this.name,
      required this.timeLeft,
      required this.prevBtnFunction,
      required this.nextBtnFunction,
      required this.togglePauseResume,
      required this.pauseResume,
      required this.workoutProgress,
      this.nextName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              height: 50,
              child: timeLeft.inSeconds > 5
                  ? Container()
                  : OffsetAnimatedText(
                      nextName != null ? 'Next Up: $nextName' : 'Last one!')),
          SizedBox(
              height: 500,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Center(
                        child: Stack(
                            alignment: AlignmentDirectional.center,
                            children: <Widget>[
                          ReverseCircularProgressIndicator(
                            controller: controller,
                          ),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.only(bottom: 8),
                                          child: Text(name,
                                              style: TextStyle(
                                                fontSize: 18,
                                              ))),
                                      Text('${formatDuration(timeLeft)}',
                                          style: TextStyle(
                                            fontSize: 55,
                                            fontWeight: FontWeight.w300,
                                          ))
                                    ]),
                              ]),
                          Align(
                              heightFactor: 10,
                              alignment: Alignment.bottomCenter,
                              child: Text(
                                workoutProgress,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                              ))
                        ])),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            tooltip: 'Previous',
                            onPressed: prevBtnFunction,
                            icon: Icon(Icons.skip_previous)),
                        IconButton(
                            tooltip: 'Pause/Resume',
                            onPressed: togglePauseResume,
                            icon: Icon(pauseResume)),
                        IconButton(
                          tooltip: 'Next',
                          onPressed: nextBtnFunction,
                          icon: Icon(Icons.skip_next),
                        )
                      ],
                    )
                  ])),
        ]));
  }
}
