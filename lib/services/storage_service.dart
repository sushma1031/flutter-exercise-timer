// import 'dart:convert';
// import 'dart:io';
import '../models/exercise.dart';
import '../models/workout.dart';

class StorageService {
//   Future<void> addExerciseList(ExerciseList exerciseList) async {
//     await _exerciseListBox.add(exerciseList);
//   }

  Future<List<Workout>> getWorkouts() async {
    // var input = await File("lib/models/test_data.json").readAsString();
    // var map = jsonDecode(input);
    // return map['workouts'];
    await Future.delayed(Duration(seconds: 1));
    return [];
  }

  Future<Workout> getSingleWorkout({String name = 'default'}) async {
    // or should I use index/id?
    List<Exercise> e = [
      new Exercise('Plank', 10),
      new Exercise('Crunches', 5),
    ];
    await Future.delayed(Duration(seconds: 1));
    return new Workout('Abs', e);
  }

//   Future<void> deleteExerciseList(int index) async {
//     await _exerciseListBox.deleteAt(index);
//   }
}
