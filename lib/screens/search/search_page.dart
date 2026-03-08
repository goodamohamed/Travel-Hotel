import 'package:flutter/material.dart';
import '../../core/app_scope.dart';
import 'widgets/car_rental_form.dart';
import 'widgets/taxi_intro.dart';
import '../../shared/pill_tab_indicator.dart';
import 'widgets/stays_tab.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final app = AppScope.of(context);
      if (!app.geniusSeen) {
        _showGeniusDialog();
      }
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF003B95),
                Color(0xFF0057C2),
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Where to next?',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Discover stays, flights, cars and more',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 14),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: _tabs,
                      isScrollable: true,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor: const Color(0xFF003B95),
                      unselectedLabelColor: Colors.black54,
                      indicator: const PillTabIndicator(
                        color: Color(0xFFE6F0FF),
                        radius: 14,
                        padding: EdgeInsets.all(6),
                      ),
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                      labelPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(icon: Icon(Icons.hotel), text: 'Stays'),
                        Tab(icon: Icon(Icons.directions_car), text: 'Car rental'),
                        Tab(icon: Icon(Icons.local_taxi), text: 'Taxi'),
                        Tab(icon: Icon(Icons.attractions), text: 'Attractions'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: const [
              StaysTab(),
              CarRentalForm(),
              TaxiIntro(),
              _AttractionsPlaceholder(),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showGeniusDialog() async {
    final app = AppScope.of(context);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      app.markGeniusSeen();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
                Row(
                  children: [
                    Text('Gen', style: TextStyle(color: const Color(0xFF003B95), fontSize: 32, fontWeight: FontWeight.bold)),
                    Text('ius', style: TextStyle(color: Colors.black87, fontSize: 32, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome! You just unlocked Level 1',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enjoy travel rewards worldwide. Just look for the blue Genius label to save!',
                ),
                const SizedBox(height: 16),
                const ListTile(
                  dense: true,
                  leading: Icon(Icons.percent),
                  title: Text('10% off select stays'),
                ),
                const ListTile(
                  dense: true,
                  leading: Icon(Icons.directions_car),
                  title: Text('10% discounts on select rental cars'),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      app.markGeniusSeen();
                    },
                    child: const Text('Ok, got it!'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AttractionsPlaceholder extends StatelessWidget {
  const _AttractionsPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.attractions, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          const Text('Attractions coming soon'),
        ],
      ),
    );
  }
}
