import 'package:flutter/foundation.dart';
import 'package:count_up/services/storage_service_interface.dart';
import 'package:count_up/models/exercise.dart';
import 'package:count_up/models/workout.dart';

class WorkoutListValueNotifier extends ValueNotifier<List<Workout>> {
  WorkoutListValueNotifier(List<Workout> value) : super(value);

  void update(List<Workout> newWorkouts) {
    value = newWorkouts;
    notifyListeners();
  }
}

class MockStorageService implements StorageService<List<Workout>> {
  final WorkoutListValueNotifier notifier = WorkoutListValueNotifier([]);
  List<Workout> workouts = [];

  int get size => workouts.length;

  Future<void> loadData() async {
    var e = [Exercise('Plank', 10), Exercise('Crunches', 5)];
    workouts = [Workout('Abs', e), Workout('Thighs', e)];
    notifier.update(workouts);
  }

  @override
  ValueListenable<List<Workout>> getListenable() {
    return notifier;
  }

  List<Workout> getAllWorkouts() {
    return workouts;
  }

  List<String> getAllWorkoutNames() {
    return workouts.map((w) => w.name).toList();
  }

  bool hasWorkoutAt(int index) {
    return index >= 0 && index < workouts.length;
  }


  Workout? getWorkoutByIndex(int index) {
    if (index < 0 || index > workouts.length) {
      print('Error: Workout index out of range.\n');
      return null;
    }
    return workouts[index];
  }

  List<Exercise> getWorkoutExercises(int index) {
    return workouts[index].exercises;
  }

  Future<int> addEmptyWorkout(String name) async {
    var w = Workout(name, []);
    workouts.add(w);
    notifier.update(workouts);
    return Future.value(workouts.length - 1);
  }

  Future<int> addManyEmptyWorkouts(List<String> names) async {
    for (String name in names) addEmptyWorkout(name);
    notifier.update(workouts);
    return Future.value(names.length);
  }
  Future<int> addWorkout(Workout wkt) async {
    workouts.add(wkt);
    notifier.update(workouts);
    return Future.value(workouts.length - 1);
  }

  Future<int> addManyWorkouts(List<Workout> wkts) async {
    for (Workout wkt in wkts) addWorkout(wkt);
    notifier.update(workouts);
    return Future.value(wkts.length);
  }

  Future<Workout?> updateWorkoutName(int index, String name) async {
    workouts[index].name = name;
    notifier.update(workouts);
    return Future.value(workouts[index]);
  }

  Future<Workout?> addWorkoutExercises(int index, List<Exercise> toAdd) async {
    Workout w = workouts[index];
    w.exercises.addAll(toAdd);
    notifier.update(workouts);
    return Future.value(w);
  }

  Future<Workout?> updateWorkoutExercises(
      int index, List<Exercise> newExercises) async {
    workouts[index].exercises = newExercises;
    notifier.update(workouts);
    return Future.value(workouts[index]);
  }

  Future<int> modifyExercises(int wIdx, List<Map> data) async {
    Workout w = workouts[wIdx];
    for (int i = 0; i < data.length; i++) {
      var x = data[i];
      w.exercises[x['index']].name = x['name'];
      w.exercises[x['index']].duration = x['duration'];
    }
    notifier.update(workouts);
    return Future.value(data.length);
  }

  Future<void> deleteWorkout(int index) async {
    workouts.remove(workouts[index]);
    notifier.update(workouts);
    return Future.value();
  }

  Future<void> close() async {
    workouts = [];
    notifier.update(workouts);
    return Future.value();
  }

  Future<void> clear() async {
    workouts = [];
    notifier.update(workouts);
    return Future.value();
  }

  Future<void> delete() async {
    workouts = [];
    notifier.update(workouts);
    return Future.value();
  }
}
