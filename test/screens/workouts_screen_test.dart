import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../services/mock_storage_service.dart';
import 'package:exercise_timer/main.dart';

void main() {
  var app = MyApp(db: MockStorageService('workoutBox'));
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
}
