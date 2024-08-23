import 'package:flutter/foundation.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_display.dart';

abstract class StorageService<T> {
  late T workouts;

  Future<void> loadData();
  ValueListenable<T> getListenable();
  List<Workout> getAllWorkouts();
  List<WorkoutDisplay> getAllWorkoutsForDisplay();
  List<String> getAllWorkoutNames();
  Workout? getWorkoutByIndex(int index);
  List<Exercise> getWorkoutExercises(int index);
  Future<int> addOneWorkout(String name);
  Future<void> addManyWorkouts(List<String> names);
  Future<Workout?> updateWorkoutName(int index, String name);
  Future<Workout?> addWorkoutExercises(int index, List<Exercise> toAdd);
  Future<Workout?> updateWorkoutExercises(
      int index, List<Exercise> newExercises);
  Future<void> modifyExercise(
      int wIndex, int eIndex, String name, int duration);
  Future<void> deleteWorkout(int index);
  Future<void> close();
  Future<void> clear();
  Future<void> delete();
}
