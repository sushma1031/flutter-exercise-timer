import 'package:flutter/material.dart';
import '../models/exercise.dart';
import './timer_provider.dart';
import '../widgets/workout_complete.dart';
import '../services/audio_service.dart';
import '../services/timer_audio_service.dart';

class WorkoutProvider extends StatefulWidget {
  final List<Exercise> exercises;
  WorkoutProvider({Key? key, required this.exercises}) : super(key: key);

  @override
  State<WorkoutProvider> createState() => _WorkoutProviderState();
}

class _WorkoutProviderState extends State<WorkoutProvider> {
  List<Exercise> _exercises = [];
  int _currentIndex = 0;
  bool _isWorkoutComplete = false;
  late AudioService player;

  @override
  void initState() {
    _exercises = widget.exercises;
    _currentIndex = 0;
    player = TimerAudioService("audio/exercise_change.mp3");
    initAudioPlayer();
    super.initState();
  }

  Future<void> initAudioPlayer() async {
    await player.configure();
  }

  void nextExercise(_) {
    setState(() {
      if (_currentIndex >= _exercises.length - 1) {
        _isWorkoutComplete = true;
      } else
        _currentIndex++;
    });
  }

  void previousExercise(_) {
    setState(() {
      if (_currentIndex > 0) _currentIndex--;
      if (_currentIndex < _exercises.length && _isWorkoutComplete) {
        _isWorkoutComplete = false;
      }
    });
  }

  void restartWorkout() {
    setState(() {
      _currentIndex = 0;
      _isWorkoutComplete = false;
    });
  }

  @override
  void dispose() {
		player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
			child: _isWorkoutComplete
				? WorkoutComplete(
						restartWorkout: restartWorkout,
					)
				: TimerProvider(
						name: _exercises[_currentIndex].name,
						nextName: _currentIndex < _exercises.length - 1 ? _exercises[_currentIndex + 1].name : null,
						duration: Duration(seconds: _exercises[_currentIndex].duration),
						currentIndex: _currentIndex,
						nextExercise: nextExercise,
						previousExercise: previousExercise,
						noOfExercises: _exercises.length - 1,
						workoutProgress: "${_currentIndex + 1}/${_exercises.length}",
						player: player,
					));
	}
}
