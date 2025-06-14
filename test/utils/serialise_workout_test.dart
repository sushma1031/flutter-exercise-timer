import 'package:count_up/models/exercise.dart';
import 'package:count_up/models/workout.dart';
import 'package:count_up/utils/serialise_workout.dart';
import 'package:test/test.dart';

void main() {
  group('JSON export works correctly', () {
    test('returns JSON string for valid workout', () {
      final workout = Workout("Abs", [Exercise("Plank", 10)]);
      final jsonResult = exportJson(workout);
      expect(jsonResult, isNotEmpty);
      expect(jsonResult, contains('"name": "Abs"'));
      expect(jsonResult, contains('"exercises"'));
      expect(jsonResult, contains('"name": "Plank"'));
      expect(jsonResult, contains('"duration": 10'));
    });
  });

  group('JSON import works correctly', () {
    test('returns Workout object for valid JSON', () {
      final json = '''
        {
            "name": "Abs",
            "exercises": [
                {
                    "name": "Crunches",
                    "duration": 10
                },
                {
                    "name": "Plank",
                    "duration": 15
                }
            ]
        }
        ''';
      final workout = importFromJson(json);
      expect(workout, isNotNull);
      expect(workout, isA<Workout>());
      expect(workout.exercises, isA<List<Exercise>>());
      expect(workout.name, equals("Abs"));
      expect(workout.exercises.length, 2);
      expect(workout.exercises[0].name, equals("Crunches"));
      expect(workout.exercises[0].duration, equals(10));
    });
    test('throws FormatException for invalid JSON', () {
      final json = '''
        
            "name": "Abs",
            "exercises": [
                {
                    "name": "Crunches",
                    "duration": 10
                },
                {
                    "name": "Plank",
                    "duration": 15
                }
            ]
        }
        ''';
      expect(() => importFromJson(json), throwsA(TypeMatcher<FormatException>()));
    });
    test('throws TypeError for incorrect Workout structure', () {
      final json = '''
        {
            "name": 10,
            "exercises": "not list"
        }
        ''';
      expect(() => importFromJson(json), throwsA(TypeMatcher<TypeError>()));
    });
  });
}
