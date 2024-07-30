import 'package:exercise_timer/services/storage_service.dart';
import 'package:exercise_timer/models/exercise.dart';
import 'package:exercise_timer/models/workout.dart';

class MockStorageService extends StorageService {
  Future<List<Workout>> getAllWorkouts() async {
    // have a function that returns only names of workouts
    List<Exercise> e = [
      new Exercise('Plank', 10),
      new Exercise('Crunches', 5),
    ];

    return Future.value([
      new Workout('Abs', e),
      new Workout('Thighs', e),
      new Workout('Biceps', e)
    ]);
  }
}
