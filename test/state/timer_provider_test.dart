import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:exercise_timer/state/timer_provider.dart';

class FakeAudioCache extends AudioCache {
  bool soundPlayed = false;

  @override
  Future<AudioPlayer> play(String fileName,
      {double volume = 1.0,
      bool? isNotification,
      PlayerMode mode = PlayerMode.MEDIA_PLAYER,
      bool stayAwake = false,
      bool recordingActive = false,
      bool? duckAudio}) {
    soundPlayed = true;
    return Future.value(FakeAudioPlayer());
  }
}

class FakeAudioPlayer extends AudioPlayer {}

void main() {
  late FakeAudioCache fakeAudioCache;

  setUp(() {
    fakeAudioCache = FakeAudioCache();
  });

  Widget createWidgetUnderTest(Duration duration, {Key? key}) {
    return MaterialApp(
        home: Scaffold(
      body: TimerProvider(
        key: key,
        duration: duration,
        currentIndex: 0,
        noOfExercises: 1,
        nextExercise: (_) {},
        previousExercise: (_) {},
        player: fakeAudioCache,
      ),
    ));
  }

  testWidgets('initial state of timer is correct', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(Duration(seconds: 5)));
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('timer counts down correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(Duration(seconds: 5)));
    await tester.pump(Duration(seconds: 1));
    expect(find.text('4'), findsOneWidget);
    await tester.pump(Duration(seconds: 4));
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('pause and resume timer', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(Duration(seconds: 5)));

    // Pause the timer
    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();
    await tester.pump(Duration(seconds: 2));
    expect(find.text('5'), findsOneWidget); // Timer should be paused

    // Resume the timer
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();
    await tester.pump(Duration(seconds: 2));
    expect(find.text('3'), findsOneWidget); // Timer should resume
  });

  testWidgets('play sound at 3 seconds remaining', (WidgetTester tester) async {
    final GlobalKey<State<TimerProvider>> timerProviderKey =
        GlobalKey(); // create unique key to identify widget
    Widget testWidget =
        createWidgetUnderTest(Duration(seconds: 5), key: timerProviderKey);
    await tester.pumpWidget(testWidget);
    await tester.pump(Duration(seconds: 1));
    final FakeAudioCache ac =
        timerProviderKey.currentState!.widget.player as FakeAudioCache;
    expect(ac.soundPlayed, false); // Ensure no sound played yet
    await tester.pump(Duration(seconds: 1));
    expect(ac.soundPlayed, true); // Ensure sound played
  });
}
