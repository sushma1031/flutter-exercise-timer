import './storage_service_interface.dart';
import '../models/exercise.dart';
import '../models/workout.dart';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WorkoutStorageService implements StorageService<Box<Workout>> {
  final String boxName;
  late Box<Workout> workouts;
  WorkoutStorageService(this.boxName);

  int get size => workouts.length;

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

  List<String> getAllWorkoutNames() {
    return workouts.values.map((w) => w.name).toList();
  }

  bool hasWorkoutAt(int index) {
    return index >= 0 && index < workouts.length && workouts.getAt(index) != null;
  }

  Workout? getWorkoutByIndex(int index) {
    if (index < 0 || index >= workouts.length) {
      print('Error: Workout index out of range.\n');
      return null;
    }
    var w = workouts.getAt(index);
    if (w == null) {
      print('Error: Workout at index $index is null.\n');
    }
    return w;
  }

  List<Exercise> getWorkoutExercises(int index) {
    return workouts.getAt(index)!.exercises;
  }

  Future<int> addWorkout(Workout workout) async {
    try {
      await workouts.add(workout);
      return workouts.length - 1;
    } on Exception catch (ex) {
      print('Error: Could not add workout.\n{$ex}');
    }
    return -1;
  }

  Future<int> addManyWorkouts(List<Workout> workouts) async {
    int addedCount = 0;
    for (Workout wkt in workouts) {
      int result = await addWorkout(wkt);
      if (result != -1) addedCount++;
    }
    return addedCount;
  }

  Future<int> addEmptyWorkout(String name) async {
    return addWorkout(Workout(name, []));
  }

  Future<int> addManyEmptyWorkouts(List<String> names) async {
    int addedCount = 0;
    for (String name in names) {
      int result = await addEmptyWorkout(name);
      if (result != -1) addedCount++;
    }
    return addedCount;
  }

  Future<Workout?> updateWorkoutName(int index, String name) async {
    if (index < 0 || index > workouts.length - 1) {
      print('Error: Workout index out of range.\n');
      return null;
    }
    Workout prev = workouts.getAt(index)!;
    prev.name = name;
    await prev.save();
    return prev;
  }

  Future<Workout?> addWorkoutExercises(int index, List<Exercise> toAdd) async {
    if (index < 0 || index > workouts.length - 1) {
      print('Error: Workout index out of range.\n');
      return null;
    }
    Workout w = workouts.getAt(index)!;
    w.exercises.addAll(toAdd);
    await w.save();
    return w;
  }

  Future<Workout?> updateWorkoutExercises(int index, List<Exercise> newExercises) async {
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
      if (data[i]['index'] < 0 || data[i]['index'] > w.exercises.length - 1) {
        print('Error: Exercise index out of range.\n');
        continue;
      }
      w.exercises[data[i]['index']].name = data[i]['name'];
      w.exercises[data[i]['index']].duration = data[i]['duration'];
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
