import 'package:exercise_timer/services/storage_service_interface.dart';
import 'package:flutter/material.dart';
import '../widgets/exercises_form.dart';
import '../widgets/static_exercises_list.dart';

enum View { staticList, add, edit }

class ExercisesScreen extends StatefulWidget {
  final int index;
  final StorageService db;
  const ExercisesScreen({Key? key, required this.db, required this.index})
      : super(key: key);

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  late Workout _w;
  var _currentView = View.staticList;
  late Widget _child;
  void initState() {
    super.initState();
    _w = widget.db.getWorkoutByIndex(widget.index)!;
    _child = StaticExerciseList(exercises: _w.exercises);
  }

  void returnToStaticList() {
    setState(() {
      _currentView = View.staticList;
      _child = StaticExerciseList(exercises: _w.exercises);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: _currentView == View.edit
                ? const Text('Edit')
                : Text('${_w.name}'),
            actions: _currentView == View.staticList
                ? [
                    IconButton(
                        icon: Icon(Icons.add, color: Colors.black),
                        onPressed: () {
                          setState(() {
                            _currentView = View.add;
                            _child = ExercisesForm(
                              workoutIndex: widget.index,
                              addWorkoutExercises:
                                  widget.db.addWorkoutExercises,
                              returnToStaticList: returnToStaticList,
                            );
                          });
                        }),
                  ]
                : []),
        body: _child);
  }
}
