import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 1)
class Exercise extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int duration;

  Exercise(this.name, this.duration);
}
