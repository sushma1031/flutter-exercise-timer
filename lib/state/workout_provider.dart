import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/exercise.dart';
import './timer_provider.dart' as timer;
import '../widgets/workout_complete.dart' as workout_complete;

class WorkoutManager extends StatefulWidget {
  final String name;
  WorkoutManager({Key? key, required this.name}) : super(key: key);

  @override
  State<WorkoutManager> createState() => _WorkoutManagerState();
}

class _WorkoutManagerState extends State<WorkoutManager> {
  final StorageService _storageService = StorageService();
  List<Exercise> _exercises = [];
  int _currentIndex = 0;
  bool _isWorkoutComplete = false;

  @override
  void initState() {
    loadExerciseList();
    super.initState();
  }

  void loadExerciseList() async {
    List<Exercise> e =
        await _storageService.getWorkoutExercises(name: widget.name);
    setState(() {
      _exercises = e;
      _currentIndex = 0;
      printIndex();
    });
  }

  void nextExercise(_) {
    setState(() {
      if (_currentIndex >= _exercises.length - 1) {
        _isWorkoutComplete = true;
      } else
        _currentIndex++;
      printIndex();
    });
  }

  void previousExercise(_) {
    setState(() {
      _currentIndex--;
      if (_currentIndex < _exercises.length && _isWorkoutComplete) {
        _isWorkoutComplete = false;
      }
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
