import 'package:hive/hive.dart';
import './exercise.dart';

part 'workout.g.dart';

@HiveType(typeId: 2)
class Workout extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final List<Exercise> exercises;

  Workout(this.name, this.exercises);

  Workout.fromWorkout(Workout other)
      : this.name = other.name,
        this.exercises = other.exercises;
}
