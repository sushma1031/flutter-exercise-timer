import './exercise.dart';

class Workout {
  String name;
  List<Exercise> exercises;
  Workout(String name, List<Exercise> exercises)
      : this.name = name,
        this.exercises = exercises;
}
