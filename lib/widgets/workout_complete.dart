import 'package:flutter/material.dart';

class WorkoutComplete extends StatelessWidget {
  final void Function() restartWorkout;

  WorkoutComplete({Key? key, required this.restartWorkout});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 300,
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text('WORKOUT COMPLETE!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 55,
                  fontWeight: FontWeight.w300,
                )),
            Center(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                  ElevatedButton(
                    onPressed: restartWorkout,
                    child: const Text('Repeat'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Home'),
                  ),
                ])),
          ],
        )));
  }
}
