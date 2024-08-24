import 'package:exercise_timer/models/workout.dart';
import 'package:exercise_timer/screens/edit_workout_screen.dart';
import 'package:exercise_timer/screens/edit_exercises_screen.dart';
import 'package:exercise_timer/services/storage_service_interface.dart';
import 'package:flutter/material.dart';
import '../widgets/exercises_form.dart';
import '../widgets/static_exercises_list.dart';

enum View { staticList, add, editWorkout, editExercise }

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
            title: _currentView == View.editWorkout
                ? const Text('Edit')
                : _currentView == View.editExercise
                    ? const Text('Edit Exercises')
                    : Text('${_w.name}'),
            actions: _currentView == View.staticList
                ? [
                    IconButton(
                        icon: Icon(Icons.add, color: Colors.black),
                        tooltip: 'Add exercises',
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
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Colors.black,
                      ),
                      tooltip: 'Edit workout',
                      onPressed: () {
                        setState(() {
                          _currentView = View.editWorkout;
                          _child = EditWorkoutScreen(
                              workout: _w,
                              workoutNames: widget.db.getAllWorkoutNames(),
                              index: widget.index,
                              updateWorkoutName: widget.db.updateWorkoutName,
                              updateWorkoutExercises:
                                  widget.db.updateWorkoutExercises,
                              returnToStaticList: returnToStaticList);
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.edit_attributes),
                      tooltip: 'Edit exercises',
                      onPressed: () {
                        setState(() {
                          _currentView = View.editExercise;
                          _child = EditExercisesScreen(
                            exercises: _w.exercises,
                            modifyExercise: widget.db.modifyExercises,
                            workoutIndex: widget.index,
                            returnToStaticList: returnToStaticList,
                          );
                        });
                      },
                    )
                  ]
                : []),
        body: _child);
  }
}
