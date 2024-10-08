import 'package:count_up/models/exercise.dart';
import 'package:flutter/material.dart';
import '../state/workout_provider.dart';

class TimerScreen extends StatelessWidget {
  final List<Exercise> e;
  const TimerScreen({Key? key, required this.e}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Timer',
            style: TextStyle(
                fontFamily: "EthosNova", fontWeight: FontWeight.bold)),
      ),
      body: Center(child: WorkoutProvider(exercises: e)),
    );
  }
}
