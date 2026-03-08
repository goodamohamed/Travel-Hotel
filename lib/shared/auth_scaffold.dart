import 'package:flutter/material.dart';

class AuthScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  const AuthScaffold({super.key, required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(title: title),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  const _Header({required this.title});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A63D0), Color(0xFF003B95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 4),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

