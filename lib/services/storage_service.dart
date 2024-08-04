import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_display.dart';
import 'package:hive/hive.dart';

class StorageService {
  final String boxName;
  var workouts;
  StorageService(this.boxName);

  Future<void> loadData() async {
    try {
      workouts = await Hive.openBox<Workout>(boxName);
    } on Exception catch (e) {
      print("Error: Could not load data from Hive.\n$e");
    }
  }

  List<Workout> getAllWorkouts() {
    return workouts.values.toList();
  }

  List<WorkoutDisplay> getAllWorkoutsForDisplay() {
    List<Workout> w = workouts.values.toList() as List<Workout>;
    var wd = w.map((w) => WorkoutDisplay(w.name, w.exercises.length));
    return wd.toList();
  }

  List<Exercise> getWorkoutExercises(int index) {
    return workouts.getAt(index).exercises;
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
    Workout prev = workouts.getAt(index);
    await workouts.putAt(index, Workout(name, prev.exercises));
  }

  Future<void> addWorkoutExercises(int index, List<Exercise> toAdd) async {
    Workout w = workouts.getAt(index);
    w.exercises.addAll(toAdd);
    await w.save();
  }

  Future<void> updateWorkoutExercises(
      int index, List<Exercise> newExercises) async {
    String name = workouts.getAt(index).name;
    await workouts.putAt(index, Workout(name, newExercises));
  }

  Future<void> modifyWorkoutExercise(
      int wIndex, int eIndex, String name, int duration) async {
    Workout w = workouts.getAt(wIndex);
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
