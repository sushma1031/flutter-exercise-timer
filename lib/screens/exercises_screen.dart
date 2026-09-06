import 'dart:io';

import 'package:count_up/utils/format.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:count_up/models/workout.dart';
import 'package:count_up/screens/edit_workout_screen.dart';
import 'package:count_up/screens/edit_exercises_screen.dart';
import 'package:count_up/services/storage_service.dart';
import 'package:count_up/utils/errors.dart';
import 'package:count_up/utils/serialise_workout.dart';
import 'package:count_up/widgets/icon_text_item.dart';
import 'package:flutter/material.dart';
import '../widgets/exercises_form.dart';
import '../widgets/static_exercises_list.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

enum WorkoutView { staticList, add, editWorkout, editExercise }

enum WorkoutAction { addExercise, editWorkout, editExercise, deleteWorkout, exportWorkout }

class ExercisesScreen extends StatefulWidget {
  final int workoutKey;
  final StorageService db;
  const ExercisesScreen({Key? key, required this.db, required this.workoutKey})
      : super(key: key);

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  late Workout _w;
  var _currentView = WorkoutView.staticList;
  late Widget _child;
  bool _invalid = false;

  Future<bool> _onPop() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            final l10n = AppLocalizations.of(context);
            return AlertDialog(
              title: Text(
                l10n.unsavedChangesTitle,
              ),
              content: Text(
                l10n.discardChangesConfirm,
              ),
              actions: <Widget>[
                TextButton(
                    child: Text(l10n.yesBtn),
                    onPressed: () => Navigator.of(context).pop(true)),
                TextButton(
                    child: Text(l10n.noBtn),
                    onPressed: () => Navigator.of(context).pop(false)),
              ],
            );
          },
        ) ??
        false;
  }

  Future<bool> _confirmAndDeleteWorkout(int workoutKey) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            final l10n = AppLocalizations.of(context);
            return AlertDialog(
              title: Wrap(
                  spacing: 20,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(Icons.error,
                        color: Theme.of(context).colorScheme.error),
                    Text(
                      l10n.dangerZoneTitle,
                    )
                  ]),
              content: Text(
                l10n.confirmDeleteWorkout(_w.name, _w.exercises.length),
              ),
              actions: <Widget>[
                TextButton(
                    child: Text(l10n.yesBtn),
                    onPressed: () async {
                      await widget.db
                          .deleteWorkout(workoutKey)
                          .then((value) => Navigator.pop(context, true));
                    }),
                TextButton(
                    child: Text(l10n.noBtn),
                    onPressed: () => Navigator.pop(context, false)),
              ],
              elevation: 24,
            );
          },
        ) ??
        false;
  }

  void _showExportErrorSnackbar(ExportError error) {
    final l10n = AppLocalizations.of(context);
    String message;
    switch (error) {
      case ExportError.empty:
        message = l10n.exportErrorEmpty;
        break;
      case ExportError.fs:
        message = l10n.exportErrorFS;
        break;
      case ExportError.platform:
        message = l10n.exportErrorPlatform;
        break;
      default:
        message = l10n.exportErrorUnknown;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.errorWithMessage(message))),
    );
  }

  Future<ExportError?> _exportWorkout() async {
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
    final workout = widget.db.getWorkout(widget.workoutKey);
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
      _currentView = WorkoutView.staticList;
      _child = StaticExerciseList(exercises: _w.exercises);
    });
  }

  String _getAppBarTitle(BuildContext context, WorkoutView view) {
    final l10n = AppLocalizations.of(context);
    switch (view) {
      case WorkoutView.staticList:
        return _w.name;
      case WorkoutView.add:
        return l10n.addExercisesTitle;
      case WorkoutView.editWorkout:
        return l10n.editWorkoutTitle;
      case WorkoutView.editExercise:
        return l10n.editExercisesTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_invalid)
      return const Center(
        child: CircularProgressIndicator(),
      );
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        appBar: AppBar(
            leading: _currentView == WorkoutView.staticList
                ? BackButton()
                : IconButton(
                    onPressed: _returnToStaticList, icon: Icon(Icons.close)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(_getAppBarTitle(context, _currentView),
                style: TextStyle(
                    fontFamily: "EthosNova", fontWeight: FontWeight.bold)),
            actions: _currentView == WorkoutView.staticList
                ? [
                    PopupMenuButton<WorkoutAction>(
                        offset: Offset.fromDirection(90, 50),
                        onSelected: (value) async {
                          switch (value) {
                            case WorkoutAction.addExercise:
                              setState(() {
                                _currentView = WorkoutView.add;
                                _child = ExercisesForm(
                                  workoutKey: widget.workoutKey,
                                  addWorkoutExercises:
                                      widget.db.addWorkoutExercises,
                                  returnToStaticList: _returnToStaticList,
                                  onPop: _onPop,
                                );
                              });
                              break;
                            case WorkoutAction.editWorkout:
                              setState(() {
                                _currentView = WorkoutView.editWorkout;
                                _child = EditWorkoutScreen(
                                    workout: _w,
                                    workoutNames:
                                        widget.db.getAllWorkoutNames(),
                                    workoutKey: widget.workoutKey,
                                    updateWorkoutName:
                                        widget.db.updateWorkoutName,
                                    updateWorkoutExercises:
                                        widget.db.updateWorkoutExercises,
                                    returnToStaticList: _returnToStaticList,
                                    onPop: _onPop);
                              });
                              break;
                            case WorkoutAction.editExercise:
                              setState(() {
                                _currentView = WorkoutView.editExercise;
                                _child = EditExercisesScreen(
                                    exercises: _w.exercises,
                                    modifyExercise: widget.db.modifyExercises,
                                    workoutKey: widget.workoutKey,
                                    returnToStaticList: _returnToStaticList,
                                    onPop: _onPop);
                              });
                              break;
                            case WorkoutAction.exportWorkout:
                              var error =
                                  await _exportWorkout();
                              if (error != null) {
                                _showExportErrorSnackbar(error);
                              }
                              break;
                            case WorkoutAction.deleteWorkout:
                              await _confirmAndDeleteWorkout(widget.workoutKey)
                                  .then((value) {
                                if (value) Navigator.pop(context);
                              });
                              break;
                          }
                        },
                        itemBuilder: (context) =>
                            <PopupMenuEntry<WorkoutAction>>[
                              PopupMenuItem<WorkoutAction>(
                                child: IconTextItem(
                                  icon: Icons.add,
                                  text: l10n.addExercisesTitle,
                                ),
                                value: WorkoutAction.addExercise,
                              ),
                              PopupMenuItem<WorkoutAction>(
                                child: IconTextItem(
                                  icon: Icons.reorder,
                                  text: l10n.editWorkoutTitle,
                                ),
                                value: WorkoutAction.editWorkout,
                              ),
                              PopupMenuItem<WorkoutAction>(
                                child: IconTextItem(
                                  icon: Icons.edit,
                                  text: l10n.editExercisesTitle,
                                ),
                                value: WorkoutAction.editExercise,
                              ),
                              PopupMenuItem<WorkoutAction>(
                                child: IconTextItem(
                                  icon: Icons.download,
                                  text: l10n.exportMenuItem,
                                ),
                                value: WorkoutAction.exportWorkout,
                              ),
                              PopupMenuItem<WorkoutAction>(
                                child: IconTextItem(
                                  icon: Icons.delete,
                                  text: l10n.deleteWorkoutMenuItem,
                                ),
                                value: WorkoutAction.deleteWorkout,
                              ),
                            ]),
                  ]
                : []),
        body: _child);
  }
}
