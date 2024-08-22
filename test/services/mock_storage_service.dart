import 'package:flutter/foundation.dart';
import 'package:exercise_timer/services/storage_service_interface.dart';
import 'package:exercise_timer/models/exercise.dart';
import 'package:exercise_timer/models/workout.dart';
import 'package:exercise_timer/models/workout_display.dart';

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

  List<WorkoutDisplay> getAllWorkoutsForDisplay() {
    List<WorkoutDisplay> wd = [];
    for (Workout w in workouts)
      wd.add(WorkoutDisplay(w.name, w.exercises.length));
    return wd;
  }

  List<String> getAllWorkoutNames() {
    return workouts.map((w) => w.name).toList();
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

  Future<void> addOneWorkout(String name) async {
    workouts.add(Workout(name, []));
    notifier.update(workouts);
    return Future.value();
  }

  Future<void> addManyWorkouts(List<String> names) async {
    for (String name in names) addOneWorkout(name);
    notifier.update(workouts);
    return Future.value();
  }

  Future<void> updateWorkoutName(int index, String name) async {
    Workout prev = workouts[index];
    workouts[index] = Workout(name, prev.exercises);
    notifier.update(workouts);
    return Future.value();
  }

  Future<void> addWorkoutExercises(int index, List<Exercise> toAdd) async {
    Workout w = workouts[index];
    w.exercises.addAll(toAdd);
    notifier.update(workouts);
    return Future.value();
  }

  Future<void> updateWorkoutExercises(
      int index, List<Exercise> newExercises) async {
    String name = workouts[index].name;
    workouts[index] = Workout(name, newExercises);
    notifier.update(workouts);
    return Future.value();
  }

  Future<void> modifyExercise(
      int wIndex, int eIndex, String name, int duration) async {
    Workout w = workouts[wIndex];
    w.exercises[eIndex] = Exercise(name, duration);
    notifier.update(workouts);
    return Future.value();
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
