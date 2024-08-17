import 'package:exercise_timer/widgets/exercise_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../services/mock_storage_service.dart';
import 'package:exercise_timer/main.dart';

void main() {
  var app = MyApp(db: MockStorageService());
  group('Exercises Screen loads correctly', () {
    testWidgets('load and display exercises', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, 'Abs'));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNWidgets(2));
      expect(find.text('Plank : 10s'), findsOneWidget);
    });
  });

  testWidgets('switches between static list and form correctly',
      (tester) async {
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Abs'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.byType(ExerciseFormField), findsOneWidget);
    expect(find.byIcon(Icons.add), findsNothing);

    await tester.tap(find.byIcon(Icons.cancel));
    await tester.pump();
    expect(find.byType(ExerciseFormField), findsNothing);
  });
  testWidgets('adds exercise correctly', (tester) async {
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Abs'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    var field = find.byType(ExerciseFormField);
    var n = find.descendant(of: field, matching: find.byType(TextField)).first;
    var d = find.descendant(of: field, matching: find.byType(TextField)).last;
    await tester.enterText(n, 'Crunches');
    await tester.enterText(d, '4');

    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pump();

    field = find.byType(ExerciseFormField).last;
    n = find.descendant(of: field, matching: find.byType(TextField)).first;
    d = find.descendant(of: field, matching: find.byType(TextField)).last;
    await tester.enterText(n, 'Push up');
    await tester.enterText(d, '10');

    await tester.tap(find.ancestor(
        of: find.text('Save'), matching: find.byType(ElevatedButton)));
    await tester.pump();
    expect(find.byType(ListTile), findsNWidgets(4));
    expect(find.text('Crunches : 4s'), findsOneWidget);
    expect(find.text('Push up : 10s'), findsOneWidget);
  });

  testWidgets('handles invalid input correctly', (tester) async {
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Abs'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    var field = find.byType(ExerciseFormField);
    var n = find.descendant(of: field, matching: find.byType(TextField)).first;
    var d = find.descendant(of: field, matching: find.byType(TextField)).last;

    await tester.enterText(n, '');
    await tester.enterText(d, '');
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pump();
    expect(find.text('Fields cannot be empty'), findsOneWidget);

    await tester.enterText(n, 'X');
    await tester.enterText(d, '0');
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pump();
    expect(find.text('Duration must be in range (0, 100)'), findsOneWidget);
  });
}
