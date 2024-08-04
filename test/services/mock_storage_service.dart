import 'package:exercise_timer/services/storage_service.dart';
import 'package:exercise_timer/models/exercise.dart';
import 'package:exercise_timer/models/workout.dart';
import 'package:exercise_timer/models/workout_display.dart';

class MockStorageService extends StorageService {
  MockStorageService(String boxName) : super(boxName);

  Future<void> loadData() async {
    var e = [Exercise('Plank', 10), Exercise('Crunches', 5)];
    workouts = [Workout('Abs', e), Workout('Thighs', e)];
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

  List<Exercise> getWorkoutExercises(int index) {
    return workouts[index].exercises;
  }

  Future<void> addOneWorkout(String name) async {
    workouts.add(Workout(name, []));
    return Future.value();
  }

  Future<void> addManyWorkouts(List<String> names) async {
    for (String name in names) addOneWorkout(name);
    return Future.value();
  }

  Future<void> updateWorkoutName(int index, String name) async {
    Workout prev = workouts[index];
    workouts[index] = Workout(name, prev.exercises);
    return Future.value();
  }

  Future<void> addWorkoutExercises(int index, List<Exercise> toAdd) async {
    Workout w = workouts[index];
    w.exercises.addAll(toAdd);
    return Future.value();
  }

  Future<void> updateWorkoutExercises(
      int index, List<Exercise> newExercises) async {
    String name = workouts[index].name;
    workouts[index] = Workout(name, newExercises);
    return Future.value();
  }

  Future<void> modifyWorkoutExercise(
      int wIndex, int eIndex, String name, int duration) async {
    Workout w = workouts[wIndex];
    w.exercises[eIndex] = Exercise(name, duration);
    return Future.value();
  }

  Future<void> deleteWorkout(int index) async {
    workouts.remove(workouts[index]);
    return Future.value();
  }

  Future<void> close() async {
    workouts = [];
    return Future.value();
  }

  Future<void> clear() async {
    workouts = [];
    return Future.value();
  }

  Future<void> delete() async {
    workouts = [];
    return Future.value();
  }
}
