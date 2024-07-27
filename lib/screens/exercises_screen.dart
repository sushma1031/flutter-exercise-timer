import 'package:flutter/material.dart';
import '../models/exercise.dart';
import './timer_screen.dart';

class ExercisesScreen extends StatelessWidget {
  final List<Exercise> exercises;

  ExercisesScreen({Key? key, required this.exercises}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
      ),
      body: Column(children: [
        Padding(
            padding: EdgeInsets.only(top: 16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TimerScreen(e: exercises)));
              },
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
      ]),
    );
  }
}
