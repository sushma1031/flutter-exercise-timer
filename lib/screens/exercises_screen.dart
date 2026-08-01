import 'dart:io';

import 'package:count_up/utils/format.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:count_up/models/workout.dart';
import 'package:count_up/screens/edit_workout_screen.dart';
import 'package:count_up/screens/edit_exercises_screen.dart';
import 'package:count_up/services/storage_service_interface.dart';
import 'package:count_up/utils/errors.dart';
import 'package:count_up/utils/serialise_workout.dart';
import 'package:count_up/widgets/icon_text_item.dart';
import 'package:flutter/material.dart';
import '../widgets/exercises_form.dart';
import '../widgets/static_exercises_list.dart';

enum View { staticList, add, editWorkout, editExercise }

enum WorkoutActions { addEx, editWkt, editEx, delWkt, exportWkt }

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
  bool _invalid = false;

  Future<bool> _onPop() async {
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

  Future<bool> _confirmAndDeleteWorkout(int index) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Wrap(
                  spacing: 20,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(Icons.error,
                        color: Theme.of(context).colorScheme.error),
                    Text(
                      'Danger Zone',
                    )
                  ]),
              content: Text(
                'Are you sure you want to delete ${_w.name} (${_w.exercises.length} exercises)?',
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
        ) ??
        false;
  }

  void _showExportErrorSnackbar(ExportError error) {
    String message;
    switch (error) {
      case ExportError.empty:
        message = "Cannot export empty workout.";
        break;
      case ExportError.fs:
        message = "Failed to save the workout file.";
        break;
      case ExportError.platform:
        message = "Could not open share interface.";
        break;
      default:
        message = "Something went wrong while exporting.";
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $message")),
    );
  }

  Future<ExportError?> _exportWorkout(int index) async {
    if (_w.exercises.length == 0) return ExportError.empty;
    try {
      final workoutJson = exportJson(_w);
      final backupFileName = generateBackupFilename(_w.name);
      final tempDir = await getTemporaryDirectory();

      final file = File('${tempDir.path}/$backupFileName.json');
      await file.writeAsString(workoutJson);

      await Share.shareXFiles([XFile(file.path)]);
      return null;
    } on FileSystemException catch (e) {
      print('File system error: $e');
      return ExportError.fs;
    } on PlatformException catch (e) {
      print('Platform share error: $e');
      return ExportError.platform;
    } on Exception catch (e) {
      print('Unexpected error: $e');
      return ExportError.unknown;
    }
  }

  void initState() {
    super.initState();
    final workout = widget.db.getWorkoutByIndex(widget.index);
    if (workout == null) {
      _invalid = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop<bool>(context, false);
      });
      return;
    }
    _w = workout;
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
    if (_invalid)
      return const Center(
        child: CircularProgressIndicator(),
      );
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
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
                                  onPop: _onPop,
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
                                    onPop: _onPop);
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
                                    onPop: _onPop);
                              });
                              break;
                            case WorkoutActions.exportWkt:
                              var error = await _exportWorkout(widget.index);
                              if (error != null) {
                                _showExportErrorSnackbar(error);
                              }
                              break;
                            case WorkoutActions.delWkt:
                              await _confirmAndDeleteWorkout(widget.index)
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
                                  icon: Icons.download,
                                  text: 'Export',
                                ),
                                value: WorkoutActions.exportWkt,
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
