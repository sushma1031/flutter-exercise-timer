import '../models/exercise.dart';
import '../models/workout.dart';

class StorageService {
  Future<List<Workout>> getAllWorkouts() async {
    // have a function that returns only names of workouts
    List<Exercise> e = [
      new Exercise('Plank', 10),
      new Exercise('Crunches', 5),
    ];
    await Future.delayed(Duration(seconds: 5));
    return [
      new Workout('Abs', e),
      new Workout('Thighs', e),
      new Workout('Biceps', e)
    ];
  }

  Future<List<Exercise>> getWorkoutExercises(String name) async {
    // or should I use index/id?
    List<Exercise> e = [
      new Exercise('Plank', 10),
      new Exercise('Crunches', 5),
    ];
    await Future.delayed(Duration(seconds: 3));
    return e;
  }
}
