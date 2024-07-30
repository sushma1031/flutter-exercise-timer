import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../services/mock_storage_service.dart';
import 'package:exercise_timer/main.dart';

void main() {
  var app = MyApp(db: MockStorageService());
  group('Workouts Screen loads correctly', () {
    testWidgets('- shows "Loading..." when loading workouts', (tester) async {
      await tester.pumpWidget(app);
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('- displays workouts from StorageService correctly',
        (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();
      expect(find.text('Loading...'), findsNothing);
      expect(find.text('Abs'), findsOneWidget);
      expect(find.text('Thighs'), findsOneWidget);
      expect(find.text('Biceps'), findsOneWidget);

      expect(find.byType(ListTile), findsNWidgets(3));
    });
  });
}
