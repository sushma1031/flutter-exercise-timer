import 'package:exercise_timer/models/exercise.dart';
import 'package:flutter/material.dart';
import '../state/workout_provider.dart';

class TimerScreen extends StatelessWidget {
  final List<Exercise> e;
  const TimerScreen({Key? key, required this.e}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer'),
      ),
      body: Center(child: WorkoutProvider(exercises: e)),
    );
  }
}
