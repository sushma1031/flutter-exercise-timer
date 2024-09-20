import 'package:count_up/models/workout.dart';
import 'package:count_up/screens/edit_workout_screen.dart';
import 'package:count_up/screens/edit_exercises_screen.dart';
import 'package:count_up/services/storage_service_interface.dart';
import 'package:count_up/widgets/icon_text_item.dart';
import 'package:flutter/material.dart';
import '../widgets/exercises_form.dart';
import '../widgets/static_exercises_list.dart';

enum View { staticList, add, editWorkout, editExercise }
enum WorkoutActions { addEx, editWkt, editEx, delWkt }

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

  Future<bool> _onWillPop() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Unsaved Changes!',
              ),
              content: Text(
                'Are you sure you want to discard all changes?',
              ),
              actions: <Widget>[
                TextButton(
                    child: Text('Yes'),
                    onPressed: () => Navigator.of(context).pop(true)),
                TextButton(
                    child: Text('No'),
                    onPressed: () => Navigator.of(context).pop(false)),
              ],
            );
          },
        ) ??
        false;
  }

  Future<bool> _confirmAndDeleteWorkouts(int index) async {
    var w = widget.db.getWorkoutByIndex(index)!;
    if (w.exercises.length == 0) {
      return await widget.db.deleteWorkout(index).then((value) => true);
    }
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Wrap(spacing: 20, children: [
            Icon(Icons.warning, color: Theme.of(context).errorColor),
            Text(
              'Danger Zone!',
            )
          ]),
          content: Text(
            'Are you sure you want to delete this workout with ${w.exercises.length} exercises?',
          ),
          actions: <Widget>[
            TextButton(
                child: Text('Yes'),
                onPressed: () async {
                  await widget.db
                      .deleteWorkout(index)
                      .then((value) => Navigator.pop(context, true));
                }),
            TextButton(
                child: Text('No'),
                onPressed: () => Navigator.pop(context, false)),
          ],
          elevation: 24,
        );
      },
    );
  }

  void initState() {
    super.initState();
    _w = widget.db.getWorkoutByIndex(widget.index)!;
    _child = StaticExerciseList(exercises: _w.exercises);
  }

  void _returnToStaticList() {
    setState(() {
      _currentView = View.staticList;
      _child = StaticExerciseList(exercises: _w.exercises);
    });
  }

  String _getAppBarTitle(View view) {
    switch (view) {
      case View.staticList:
        return _w.name;
      case View.add:
        return 'Add Exercises';
      case View.editWorkout:
        return 'Edit Workout';
      case View.editExercise:
        return 'Edit Exercises';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
            leading: _currentView == View.staticList
                ? BackButton()
                : IconButton(
                    onPressed: _returnToStaticList, icon: Icon(Icons.close)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(_getAppBarTitle(_currentView),
                style: TextStyle(
                    fontFamily: "EthosNova", fontWeight: FontWeight.bold)),
            actions: _currentView == View.staticList
                ? [
                    PopupMenuButton<WorkoutActions>(
                        offset: Offset.fromDirection(90, 50),
                        onSelected: (value) async {
                          switch (value) {
                            case WorkoutActions.addEx:
                              setState(() {
                                _currentView = View.add;
                                _child = ExercisesForm(
                                  workoutIndex: widget.index,
                                  addWorkoutExercises:
                                      widget.db.addWorkoutExercises,
                                  returnToStaticList: _returnToStaticList,
                                  onWillPop: _onWillPop,
                                );
                              });
                              break;
                            case WorkoutActions.editWkt:
                              setState(() {
                                _currentView = View.editWorkout;
                                _child = EditWorkoutScreen(
                                    workout: _w,
                                    workoutNames:
                                        widget.db.getAllWorkoutNames(),
                                    index: widget.index,
                                    updateWorkoutName:
                                        widget.db.updateWorkoutName,
                                    updateWorkoutExercises:
                                        widget.db.updateWorkoutExercises,
                                    returnToStaticList: _returnToStaticList,
                                    onWillPop: _onWillPop);
                              });
                              break;
                            case WorkoutActions.editEx:
                              setState(() {
                                _currentView = View.editExercise;
                                _child = EditExercisesScreen(
                                    exercises: _w.exercises,
                                    modifyExercise: widget.db.modifyExercises,
                                    workoutIndex: widget.index,
                                    returnToStaticList: _returnToStaticList,
                                    onWillPop: _onWillPop);
                              });
                              break;
                            case WorkoutActions.delWkt:
                              await _confirmAndDeleteWorkouts(widget.index)
                                  .then((value) {
                                if (value) Navigator.pop(context);
                              });

                              break;
                          }
                        },
                        itemBuilder: (context) =>
                            <PopupMenuEntry<WorkoutActions>>[
                              PopupMenuItem<WorkoutActions>(
                                child: IconTextItem(
                                  icon: Icons.add,
                                  text: 'Add Exercises',
                                ),
                                value: WorkoutActions.addEx,
                              ),
                              PopupMenuItem<WorkoutActions>(
                                child: IconTextItem(
                                  icon: Icons.reorder,
                                  text: 'Edit Workout',
                                ),
                                value: WorkoutActions.editWkt,
                              ),
                              PopupMenuItem<WorkoutActions>(
                                child: IconTextItem(
                                  icon: Icons.edit,
                                  text: 'Edit Exercises',
                                ),
                                value: WorkoutActions.editEx,
                              ),
                              PopupMenuItem<WorkoutActions>(
                                child: IconTextItem(
                                  icon: Icons.delete,
                                  text: 'Delete Workout',
                                ),
                                value: WorkoutActions.delWkt,
                              ),
                            ]),
                  ]
                : []),
        body: _child);
  }
}
