import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../screens/countdown_screen.dart';
import '../services/timer_audio_service.dart';
import '../screens/timer_screen.dart';
import '../widgets/exercise_item.dart';

class StaticExerciseList extends StatelessWidget {
  final List<Exercise> exercises;
  const StaticExerciseList({Key? key, required this.exercises})
      : super(key: key);

  void countdownAndStart(context) async {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CountdownScreen(
            textSequence:
                List.generate(5, (i) => (5 - i).toString(), growable: false),
            onCompleteAudioPlayer: TimerAudioService("audio/workout_start.mp3"),
            fontSize: 50,
          ),
        )).then((value) {
      if (value == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TimerScreen(
                  e: exercises,
                  player: TimerAudioService("audio/exercise_change.mp3"))),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
          padding: EdgeInsets.only(top: 16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8)),
            onPressed: (exercises.length > 0)
                ? () => countdownAndStart(context)
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
