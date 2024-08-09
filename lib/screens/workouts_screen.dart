import 'package:exercise_timer/screens/exercises_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/workout_form.dart';
import '../services/storage_service_interface.dart';

class WorkoutsScreen extends StatelessWidget {
  final StorageService db;

  WorkoutsScreen({Key? key, required this.db}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Workouts'),
          actions: [
            IconButton(
              icon: Icon(Icons.delete, color: Colors.black),
              onPressed: () {
                db.clear();
              },
            ),
          ],
        ),
        body: ValueListenableBuilder(
            valueListenable: db.getListenable(),
            child: WorkoutForm(
              addWorkout: db.addOneWorkout,
              workoutNames: db.getAllWorkouts().map((e) => e.name).toList(),
            ),
            builder: (context, _, form) {
              var workouts = db.getAllWorkoutsForDisplay();
              return Column(children: [
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
                ),
                form!
              ]);
            }));
  }
}
