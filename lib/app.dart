import 'package:flutter/material.dart';
import 'screens/workouts_screen.dart';
import 'services/storage_service_interface.dart';
import 'services/settings_service_interface.dart';
import 'state/life_cycle_watcher.dart';
import 'state/settings_provider.dart';
import 'utils/color.dart';
import 'utils/errors.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MyApp extends StatelessWidget {
  final StorageService db;
  final SettingsService settings;

  MyApp({required this.db, required this.settings});

  @override
  Widget build(BuildContext context) {
    ColorScheme _colorScheme = ColorScheme.dark().copyWith(
        primary: Colors.indigo.shade200,
        primaryContainer: Colors.indigo.shade700,
        secondary: Colors.deepPurple.shade200,
        secondaryContainer: Colors.deepPurple.shade200,
        error: Color(0xFFCF6765));
    return SettingsProvider(
      settings: settings,
      child: MaterialApp(
          title: 'Count Up',
          theme: ThemeData(
              useMaterial3: false,
              brightness: Brightness.dark,
              primarySwatch: Colors.indigo,
              colorScheme: _colorScheme,
              applyElevationOverlayColor: true,
              snackBarTheme: SnackBarThemeData(
                  backgroundColor: darken(_colorScheme.onSurface, 0.2))),
          home: LifecycleWatcher(
            child: HomePage(db: db),
          )),
    );
  }
}

class HomePage extends StatefulWidget {
  final StorageService db;
  const HomePage({Key? key, required this.db}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> loadDataWithDelay() async {
    await widget.db.loadData();
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: loadDataWithDelay(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          final gradient =
              LinearGradient(colors: [Colors.indigo.shade200, Colors.indigo]);
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: Center(
              child: ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => gradient.createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                child: Text(
                  'COUNT UP',
                  style: TextStyle(
                    fontSize: 40,
                    fontFamily: "EthosNova",
                  ),
                ),
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          final error = snapshot.error;
          String message;
          if (error is HiveError) {
            message = errorMessages[AppError.dbInitFailed]!;
          } else {
            message = errorMessages[AppError.unknown]!;
          }
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsetsGeometry.only(bottom: 24),
                      child: Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.redAccent,
                      )),
                  Text(message,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18)),
                  Padding(
                      padding: EdgeInsetsGeometry.symmetric(vertical: 16),
                      child: Text(
                        "Please try again or come back later.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.8),
                        ),
                      )),
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(vertical: 16),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 0)),
                      onPressed: () {
                        setState(() {});
                      },
                      child: const Text('Retry'),
                    ),
                  )
                ],
              ),
            ),
          );
        } else {
          return WorkoutsScreen(db: widget.db);
        }
      },
    );
  }
}
