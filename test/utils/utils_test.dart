import 'package:test/test.dart';
import 'package:count_up/utils/format.dart';
import 'package:count_up/utils/validate_exercise.dart';
import 'package:count_up/gen/l10n/app_localizations_en.dart';

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
    final validate = validateExercise(AppLocalizationsEn());

    var l = <String>["Crunches", "15"];
    expect(validate(l), null);
    l = <String>["Crunches", "99"];
    expect(validate(l), null);

    l = ["", "10"];
    expect(validate(l), "Fields cannot be empty");
    l = ["  ", "10"];
    expect(validate(l), "Fields cannot be empty");
    l = ["Crunches", ""];
    expect(validate(l), "Fields cannot be empty");
    l = ["", ""];
    expect(validate(l), "Fields cannot be empty");

    l = ["Crunches", "x"];
    expect(validate(l), "Duration must be in range [1, 999]");
    l = ["Crunches", "0"];
    expect(validate(l), "Duration must be in range [1, 999]");
    l = ["Crunches", "-1"];
    expect(validate(l), "Duration must be in range [1, 999]");
    l = ["Crunches", "1000"];
    expect(validate(l), "Duration must be in range [1, 999]");
  });
}
