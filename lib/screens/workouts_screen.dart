import 'package:exercise_timer/screens/exercises_screen.dart';
import 'package:exercise_timer/widgets/workout_card.dart';
import 'package:flutter/material.dart';
import '../widgets/workout_form.dart';
import '../services/storage_service_interface.dart';

enum Actions { deleteAll }

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

    void confirmAndDeleteAllWorkouts() {
      var len = db.size;
      if (len > 0) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Wrap(spacing: 20, children: [
                Icon(Icons.warning, color: Theme.of(context).errorColor),
                Text(
                  'Danger Zone!',
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

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Workouts',
            style: TextStyle(fontFamily: "Mulish", fontWeight: FontWeight.bold),
          ),
          actions: [
            PopupMenuButton<Actions>(
                offset: Offset.fromDirection(90, 50),
                onSelected: (value) {
                  switch (value) {
                    case Actions.deleteAll:
                      confirmAndDeleteAllWorkouts();
                      break;
                  }
                },
                itemBuilder: (context) => <PopupMenuEntry<Actions>>[
                      const PopupMenuItem<Actions>(
                        child: Text('Delete All'),
                        value: Actions.deleteAll,
                      ),
                    ]),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            int wIdx = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: WorkoutForm(
                    addWorkout: db.addOneWorkout,
                    isUnique: (name) {
                      if (!db.getAllWorkoutNames().contains(name)) return true;
                      return false;
                    },
                  ),
                  elevation: 24,
                );
              },
            );
            if (wIdx != -1) goToWorkout(wIdx);
          },
        ),
        body: ValueListenableBuilder(
            valueListenable: db.getListenable(),
            builder: (context, _, __) {
              var workouts = db.getAllWorkoutsForDisplay();
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
                            onTap: () => goToWorkout(index),
                          ));
                    },
                  ),
                ),
              ]);
            }));
  }
}
