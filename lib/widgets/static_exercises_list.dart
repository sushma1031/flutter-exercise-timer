import '../models/exercise.dart';
import 'package:flutter/material.dart';
import '../screens/timer_screen.dart';
import 'package:count_up/widgets/exercise_item.dart';

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
          child: Padding(
              padding: EdgeInsets.fromLTRB(32, 0, 32, 24),
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  return Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: ExerciseItem(
                          name: exercises[index].name,
                          duration: '${exercises[index].duration}'));
                },
              ))),
    ]);
  }
}
