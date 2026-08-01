import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:count_up/screens/exercises_screen.dart';
import 'package:count_up/models/workout_display.dart';
import 'package:count_up/widgets/workout_card.dart';
import 'package:count_up/widgets/volume_slider.dart';
import 'package:count_up/utils/format.dart';
import 'package:count_up/utils/errors.dart';
import 'package:count_up/utils/serialise_workout.dart';
import '../widgets/workout_form.dart';
import '../services/storage_service_interface.dart';
import '../state/settings_provider.dart';

enum Actions { deleteAll, importWkt, exportAll }

class WorkoutsScreen extends StatelessWidget {
  final StorageService db;

  WorkoutsScreen({Key? key, required this.db}) : super(key: key);

  List<WorkoutDisplay> _getAllWorkoutsForDisplay() {
    List<WorkoutDisplay> wd = [];
    final workouts = db.getAllWorkouts();
    for (int i = 0; i < workouts.length; i++) {
      var w = workouts[i];
      int total = 0;
      for (var ex in w.exercises) total += ex.duration;
      total = (total / 60).ceil();
      wd.add(WorkoutDisplay(w.name, w.exercises.length, total));
    }
    return wd;
  }

  Future<void> _goToWorkout(BuildContext context, int index) async {
    if (!db.hasWorkoutAt(index)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Workout not found."),
            duration: Duration(milliseconds: 2500)),
      );
      return;
    }
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExercisesScreen(
          index: index,
          db: db,
        ),
      ),
    );

    if (result != null && result == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: Workout no longer available.'),
            duration: Duration(milliseconds: 2500)),
      );
    }
  }

  void _confirmAndDeleteAllWorkouts(BuildContext context) {
    var len = db.size;
    if (len > 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Wrap(
                spacing: 20,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(Icons.error, color: Theme.of(context).colorScheme.error),
                  Text(
                    'Danger Zone',
                  )
                ]),
            content: Text(
              'Are you sure you want to delete $len workouts? This action is irreversible.',
            ),
            actions: <Widget>[
              TextButton(
                  child: Text(
                    'Yes',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    await db.clear();
                    Navigator.pop(context);
                  }),
              TextButton(
                  child: Text(
                    'No',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => Navigator.pop(context)),
            ],
            elevation: 24,
          );
        },
      );
    }
  }

  void _showImportErrorSnackbar(BuildContext context, ImportError error) {
    String message;
    switch (error) {
      case ImportError.format:
        message = "Invalid file format.";
        break;
      case ImportError.type:
        message = "Workout structure is incompatible or malformed.";
        break;
      default:
        message = "Something went wrong while importing.";
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $message")),
    );
  }

  Future<ImportError?> _importWorkout() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null) {
      return null;
    }
    File file = File(result.files.single.path!);
    String workoutJson = await file.readAsString();
    try {
      var workout = importFromJson(workoutJson);
      workout.name =
          getUniqueWorkoutName(db.getAllWorkoutNames(), workout.name);
      await db.addWorkout(workout);
      return null;
    } on FormatException catch (e) {
      print('Invalid JSON: $e');
      return ImportError.format;
    } on TypeError catch (e) {
      print('Type error: $e');
      return ImportError.type;
    } catch (e) {
      print('Unexpected error: $e');
      return ImportError.unknown;
    }
  }

  Future<ExportError?> _exportAllWorkouts() async {
    final workouts = db.getAllWorkouts();
    if (workouts.isEmpty) return ExportError.empty;

    Directory tempDir;
    try {
      tempDir = await getApplicationDocumentsDirectory();
    } on MissingPlatformDirectoryException catch (e) {
      print('Could not access temporary directory: $e');
      return ExportError.platform;
    }

    final archive = Archive();
    for (var w in workouts) {
      final workoutJson = exportJson(w);
      final backupFileName = generateBackupFilename(w.name, withDate: false);
      final archiveFile =
          ArchiveFile.string('$backupFileName.json', workoutJson);
      archive.addFile(archiveFile);
    }
    try {
      final zipData = ZipEncoder().encodeBytes(archive);
      final file =
          File('${tempDir.path}/${generateBackupFilename("count-up")}.zip');
      await file.writeAsBytes(zipData);
      await Share.shareXFiles([XFile(file.path, mimeType: 'application/zip')]);
      await file.delete();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Workouts',
            style:
                TextStyle(fontFamily: "EthosNova", fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
                onPressed: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) {
                        final settings = SettingsProvider.of(context);
                        return Dialog(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Timer', style: TextStyle(fontSize: 16)),
                                VolumeSlider(
                                    initial: settings.timerVolume,
                                    min: 0.2,
                                    onChanged: (value) =>
                                        settings.setTimerVolume(value)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                icon: Icon(Icons.volume_down)),
            PopupMenuButton<Actions>(
                offset: Offset.fromDirection(90, 50),
                onSelected: (value) async {
                  switch (value) {
                    case Actions.importWkt:
                      var error = await _importWorkout();
                      if (error != null) {
                        _showImportErrorSnackbar(context, error);
                      }
                      break;
                    case Actions.deleteAll:
                      _confirmAndDeleteAllWorkouts(context);
                      break;
                    case Actions.exportAll:
                      var error = await _exportAllWorkouts();
                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("Error: Something went wrong.")),
                        );
                      }
                      break;
                  }
                },
                itemBuilder: (context) => <PopupMenuEntry<Actions>>[
                      const PopupMenuItem<Actions>(
                        child: Text('Import Workout'),
                        value: Actions.importWkt,
                      ),
                      const PopupMenuItem<Actions>(
                        child: Text('Export All'),
                        value: Actions.exportAll,
                      ),
                      const PopupMenuItem<Actions>(
                        child: Text('Delete All'),
                        value: Actions.deleteAll,
                      )
                    ]),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          shape: StadiumBorder(),
          child: Icon(Icons.add),
          onPressed: () async {
            var wIdx = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: WorkoutForm(
                    addWorkout: db.addEmptyWorkout,
                    isUnique: (name) {
                      if (!db.getAllWorkoutNames().contains(name)) return true;
                      return false;
                    },
                  ),
                  elevation: 24,
                );
              },
            );
            if (wIdx != null) _goToWorkout(context, wIdx);
          },
        ),
        body: ValueListenableBuilder(
            valueListenable: db.getListenable(),
            builder: (context, _, __) {
              var workouts = _getAllWorkoutsForDisplay();
              return Column(children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 32),
                    itemCount: workouts.length,
                    itemBuilder: (context, index) {
                      return Padding(
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: WorkoutCard(
                            workout: workouts[index],
                            onTap: () => _goToWorkout(context, index),
                          ));
                    },
                  ),
                ),
              ]);
            }));
  }
}
