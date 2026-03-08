import 'package:flutter/material.dart';
import 'core/app_state.dart';
import 'core/app_scope.dart';
import 'screens/home_shell.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/app_theme.dart';
import 'screens/onboarding/onboarding_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    state.setFirebaseReady(true);
  } catch (_) {
    state.setFirebaseReady(false);
  }
  runApp(MyApp(state: state));
}

class MyApp extends StatelessWidget {
  final AppState? state;
  const MyApp({super.key, this.state});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final s = state ?? AppState();
    return AppScope(
      notifier: s,
      child: MaterialApp(
        title: 'TravelMate',
        theme: AppTheme.theme(),
        home: const OnboardingPage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const HomeShell();
  }
}
