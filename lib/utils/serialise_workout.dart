import 'dart:convert';
import 'package:count_up/models/workout.dart';

String exportJson(Workout workout) {
  final workoutJson = JsonEncoder.withIndent('  ').convert(workout);
  return workoutJson;
}

Workout importFromJson(String json) {
  Map<String, dynamic> workoutMap = jsonDecode(json);
  Workout workout = Workout.fromJson(workoutMap);
  return workout;
}
