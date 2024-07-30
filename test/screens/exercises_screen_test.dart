import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../services/mock_storage_service.dart';
import 'package:exercise_timer/main.dart';

void main() {
  var app = MyApp(db: MockStorageService());
  group('Exercises Screen loads correctly:', () {
    testWidgets('loads and displays exercises correctly', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, 'Abs'));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNWidgets(2));
      expect(find.text('Plank : 10s'), findsOneWidget);
    });
  });
}
