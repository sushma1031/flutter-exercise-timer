import 'package:test/test.dart';
import 'package:exercise_timer/utils/duration_format.dart';

void main() {
  group('Utility functions work correctly', () {
    test('.formatDuration() formats duration correctly', () {
      var d = Duration(seconds: 60);
      expect(formatDuration(d), equals('01 : 00'));
      d = Duration(seconds: 45);
      expect(formatDuration(d), equals('45'));
    });
  });
}
