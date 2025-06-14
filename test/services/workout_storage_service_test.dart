import 'dart:io';
import 'package:hive/hive.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:count_up/services/workout_storage_service.dart';
import 'package:count_up/models/exercise.dart';
import 'package:count_up/models/workout.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  Hive.init(Directory.systemTemp.path);
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(WorkoutAdapter());

  TestWidgetsFlutterBinding.ensureInitialized();
  String box = 'testBox';

  tearDownAll(() async {
    await Hive.close();
  });

  WorkoutStorageService db = WorkoutStorageService(box);
  await db.loadData();
  test('clears box successfully', () async {
    await db.clear();
    expect(db.getAllWorkouts().length, 0);
  });

  test('adds workouts correctly', () async {
    await db.clear();
    await db.addEmptyWorkout('Abs');
    var workouts = db.getAllWorkouts();
    expect(workouts.length, 1);
    expect(db.getWorkoutByIndex(0)!.name, 'Abs');

    await db.addManyEmptyWorkouts(['Thighs', 'Biceps']);
    var workoutNames = db.getAllWorkoutNames();
    expect(workoutNames.length, 4);
    expect(workoutNames, ['Abs', 'Abs2', 'Thighs', 'Biceps']);
  });

  test('updates workout name correctly', () async {
    await db.clear();
    await db.addEmptyWorkout('Abs');
    expect(db.getAllWorkouts()[0].name, 'Abs');

    await db.updateWorkoutName(0, 'Thighs');
    expect(db.getAllWorkouts()[0].name, 'Thighs');
  });
  test('adds workout exercises correctly', () async {
    await db.clear();
    await db.addEmptyWorkout('Abs');
    await db.addWorkoutExercises(0, [Exercise('Plank', 60)]);
    var ex = db.getWorkoutExercises(0);
    expect(ex.length, 1);

    await db.addWorkoutExercises(0, [Exercise('Crunches', 40), Exercise('Russian Twist', 40)]);
    ex = db.getWorkoutExercises(0);
    expect(ex.length, 3);

    expect(ex.map((e) => e.name), ['Plank', 'Crunches', 'Russian Twist']);
  });

  test('updates workout exercises correctly', () async {
    await db.clear();
    await db.addEmptyWorkout('Abs');
    await db.addWorkoutExercises(0, [Exercise('Plank', 60), Exercise('Crunches', 40), Exercise('Russian Twist', 40)]);

    await db.updateWorkoutExercises(0, [Exercise('Crunches', 40), Exercise('Russian Twist', 40)]);
    var ex = db.getWorkoutExercises(0);
    expect(ex.length, 2);

    await db.updateWorkoutExercises(0, [Exercise('Russian Twist', 40), Exercise('Crunches', 40)]);
    ex = db.getWorkoutExercises(0);
    expect(ex.map((e) => e.name), ['Russian Twist', 'Crunches']);
  });

  test('modifies a workout exercise correctly', () async {
    await db.clear();
    await db.addEmptyWorkout('Abs');
    await db.addWorkoutExercises(0, [Exercise('Plank', 60), Exercise('Crunches', 40), Exercise('Russian Twist', 40)]);
    await db.modifyExercises(0, [
      {'index': 0, 'name': 'Push-up', 'duration': 30}
    ]);
    var ex = db.getWorkoutExercises(0);
    expect(ex[0].name, 'Push-up');
    expect(ex[0].duration, 30);
  });

  test('deletes a workout successfully', () async {
    await db.clear();
    await db.addManyEmptyWorkouts(['Thighs', 'Biceps']);
    expect(db.getAllWorkouts().length, 2);

    await db.deleteWorkout(1);
    var workouts = db.getAllWorkouts();
    expect(workouts.length, 1);
    expect(workouts.where((e) => e.name == "Biceps").length, 0);
  });
  test('deletes box successfully', () async {
    await db.loadData();
    await db.delete();
    expect(() => db.getAllWorkouts(), throwsA(TypeMatcher<HiveError>()));
  });
  test('closes box successfully', () async {
    await db.close();
    expect(() => db.getAllWorkouts(), throwsA(TypeMatcher<HiveError>()));
  });
}
