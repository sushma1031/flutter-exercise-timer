import 'package:test/test.dart';
import 'package:exercise_timer/utils/duration_format.dart';
import 'package:exercise_timer/utils/validate_exercise.dart';

void main() {
  group('Utility functions work correctly', () {
    test('.formatDuration() formats duration correctly', () {
      var d = Duration(seconds: 60);
      expect(formatDuration(d), equals('01 : 00'));
      d = Duration(seconds: 45);
      expect(formatDuration(d), equals('45'));
    });
  });

  test('.validateExercise() validates exercise name and duration corrrectly',
      () {
    var l = <String>["Crunches", "15"];
    expect(validateExercise(l), null);
    l = <String>["Crunches", "99"];
    expect(validateExercise(l), null);
    l = ["", "10"];
    expect(validateExercise(l), "Fields cannot be empty");
    l = ["  ", "10"];
    expect(validateExercise(l), "Fields cannot be empty");
    l = ["*,%\$#@'", "10"];
    expect(validateExercise(l), "Use only alphanumeric, spaces, ./-");
    l = ["Crunches", ""];
    expect(validateExercise(l), "Fields cannot be empty");
    l = ["", ""];
    expect(validateExercise(l), "Fields cannot be empty");
    l = ["Crunches", "x"];
    expect(validateExercise(l), "Duration must be in range [1, 99]");
    l = ["Crunches", "0"];
    expect(validateExercise(l), "Duration must be in range [1, 99]");
    l = ["Crunches", "-1"];
    expect(validateExercise(l), "Duration must be in range [1, 99]");
    l = ["Crunches", "100"];
    expect(validateExercise(l), "Duration must be in range [1, 99]");
  });
}
