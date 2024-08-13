import 'package:exercise_timer/services/storage_service_interface.dart';
import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../widgets/exercises_form.dart';
import '../widgets/static_exercises_list.dart';

class ExercisesScreen extends StatefulWidget {
  final int index;
  final StorageService db;
  const ExercisesScreen({Key? key, required this.db, required this.index})
      : super(key: key);

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  List<Exercise> _exercises = [];
  late Widget _child;
  void initState() {
    super.initState();
    _exercises = widget.db.getWorkoutExercises(widget.index);
    _child = StaticExerciseList(exercises: _exercises);
  }

  void returnToStaticList() {
    setState(() {
      _child = StaticExerciseList(
          exercises: widget.db.getWorkoutExercises(widget.index));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Exercises'), actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.black),
            onPressed: () {
              setState(() {
                _child = ExercisesForm(
                  workoutIndex: widget.index,
                  addWorkoutExercises: widget.db.addWorkoutExercises,
                  returnToStaticList: returnToStaticList,
                );
              });
            },
          ),
        ]),
        body: _child);
  }
}
