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
import 'package:count_up/widgets/settings_dialog.dart';
import 'package:count_up/utils/format.dart';
import 'package:count_up/utils/errors.dart';
import 'package:count_up/utils/serialise_workout.dart';
import '../widgets/workout_form.dart';
import '../services/storage_service_interface.dart';
import '../state/settings_provider.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

enum Actions { deleteAll, importWkt, exportAll }

class WorkoutsScreen extends StatelessWidget {
  final StorageService db;

  WorkoutsScreen({Key? key, required this.db}) : super(key: key);

  List<WorkoutDisplay> _getAllWorkoutsForDisplay() {
    List<WorkoutDisplay> wd = [];
    final workouts = db.getWorkoutEntries();
    for (var entry in workouts) {
      var w = entry.value;
      int total = 0;
      for (var ex in w.exercises) total += ex.duration;
      total = (total / 60).ceil();
      wd.add(WorkoutDisplay(entry.key, w.name, w.exercises.length, total));
    }
    return wd;
  }

  Future<void> _goToWorkout(BuildContext context, int workoutKey) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExercisesScreen(
          workoutKey: workoutKey,
          db: db,
        ),
      ),
    );

    if (result != null && result == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context).workoutNoLongerAvailable),
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
          final l10n = AppLocalizations.of(context);
          return AlertDialog(
            title: Wrap(
                spacing: 20,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(Icons.error, color: Theme.of(context).colorScheme.error),
                  Text(
                    l10n.dangerZoneTitle,
                  )
                ]),
            content: Text(
              l10n.confirmDeleteWorkouts(len),
            ),
            actions: <Widget>[
              TextButton(
                  child: Text(
                    l10n.yesBtn,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    await db.clear();
                    Navigator.pop(context);
                  }),
              TextButton(
                  child: Text(
                    l10n.noBtn,
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
    final l10n = AppLocalizations.of(context);
    String message;
    switch (error) {
      case ImportError.format:
        message = l10n.importErrorFormat;
        break;
      case ImportError.type:
        message = l10n.importErrorType;
        break;
      default:
        message = l10n.importErrorUnknown;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.errorWithMessage(message))),
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            l10n.workoutsScreenTitle,
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
                          child: SettingsDialog(settings: settings),
                        );
                      },
                    ),
                icon: Icon(Icons.settings)),
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
                          SnackBar(content: Text(l10n.exportAllGenericError)),
                        );
                      }
                      break;
                  }
                },
                itemBuilder: (context) => <PopupMenuEntry<Actions>>[
                      PopupMenuItem<Actions>(
                        child: Text(l10n.importWorkoutMenuItem),
                        value: Actions.importWkt,
                      ),
                      PopupMenuItem<Actions>(
                        child: Text(l10n.exportAllMenuItem),
                        value: Actions.exportAll,
                      ),
                      PopupMenuItem<Actions>(
                        child: Text(l10n.deleteAllMenuItem),
                        value: Actions.deleteAll,
                      )
                    ]),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          shape: StadiumBorder(),
          child: Icon(Icons.add),
          onPressed: () async {
            var workoutKey = await showDialog(
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
            if (workoutKey != null) _goToWorkout(context, workoutKey);
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
                            onTap: () =>
                                _goToWorkout(context, workouts[index].key),
                          ));
                    },
                  ),
                ),
              ]);
            }));
  }
}
