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
    } on HiveError catch (e) {
      print("Error: Could not load data from Hive.\n$e");
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

  List<String> getAllWorkoutNames() {
    return workouts.values.map((w) => w.name).toList();
  }

  Workout? getWorkoutByIndex(int index) {
    if (index < 0 || index > workouts.length) {
      print('Error: Workout index out of range.\n');
      return null;
    }
    return workouts.getAt(index)!;
  }

  List<Exercise> getWorkoutExercises(int index) {
    return workouts.getAt(index)!.exercises;
  }

  Future<void> addOneWorkout(String name) async {
    if (name.isNotEmpty &&
        getAllWorkouts().where((e) => e.name == name).isEmpty) {
      try {
        await workouts.add(Workout(name, []));
      } on Exception catch (ex) {
        print('Error: Could not add workout.\n{$ex}');
      }
    }
  }

  Future<void> addManyWorkouts(List<String> names) async {
    for (String name in names) await addOneWorkout(name);
  }

  Future<void> updateWorkoutName(int index, String name) async {
    Workout prev = workouts.getAt(index)!;
    if (name.isNotEmpty &&
        name != prev.name &&
        getAllWorkouts().where((e) => e.name == name).isEmpty) {
      await workouts.putAt(index, Workout(name, prev.exercises));
    }
  }

  Future<void> addWorkoutExercises(int index, List<Exercise> toAdd) async {
    if (index < 0 || index > workouts.length) {
      print('Error: Workout index out of range.\n');
      return;
    }
    Workout w = workouts.getAt(index)!;
    if (toAdd.where((e) => e.duration <= 0 || e.duration > 99).isEmpty) {
      w.exercises.addAll(toAdd);
      await w.save();
    } else {
      print('Error: Some exercises have duration <= 0s or > 99s.\n');
    }
  }

  Future<void> updateWorkoutExercises(
      int index, List<Exercise> newExercises) async {
    Workout w = getWorkoutByIndex(index)!;
    w.exercises = newExercises;
    await w.save();
  }

  Future<void> modifyExercise(
      int wIndex, int eIndex, String name, int duration) async {
    if (duration <= 0 || duration > 99) {
      print('Error: Duration must be in [1, 100)s.\n');
      return;
    }
    if (wIndex < 0 || wIndex > workouts.length) {
      print('Error: Workout index out of range.\n');
      return;
    }
    Workout w = workouts.getAt(wIndex)!;
    if (eIndex < 0 || eIndex > w.exercises.length) {
      print('Error: Exercise index out of range.\n');
      return;
    }

    w.exercises[eIndex].name = name;
    w.exercises[eIndex].duration = duration;
    await w.save();
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
