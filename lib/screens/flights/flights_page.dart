import 'package:flutter/material.dart';
import '../../core/app_scope.dart';

class FlightsPage extends StatefulWidget {
  const FlightsPage({super.key});
  @override
  State<FlightsPage> createState() => _FlightsPageState();
}

class _FlightsPageState extends State<FlightsPage> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = AppScope.of(context);
    final list = app.flights.where((f) {
      final q = query.trim().toLowerCase();
      final route = '${f.from} ${f.to}'.toLowerCase();
      return q.isEmpty || route.contains(q);
    }).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search flights (from/to)',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => query = v),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final f = list[i];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.96, end: 1),
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
                      child: const Icon(Icons.flight_takeoff, color: Color(0xFF003B95)),
                    ),
                    title: Text('${f.from} → ${f.to}'),
                    subtitle: Text('${f.departAt.toLocal()}'.split('.').first),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${f.price.toStringAsFixed(0)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 16, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(f.rating.toStringAsFixed(1)),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      app.addBookingFromFlight(f);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Flight added to bookings'),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
