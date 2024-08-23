import 'package:hive/hive.dart';
import './exercise.dart';

part 'workout.g.dart';

@HiveType(typeId: 2)
class Workout extends HiveObject {
  @HiveField(0)
  String _name;

  @HiveField(1)
  List<Exercise> _exercises;

  String get name => _name;
  set name(value) => _name = value;

  List<Exercise> get exercises => _exercises;
  set exercises(value) => _exercises = value;

  Workout(this._name, this._exercises);

  @override
  String toString() => this.name;

  Workout.fromWorkout(Workout other)
      : this._name = other.name,
        this._exercises = other.exercises;
}
