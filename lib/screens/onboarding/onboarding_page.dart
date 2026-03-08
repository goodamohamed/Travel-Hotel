import 'package:flutter/material.dart';
import '../auth/login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController controller = PageController();
  int index = 0;

  final items = const [
    _OnboardingItem(
      imageAsset: 'assets/images/onboarding/1.png',
      title: 'Start\nyour journey\nwith us',
      subtitle: 'Chat with owners or agents\nand book your visit in seconds',
    ),
    _OnboardingItem(
      imageAsset: 'assets/images/onboarding/2.png',
      title: 'Browse for\nthe trusted\nfeelings',
      subtitle: 'Explore verified properties with\nclear details and real photos.',
    ),
    _OnboardingItem(
      imageAsset: 'assets/images/onboarding/3.png',
      title: 'Find\nthe perfect\nplace',
      subtitle: 'Post your requirements\nand highly relevant matches.',
    ),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF003B95),
              Color(0xFF0057C2),
              Color(0xFFF6F2F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              PageView.builder(
                controller: controller,
                itemCount: items.length,
                onPageChanged: (i) => setState(() => index = i),
                itemBuilder: (context, i) => _OnboardingSlide(item: items[i]),
              ),
              Positioned(
                top: 8,
                right: 12,
                child: TextButton(
                  onPressed: _goLogin,
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Positioned(
                left: 24,
                bottom: 38,
                child: _Dots(count: items.length, index: index),
              ),
              Positioned(
                right: 24,
                bottom: 24,
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: FloatingActionButton(
                    heroTag: 'onboarding_next',
                    elevation: 0,
                    backgroundColor: const Color(0xFF0F6B4B),
                    onPressed: _goLogin,
                    child: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }
}

class _OnboardingItem {
  final String imageAsset;
  final String title;
  final String subtitle;
  const _OnboardingItem({
    required this.imageAsset,
    required this.title,
    required this.subtitle,
  });
}

class _OnboardingSlide extends StatelessWidget {
  final _OnboardingItem item;
  const _OnboardingSlide({required this.item});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TravelMate',
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white.withOpacity(0.85),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              clipBehavior: Clip.antiAlias,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFFFFF),
                      Color(0xFFF4F6FB),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Center(
                          child: Image.asset(
                            item.imageAsset,
                            fit: BoxFit.contain,
                            errorBuilder: (c, e, s) {
                              return Container(
                                width: 320,
                                height: 220,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: Icon(Icons.image,
                                      size: 52, color: Colors.grey),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        item.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int index;
  const _Dots({required this.count, required this.index});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.only(right: 8),
          width: active ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF0F6B4B) : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }
}

