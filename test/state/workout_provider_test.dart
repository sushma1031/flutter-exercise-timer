import 'package:flutter/material.dart';
import 'package:count_up/models/exercise.dart';
import 'package:count_up/state/workout_provider.dart';
import 'package:count_up/widgets/workout_complete.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final exercises = [Exercise('Plank', 6), Exercise('Crunches', 5)];
  final Widget testWidget =
      MaterialApp(home: Scaffold(body: WorkoutProvider(exercises: exercises)));
  testWidgets('initial exercise and timer duration',
      (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    expect(find.text('6'), findsOneWidget);
    expect(find.text('Plank'), findsOneWidget);
  });

  testWidgets('progress to next exercise', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // advance by duration of first exercise
    await tester.pump(Duration(seconds: 7));
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Crunches'), findsOneWidget);
  });

  testWidgets('navigate to next exercise', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    await tester.tap(find.byIcon(Icons.skip_next));
    await tester.pump();
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Crunches'), findsOneWidget);
  });

  testWidgets('navigate manually to previous exercise',
      (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.pump(Duration(seconds: 7)); //progress to next exercise

    await tester.tap(find.byIcon(Icons.skip_previous));
    await tester.pump();
    expect(find.text('6'), findsOneWidget);
    expect(find.text('Plank'), findsOneWidget);
  });

  testWidgets('restart exercise', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.pump(Duration(seconds: 3));

    await tester.tap(find.byIcon(Icons.skip_previous));
    await tester.pump();
    expect(find.text('6'), findsOneWidget);
    expect(find.text('Plank'), findsOneWidget);
  });

  testWidgets('complete workout and show completion screen',
      (WidgetTester tester) async {
    final exercises = [Exercise('Plank', 2)];
    final Widget testWidget = MaterialApp(
        home: Scaffold(body: WorkoutProvider(exercises: exercises)));
    // Short duration for quick test
    await tester.pumpWidget(testWidget);

    await tester.pump(Duration(seconds: 3));
    await tester.pump();
    expect(find.byType(WorkoutComplete), findsOneWidget);
  });

  testWidgets('disable next button for last exercise',
      (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    final nextIconBtn = find.widgetWithIcon(IconButton, Icons.skip_next);
    expect(tester.widget<IconButton>(nextIconBtn).onPressed == null, false);

    await tester.tap(find.byIcon(Icons.skip_next));
    await tester.pump();

    expect(tester.widget<IconButton>(nextIconBtn).onPressed, null);
  });
}
