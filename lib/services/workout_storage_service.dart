import './storage_service_interface.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_display.dart';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WorkoutStorageService implements StorageService<Box<Workout>> {
  final String boxName;
  late Box<Workout> workouts;
  WorkoutStorageService(this.boxName);

  Future<void> loadData() async {
    try {
      workouts = await Hive.openBox<Workout>(boxName);
    } on Exception catch (e) {
      print("Error: Could not load data from Hive.\n$e");
    }
  }

  ValueListenable<Box<Workout>> getListenable() {
    return workouts.listenable();
  }

  List<Workout> getAllWorkouts() {
    return workouts.values.toList();
  }

  List<WorkoutDisplay> getAllWorkoutsForDisplay() {
    List<WorkoutDisplay> wd = [];
    for (int i = 0; i < workouts.length; i++) {
      var w = workouts.getAt(i);
      wd.add(WorkoutDisplay(w!.name, w.exercises.length));
    }
    return wd;
  }

  List<Exercise> getWorkoutExercises(int index) {
    return workouts.getAt(index)!.exercises;
  }

  Future<void> addOneWorkout(String name) async {
    try {
      await workouts.add(Workout(name, []));
    } on Exception catch (ex) {
      print('Error: Could not add workout.\n{$ex}');
    }
  }

  Future<void> addManyWorkouts(List<String> names) async {
    try {
      for (String name in names) await addOneWorkout(name);
    } on Exception catch (ex) {
      print('Error: Could not add workout.\n{$ex}');
    }
  }

  Future<void> updateWorkoutName(int index, String name) async {
    Workout prev = workouts.getAt(index)!;
    await workouts.putAt(index, Workout(name, prev.exercises));
  }

  Future<void> addWorkoutExercises(int index, List<Exercise> toAdd) async {
    Workout w = workouts.getAt(index)!;
    w.exercises.addAll(toAdd);
    await w.save();
  }

  Future<void> updateWorkoutExercises(
      int index, List<Exercise> newExercises) async {
    String name = workouts.getAt(index)!.name;
    await workouts.putAt(index, Workout(name, newExercises));
  }

  Future<void> modifyExercise(
      int wIndex, int eIndex, String name, int duration) async {
    Workout w = workouts.getAt(wIndex)!;
    w.exercises[eIndex] = Exercise(name, duration);
    await workouts.putAt(wIndex, Workout.fromWorkout(w));
  }

  Future<void> deleteWorkout(int index) async {
    await workouts.deleteAt(index);
  }

  Future<void> close() async {
    await workouts.close();
  }

  Future<void> clear() async {
    await workouts.clear();
  }

  Future<void> delete() async {
    await clear();
    await workouts.deleteFromDisk();
  }
}
