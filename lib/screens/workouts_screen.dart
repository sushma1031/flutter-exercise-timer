import 'package:exercise_timer/screens/exercises_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/workout_form.dart';
import '../services/storage_service_interface.dart';

class WorkoutsScreen extends StatelessWidget {
  final StorageService db;

  WorkoutsScreen({Key? key, required this.db}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void goToWorkout(int index) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExercisesScreen(
            index: index,
            db: db,
          ),
        ),
      );
    }

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
              isUnique: (name) {
                if (!db.getAllWorkoutNames().contains(name)) return true;
                return false;
              },
              goToWorkout: goToWorkout,
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
                                index: index,
                                db: db,
                              ),
                            ),
                          );
                        },
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red.shade900,
                          ),
                          onPressed: () {
                            if (workouts[index].noOfExercises == 0)
                              db.deleteWorkout(index);
                            else
                              showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      'Danger Zone!',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    content: Text(
                                      'Are you sure you want to delete this workout with ${workouts[index].noOfExercises} exercises?',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                          child: Text('Yes'),
                                          onPressed: () async {
                                            await db.deleteWorkout(index);
                                            Navigator.pop(context);
                                          }),
                                      TextButton(
                                          child: Text('No'),
                                          onPressed: () =>
                                              Navigator.pop(context)),
                                    ],
                                    elevation: 24,
                                  );
                                },
                              );
                          },
                        ),
                      );
                    },
                  ),
                ),
                form!
              ]);
            }));
  }
}
