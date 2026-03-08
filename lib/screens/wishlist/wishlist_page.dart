import 'package:flutter/material.dart';
import '../../core/app_scope.dart';
import '../hotels/hotel_detail_page.dart';
import '../../shared/app_image.dart';
import '../../shared/skeleton_box.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = AppScope.of(context);
    final loading = app.firebaseReady && app.currentUser != null && app.isLoadingUserData;
    final hotels = app.hotels.where((h) => app.isWishlisted(h.id)).toList();
    if (loading) {
      return ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: 5,
        itemBuilder: (context, i) => const _WishlistSkeleton(),
      );
    }
    if (hotels.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No saved stays yet',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Tap the heart on a place you like\nto see it here.',
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
      itemCount: hotels.length,
      itemBuilder: (context, i) {
        final h = hotels[i];
        return Card(
          child: ListTile(
            leading: SizedBox(
              width: 56,
              height: 56,
              child: AppImage(
                url: h.imageUrl,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            title: Text(
              h.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Row(
              children: [
                const Icon(Icons.place, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    h.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.star_rounded,
                    size: 16, color: Colors.amber),
                const SizedBox(width: 2),
                Text(h.rating.toStringAsFixed(1)),
              ],
            ),
            trailing: IconButton(
              onPressed: () => app.toggleWishlistHotel(h.id),
              icon: const Icon(Icons.delete_outline),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => HotelDetailPage(hotelId: h.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _WishlistSkeleton extends StatelessWidget {
  const _WishlistSkeleton();
  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            SkeletonBox(
              height: 56,
              width: 56,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(
                    height: 12,
                    width: double.infinity,
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                  SizedBox(height: 6),
                  SkeletonBox(
                    height: 10,
                    width: 120,
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

