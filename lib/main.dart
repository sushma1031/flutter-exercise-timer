import 'package:flutter/material.dart';
import 'models/workout.dart';
import 'screens/workouts_screen.dart';
import 'services/storage_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final StorageService storageService = StorageService();
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
        home: FutureBuilder<List<Workout>>(
          future: storageService.getAllWorkouts(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Workout>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(
                    child: Text(
                  'Loading...',
                  style: TextStyle(fontSize: 20),
                )),
              );
            } else if (snapshot.hasError) {
              return Scaffold(
                body: Center(child: Text('Error: ${snapshot.error}')),
              );
            } else if (snapshot.hasData) {
              return HomePage(workouts: snapshot.data!);
            } else {
              return Scaffold(
                body: Center(child: Text('No Workouts Found.')),
              );
            }
          },
        ));
  }
}

class HomePage extends StatelessWidget {
  final List<Workout> workouts;
  const HomePage({Key? key, required this.workouts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WorkoutsScreen(workouts: workouts);
  }
}
