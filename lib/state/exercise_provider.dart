import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import './timer_provider.dart' as timer;

class WorkoutManager extends StatefulWidget {
  WorkoutManager({Key? key}) : super(key: key);

  @override
  State<WorkoutManager> createState() => _WorkoutManagerState();
}

class _WorkoutManagerState extends State<WorkoutManager> {
  final StorageService _storageService = StorageService();
  List<Exercise> _exercises = [];
  late int _currentIndex;

  @override
  void initState() {
    loadExerciseList();
    super.initState();
  }

  void loadExerciseList() async {
    Workout w = await _storageService.getSingleWorkout();
    setState(() {
      _exercises = w.exercises;
      _currentIndex = 0;
      printIndex();
    });
  }

  void nextExercise(_) {
    setState(() {
      if (_currentIndex == _exercises.length - 1)
        _currentIndex = 0;
      else
        _currentIndex++;
      printIndex();
    });
  }

  void previousExercise(_) {
    setState(() {
      _currentIndex--;
      printIndex();
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
        child: timer.ExerciseTimerManager(
      duration: Duration(seconds: _exercises[_currentIndex].duration),
      currentIndex: _currentIndex,
      nextExercise: nextExercise,
      previousExercise: previousExercise,
    ));
  }
}
