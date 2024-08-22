import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'package:exercise_timer/services/workout_storage_service.dart';
import 'package:exercise_timer/models/exercise.dart';
import 'package:exercise_timer/models/workout.dart';

Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  final appDocumentsDir =
      await path_provider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentsDir.path);
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(WorkoutAdapter());
  String box = 'testBox';

  WorkoutStorageService db = WorkoutStorageService(box);
  await db.loadData();
  test('clears box successfully', () async {
    await db.clear();
    expect(db.getAllWorkouts().length, 0);
  });
  test('adds workouts correctly', () async {
    await db.clear();
    await db.addOneWorkout('Abs');
    var workouts = db.getAllWorkouts();
    expect(workouts.length, 1);
    expect(db.getWorkoutByIndex(0)!.name, 'Abs');

    await db.addManyWorkouts(['Thighs', 'Biceps']);
    var workoutNames = db.getAllWorkoutNames();
    expect(workoutNames.length, 3);
    expect(workoutNames, ['Abs', 'Thighs', 'Biceps']);
  });

  test('fetches workouts for display correctly', () async {
    await db.clear();
    await db.addOneWorkout('Abs');
    var workouts = db.getAllWorkoutsForDisplay();
    expect(workouts.length, 1);
    expect(workouts[0].name, 'Abs');
    expect(workouts[0].noOfExercises, 0);
  });

  test('updates workout name correctly', () async {
    await db.clear();
    await db.addOneWorkout('Abs');
    expect(db.getAllWorkouts()[0].name, 'Abs');

    await db.updateWorkoutName(0, 'Thighs');
    expect(db.getAllWorkouts()[0].name, 'Thighs');
  });
  test('adds workout exercises correctly', () async {
    await db.clear();
    await db.addOneWorkout('Abs');
    await db.addWorkoutExercises(0, [Exercise('Plank', 60)]);
    var ex = db.getWorkoutExercises(0);
    expect(ex.length, 1);

    await db.addWorkoutExercises(
        0, [Exercise('Crunches', 40), Exercise('Russian Twist', 40)]);
    ex = db.getWorkoutExercises(0);
    expect(ex.length, 3);

    expect(ex.map((e) => e.name), ['Plank', 'Crunches', 'Russian Twist']);
  });

  test('updates workout exercises correctly', () async {
    await db.clear();
    await db.addOneWorkout('Abs');
    await db.addWorkoutExercises(0, [
      Exercise('Plank', 60),
      Exercise('Crunches', 40),
      Exercise('Russian Twist', 40)
    ]);

    await db.updateWorkoutExercises(
        0, [Exercise('Crunches', 40), Exercise('Russian Twist', 40)]);
    var ex = db.getWorkoutExercises(0);
    expect(ex.length, 2);

    await db.updateWorkoutExercises(
        0, [Exercise('Russian Twist', 40), Exercise('Crunches', 40)]);
    ex = db.getWorkoutExercises(0);
    expect(ex.map((e) => e.name), ['Russian Twist', 'Crunches']);
  });

  test('modifies a workout exercise correctly', () async {
    await db.clear();
    await db.addOneWorkout('Abs');
    await db.addWorkoutExercises(0, [
      Exercise('Plank', 60),
      Exercise('Crunches', 40),
      Exercise('Russian Twist', 40)
    ]);
    await db.modifyExercise(0, 0, 'Push-up', 30);
    var ex = db.getWorkoutExercises(0);
    expect(ex[0].name, 'Push-up');
    expect(ex[0].duration, 30);
  });

  test('deletes a workout successfully', () async {
    await db.clear();
    await db.addManyWorkouts(['Thighs', 'Biceps']);
    expect(db.getAllWorkouts().length, 2);

    await db.deleteWorkout(1);
    var workouts = db.getAllWorkouts();
    expect(workouts.length, 1);
    expect(workouts.where((e) => e.name == "Biceps").length, 0);
  });
  test('closes box successfully', () async {
    await db.close();
    expect(() => db.getAllWorkouts(), throwsA(TypeMatcher<HiveError>()));
  });
  test('deletes box successfully', () async {
    await db.loadData();
    await db.delete();
    expect(() => db.getAllWorkouts(), throwsA(TypeMatcher<HiveError>()));
  });
}
