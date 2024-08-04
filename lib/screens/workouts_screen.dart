import 'package:exercise_timer/screens/exercises_screen.dart';
import 'package:flutter/material.dart';
import '../models/workout_display.dart';
import '../models/exercise.dart';
import '../services/storage_service.dart';

class WorkoutsScreen extends StatelessWidget {
  final List<WorkoutDisplay> workouts;
  final StorageService db;

  WorkoutsScreen({Key? key, required this.workouts, required this.db})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Workouts'),
          actions: [
            IconButton(
              icon: Icon(Icons.delete, color: Colors.black),
              onPressed: () {
                db.delete();
              },
            ),
          ],
        ),
        body: Column(children: [
          ElevatedButton(onPressed: () {}, child: Text('Add')),
          Expanded(
            child: ListView.builder(
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(workouts[index].name),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExercisesScreen(
                            exercises: db.getWorkoutExercises(index)),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ]));
  }
}
