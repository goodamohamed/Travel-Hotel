import 'package:flutter/material.dart';
import '../../core/app_scope.dart';
import '../../core/models.dart';
import '../../shared/skeleton_box.dart';

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = AppScope.of(context);
    final bs = app.bookings.reversed.toList();
    final loading = app.firebaseReady && app.currentUser != null && app.isLoadingUserData;
    if (loading) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: 4,
        itemBuilder: (context, i) => const _BookingSkeleton(),
      );
    }
    if (bs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_note, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No bookings yet',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Your upcoming trips will appear here\nonce you book a stay or flight.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: bs.length,
      itemBuilder: (context, i) {
        final b = bs[i];
        IconData icon;
        switch (b.kind) {
          case BookingKind.hotel:
            icon = Icons.hotel;
            break;
          case BookingKind.flight:
            icon = Icons.flight_takeoff;
            break;
          case BookingKind.travelPackage:
            icon = Icons.card_travel;
            break;
        }
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
              child: Icon(icon, color: const Color(0xFF003B95)),
            ),
            title: Text(b.title),
            subtitle: Text('${b.date.toLocal()}'.split('.').first),
            trailing: Text(
              '\$${b.price.toStringAsFixed(0)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BookingSkeleton extends StatelessWidget {
  const _BookingSkeleton();
  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SkeletonBox(
              height: 40,
              width: 40,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(height: 12, width: double.infinity, borderRadius: BorderRadius.all(Radius.circular(6))),
                  SizedBox(height: 6),
                  SkeletonBox(height: 10, width: 140, borderRadius: BorderRadius.all(Radius.circular(6))),
                ],
              ),
            ),
            SizedBox(width: 12),
            SkeletonBox(height: 14, width: 40, borderRadius: BorderRadius.all(Radius.circular(6))),
          ],
        ),
      ),
    );
  }
}

