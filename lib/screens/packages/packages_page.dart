import 'package:flutter/material.dart';
import '../../core/app_scope.dart';
import '../../shared/app_image.dart';

class PackagesPage extends StatelessWidget {
  const PackagesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final theme = Theme.of(context);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF4F6FB),
            Color(0xFFFFFFFF),
          ],
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        itemCount: app.packages.length,
        itemBuilder: (context, i) {
          final p = app.packages[i];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.96, end: 1),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: AppImage(
                          url: p.imageUrl,
                        ),
                      ),
                      Positioned(
                        left: 12,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                p.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${p.days} days',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '\$${p.price.toStringAsFixed(0)}',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'per person • taxes included',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FilledButton.icon(
                              onPressed: () {
                                app.addBookingFromPackage(p);
                                ScaffoldMessenger.of(context)
                                  ..clearSnackBars()
                                  ..showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: theme.colorScheme.primary,
                                      content: const Text('Package added to your bookings'),
                                    ),
                                  );
                              },
                              icon: const Icon(Icons.flight_takeoff),
                              label: const Text('Book now'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
