import '../models/exercise.dart';
import 'package:flutter/material.dart';
import '../screens/timer_screen.dart';

class StaticExerciseList extends StatelessWidget {
  final List<Exercise> exercises;
  const StaticExerciseList({Key? key, required this.exercises})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
          padding: EdgeInsets.only(top: 16),
          child: ElevatedButton(
            onPressed: (exercises.length > 0)
                ? () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TimerScreen(e: exercises)));
                  }
                : null,
            child: const Text('Start Workout'),
          )),
      Expanded(
          child: ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              '${exercises[index].name} : ${exercises[index].duration}s',
            ),
          );
        },
      )),
    ]);
  }
}
