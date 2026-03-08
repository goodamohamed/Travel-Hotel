import 'package:flutter/material.dart';

class TaxiIntro extends StatefulWidget {
  const TaxiIntro({super.key});
  @override
  State<TaxiIntro> createState() => _TaxiIntroState();
}

class _TaxiIntroState extends State<TaxiIntro> {
  final PageController _ctrl = PageController();
  int _page = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = const [
      _TaxiPage(
        title: 'Free cancellation for total flexibility',
        body:
            'All bookings can be cancelled for free up to 24 hours before your scheduled pick-up time',
        icon: Icons.schedule,
      ),
      _TaxiPage(
        title: 'Live flight tracking for airport pick-ups',
        body:
            'Book an airport taxi in advance and our drivers will monitor your arrival and wait 45 minutes after you land',
        icon: Icons.flight,
      ),
    ];
    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: _ctrl,
            onPageChanged: (i) => setState(() => _page = i),
            children: pages,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            pages.length,
            (i) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _page == i ? const Color(0xFF003B95) : Colors.grey.shade400,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: () {}, child: const Text('Skip')),
              FilledButton(
                onPressed: () {},
                child: Text(_page == pages.length - 1 ? 'Got it' : 'Next'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TaxiPage extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;
  const _TaxiPage({required this.title, required this.body, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.black54),
            const SizedBox(height: 24),
            Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(body, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

