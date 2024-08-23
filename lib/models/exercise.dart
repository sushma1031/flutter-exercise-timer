import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 1)
class Exercise extends HiveObject {
  @HiveField(0)
  String _name;

  @HiveField(1)
  int _duration;

  String get name => _name;
  set name(value) => _name = value;

  int get duration => _duration;
  set duration(value) => _duration = value;

  Exercise(this._name, this._duration);

  @override
  String toString() => "${this.name}, ${this.duration}s";
}
