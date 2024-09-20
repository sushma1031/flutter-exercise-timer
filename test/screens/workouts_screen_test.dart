import 'package:count_up/screens/workouts_screen.dart';
import 'package:count_up/widgets/workout_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:count_up/main.dart';

import '../services/mock_storage_service.dart';

void main() {
  var mockDB = MockStorageService();
  mockDB.loadData();
  var screen = MaterialApp(home: WorkoutsScreen(db: mockDB));
  group('Workouts Screen loads correctly', () {
    testWidgets('display loading screen', (tester) async {
      await tester.pumpWidget(MyApp(db: mockDB));
      expect(find.text('COUNT UP'), findsOneWidget);
      await tester.pump(Duration(seconds: 3));
    });

    testWidgets('display workouts', (tester) async {
      await tester.pumpWidget(screen);
      expect(find.text('COUNT UP'), findsNothing);
      expect(find.text('Abs'), findsOneWidget);
      expect(find.text('Thighs'), findsOneWidget);

      expect(find.byType(WorkoutCard), findsNWidgets(2));
    });
  });

  testWidgets('adds workout correctly', (tester) async {
    await tester.pumpWidget(screen);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await tester.enterText(find.byType(TextFormField), 'Biceps');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(find.text('Biceps'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await tester.enterText(find.byType(TextFormField), '');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.text('Please enter a name'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Abs');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.text('Name already in use'), findsOneWidget);
  });

  testWidgets('clears workouts correctly', (tester) async {
    await tester.pumpWidget(screen);
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete All'));
    await tester.pump();
    await tester.tap(find.text('Yes'));
    await tester.pump();
    expect(find.byType(WorkoutCard), findsNothing);
  });
}
