import 'package:flutter/material.dart';
import 'models/workout.dart';
import 'models/exercise.dart';
import 'screens/workouts_screen.dart';
import 'services/storage_service_interface.dart';
import 'services/workout_storage_service.dart';
import 'state/life_cycle_watcher.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentsDir =
      await path_provider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentsDir.path);
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(WorkoutAdapter());
  runApp(MyApp(db: WorkoutStorageService('workoutsBox')));
}

class MyApp extends StatelessWidget {
  final StorageService db;

  MyApp({required this.db});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ColorScheme _colorScheme = ColorScheme.dark().copyWith(
        primary: Colors.indigo.shade200,
        primaryVariant: Colors.indigo.shade700,
        secondary: Colors.deepPurple.shade200,
        secondaryVariant: Colors.deepPurple.shade200,
        error: Color(0xFFCF6765));
    return MaterialApp(
        title: 'Exercise Timer',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.indigo,
          colorScheme: _colorScheme,
          errorColor: _colorScheme.error,
          accentColor: _colorScheme.secondaryVariant,
          applyElevationOverlayColor: true,
        ),
        home: LifecycleWatcher(
          child: HomePage(db: db),
        ));
  }
}

class HomePage extends StatelessWidget {
  final StorageService db;
  const HomePage({Key? key, required this.db}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: db.loadData(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.error,
              body: Center(
                  child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Theme.of(context).colorScheme.onError),
              )),
            );
          } else {
            return WorkoutsScreen(db: db);
          }
        } else {
          // waiting
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: Center(
                child: Text(
              'Loading...',
              style: TextStyle(fontSize: 20),
            )),
          );
        }
      },
    );
  }
}
