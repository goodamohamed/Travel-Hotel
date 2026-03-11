import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final bool autoNavigate;
  const SplashScreen({super.key, this.autoNavigate = true});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _textController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _logoController, curve: const Interval(0.0, 0.5)));
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(_textController);
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _textController, curve: Curves.easeOutCubic));
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _logoController,
                builder: (_, __) => Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.4), width: 2)),
                      child: const Icon(Icons.flight_takeoff,
                          color: Colors.white, size: 52),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              AnimatedBuilder(
                animation: _textController,
                builder: (_, __) => SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textOpacity,
                    child: Column(children: [
                      Text('TravelMate',
                          style: GoogleFonts.playfairDisplay(
                              fontSize: 38,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1)),
                      const SizedBox(height: 8),
                      Text('Your World Awaits',
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white70,
                              letterSpacing: 2)),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 80),
              FadeTransition(
                opacity: _textOpacity,
                child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.6)),
                        strokeWidth: 2)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
