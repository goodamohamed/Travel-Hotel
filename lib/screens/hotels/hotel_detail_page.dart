import 'package:flutter/material.dart';
import '../../core/app_scope.dart';
import '../../core/models.dart';
import '../../shared/app_image.dart';

class HotelDetailPage extends StatelessWidget {
  final String hotelId;
  const HotelDetailPage({super.key, required this.hotelId});
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final h = app.hotels.firstWhere((e) => e.id == hotelId);
    final wish = app.isWishlisted(h.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(h.name),
        actions: [
          IconButton(
            onPressed: () => app.toggleWishlistHotel(h.id),
            icon: Icon(
              wish ? Icons.favorite : Icons.favorite_border,
              color: wish ? Colors.red : null,
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Hero(
              tag: 'hotel_${h.id}',
              child: AppImage(url: h.imageUrl),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      h.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(h.rating.toStringAsFixed(1)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.place, size: 18),
                    const SizedBox(width: 6),
                    Text(h.location),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Map',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 180,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Map placeholder'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${h.pricePerNight.toStringAsFixed(0)}/night',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    FilledButton(
                      onPressed: () {
                        app.addBookingFromHotel(h);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to bookings')),
                        );
                      },
                      child: const Text('Book Now'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reviews',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton(
                      onPressed: () => _openAddReview(context, h),
                      child: const Text('Add review'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final r in h.reviews)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(child: Icon(Icons.person)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(r.user, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.star, size: 16, color: Colors.amber),
                                  const SizedBox(width: 2),
                                  Text(r.rating.toStringAsFixed(1)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(r.comment),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openAddReview(BuildContext context, Hotel h) {
    final app = AppScope.of(context);
    final userCtrl = TextEditingController();
    final commentCtrl = TextEditingController();
    double rating = 4;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16,
          ),
          child: StatefulBuilder(
            builder: (context, setS) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: userCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Comment',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Rating'),
                      Text(rating.toStringAsFixed(1)),
                    ],
                  ),
                  Slider(
                    value: rating,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    onChanged: (v) => setS(() => rating = v),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (userCtrl.text.trim().isEmpty ||
                            commentCtrl.text.trim().isEmpty) {
                          Navigator.pop(context);
                          return;
                        }
                        app.addReview(
                          h.id,
                          Review(
                            user: userCtrl.text.trim(),
                            comment: commentCtrl.text.trim(),
                            rating: rating,
                            date: DateTime.now(),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
