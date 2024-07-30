import 'package:exercise_timer/models/exercise.dart';
import 'package:exercise_timer/screens/exercises_screen.dart';
import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../services/storage_service.dart';

class WorkoutsScreen extends StatelessWidget {
  final List<Workout> workouts;
  final StorageService db;

  WorkoutsScreen({Key? key, required this.workouts, required this.db})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
      ),
      body: ListView.builder(
        itemCount: workouts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(workouts[index].name),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FutureBuilder(
                    future: db.getWorkoutExercises(workouts[index].name),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Exercise>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Scaffold(
                          body: Center(
                              child: Text(
                            'Loading Exercises...',
                            style: TextStyle(fontSize: 20),
                          )),
                        );
                      } else if (snapshot.hasError) {
                        return Scaffold(
                          body: Center(child: Text('Error: ${snapshot.error}')),
                        );
                      } else if (snapshot.hasData) {
                        return ExercisesScreen(exercises: snapshot.data!);
                      } else {
                        return Scaffold(
                          body: Center(child: Text('No Exercises Found.')),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
