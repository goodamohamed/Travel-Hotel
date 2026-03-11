import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart' as ap;
import 'screens/auth_screen.dart';
import 'screens/main_navigation.dart';
import 'screens/splash_screen.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ap.AuthProvider>(
      builder: (context, auth, _) {
        switch (auth.status) {
          case ap.AuthStatus.initial:
            return const SplashScreen(autoNavigate: false);
          case ap.AuthStatus.loading:
            return const _LoadingScreen();
          case ap.AuthStatus.authenticated:
            return const MainNavigation();
          case ap.AuthStatus.unauthenticated:
          case ap.AuthStatus.error:
            return const AuthGate();
        }
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }
}
