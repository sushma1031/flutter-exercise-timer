import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../services/mock_storage_service.dart';
import 'package:exercise_timer/main.dart';

void main() {
  var app = MyApp(db: MockStorageService());
  group('Workouts Screen loads correctly', () {
    testWidgets('show "Loading..." when loading workouts', (tester) async {
      await tester.pumpWidget(app);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('display workouts', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();
      expect(find.text('Loading...'), findsNothing);
      expect(find.text('Abs'), findsOneWidget);
      expect(find.text('Thighs'), findsOneWidget);

      expect(find.byType(ListTile), findsNWidgets(2));
    });
  });

  testWidgets('adds workout correctly', (tester) async {
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Biceps');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Biceps'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.text('Please enter a workout name'), findsOneWidget);
  });

  testWidgets('clears workouts correctly', (tester) async {
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();
    expect(find.byType(ListTile), findsNothing);
  });
}
