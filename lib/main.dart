import 'package:flutter/material.dart';
import 'models/workout.dart';
import 'models/exercise.dart';
import 'screens/workouts_screen.dart';
import 'services/storage_service_interface.dart';
import 'services/workout_storage_service.dart';
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
    return MaterialApp(
        title: 'Exercise Timer',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            accentColor: Colors.teal,
            scaffoldBackgroundColor: const Color(0x0A0A0AFF),
            textTheme: Theme.of(context)
                .textTheme
                .apply(bodyColor: Colors.white, displayColor: Colors.white)),
        home: FutureBuilder<void>(
          future: db.loadData(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Scaffold(
                  body: Center(child: Text('Error: ${snapshot.error}')),
                );
              } else {
                return HomePage(db: db);
              }
            } else {
              // waiting
              return Scaffold(
                body: Center(
                    child: Text(
                  'Loading...',
                  style: TextStyle(fontSize: 20),
                )),
              );
            }
          },
        ));
  }
}

class HomePage extends StatelessWidget {
  final StorageService db;
  const HomePage({Key? key, required this.db}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WorkoutsScreen(db: db);
  }
}
