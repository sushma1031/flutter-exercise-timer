import 'package:flutter/material.dart';
import '../models/exercise.dart';
import './timer_provider.dart' as timer;
import '../widgets/workout_complete.dart' as workout_complete;

class WorkoutManager extends StatefulWidget {
  final List<Exercise> exercises;
  WorkoutManager({Key? key, required this.exercises}) : super(key: key);

  @override
  State<WorkoutManager> createState() => _WorkoutManagerState();
}

class _WorkoutManagerState extends State<WorkoutManager> {
  List<Exercise> _exercises = [];
  int _currentIndex = 0;
  bool _isWorkoutComplete = false;

  @override
  void initState() {
    _exercises = widget.exercises;
    _currentIndex = 0;
    super.initState();
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
      _currentIndex--;
      if (_currentIndex < _exercises.length && _isWorkoutComplete) {
        _isWorkoutComplete = false;
      }
    });
  }

  void printIndex() {
    print("Current: $_currentIndex");
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: _isWorkoutComplete
            ? workout_complete.WorkoutComplete()
            : timer.ExerciseTimerManager(
                duration: Duration(seconds: _exercises[_currentIndex].duration),
                currentIndex: _currentIndex,
                nextExercise: nextExercise,
                previousExercise: previousExercise,
              ));
  }
}
