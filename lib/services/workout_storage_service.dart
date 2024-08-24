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

  Future<int> addOneWorkout(String name) async {
    if (name.isNotEmpty && !getAllWorkoutNames().contains(name)) {
      try {
        var w = Workout(name, []);
        await workouts.add(w);
        return workouts.length - 1;
      } on Exception catch (ex) {
        print('Error: Could not add workout.\n{$ex}');
      }
    } else {
      print('Error: Name must be unique and non-empty');
    }
    return -1;
  }

  Future<int> addManyWorkouts(List<String> names) async {
    int added = 0;
    for (String name in names) {
      int result = await addOneWorkout(name);
      if (result != -1) added++;
    }
    return added;
  }

  Future<Workout?> updateWorkoutName(int index, String name) async {
    if (index < 0 || index > workouts.length - 1) {
      print('Error: Workout index out of range.\n');
      return null;
    }
    Workout prev = workouts.getAt(index)!;
    if (name.isNotEmpty &&
        name != prev.name &&
        !getAllWorkoutNames().contains(name)) {
      prev.name = name;
      await prev.save();
    } else {
      print('Error: Name must be unique and non-empty');
    }
    return prev;
  }

  Future<Workout?> addWorkoutExercises(int index, List<Exercise> toAdd) async {
    if (index < 0 || index > workouts.length - 1) {
      print('Error: Workout index out of range.\n');
      return null;
    }
    Workout w = workouts.getAt(index)!;
    if (toAdd.where((e) => e.duration <= 0 || e.duration > 99).isEmpty) {
      w.exercises.addAll(toAdd);
      await w.save();
    } else {
      print('Error: Some exercises have duration <= 0s or > 99s.\n');
    }
    return w;
  }

  Future<Workout?> updateWorkoutExercises(
      int index, List<Exercise> newExercises) async {
    if (index < 0 || index > workouts.length - 1) {
      print('Error: Workout index out of range.\n');
      return null;
    }
    Workout w = getWorkoutByIndex(index)!;
    w.exercises = newExercises;
    await w.save();
    return w;
  }

  Future<int> modifyExercises(int wIdx, List<Map> data) async {
    if (wIdx < 0 || wIdx > workouts.length - 1) {
      print('Error: Workout index out of range.\n');
      return 0;
    }
    int modified = 0;
    Workout w = workouts.getAt(wIdx)!;
    for (int i = 0; i < data.length; i++) {
      var x = data[i];
      if (x['index'] < 0 || x['index'] > w.exercises.length - 1) {
        print('Error: Exercise index out of range.\n');
        continue;
      }
      if (x['duration'] <= 0 || x['duration'] > 99) {
        print('Error: Duration must be within range [1, 99]');
        continue;
      }
      if (x['name'].isEmpty) {
        print('Error: Name must not be empty');
        continue;
      }
      w.exercises[x['index']].name = x['name'];
      w.exercises[x['index']].duration = x['duration'];
      modified++;
    }
    await w.save();
    return modified;
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
