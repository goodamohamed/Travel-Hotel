import 'package:flutter/material.dart';
import '../../core/app_scope.dart';
import '../../core/app_state.dart';
import 'hotel_detail_page.dart';
import '../../shared/app_image.dart';

class HotelsPage extends StatefulWidget {
  final bool showHeader;
  final String? query;
  final String? locationFilter;
  final double? maxPriceFilter;
  final double? minRatingFilter;
  const HotelsPage({
    super.key,
    this.showHeader = true,
    this.query,
    this.locationFilter,
    this.maxPriceFilter,
    this.minRatingFilter,
  });
  @override
  State<HotelsPage> createState() => _HotelsPageState();
}

class _HotelsPageState extends State<HotelsPage> {
  String query = '';
  double maxPrice = 1000;
  double minRating = 0;
  String location = '';

  @override
  void initState() {
    super.initState();
    if (!widget.showHeader) {
      query = widget.query ?? '';
      location = widget.locationFilter ?? '';
      if (widget.maxPriceFilter != null) maxPrice = widget.maxPriceFilter!;
      if (widget.minRatingFilter != null) minRating = widget.minRatingFilter!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = AppScope.of(context);
    final filtered = app.hotels.where((h) {
      final q = query.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          h.name.toLowerCase().contains(q) ||
          h.location.toLowerCase().contains(q);
      final matchesPrice = h.pricePerNight <= maxPrice;
      final matchesRating = h.rating >= minRating;
      final matchesLocation =
          location.isEmpty || h.location.toLowerCase() == location.toLowerCase();
      return matchesQuery && matchesPrice && matchesRating && matchesLocation;
    }).toList();

    return Column(
      children: [
        if (widget.showHeader)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search hotels, city...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => query = v),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: () => _openFilters(context, app),
                  child: const Icon(Icons.filter_list),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: filtered.length,
            itemBuilder: (context, i) {
              final h = filtered[i];
              final wish = app.isWishlisted(h.id);
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.96, end: 1),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => HotelDetailPage(hotelId: h.id),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Hero(
                                  tag: 'hotel_${h.id}',
                                  child: AppImage(
                                    url: h.imageUrl,
                                    borderRadius: BorderRadius.zero,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              if (h.rating >= 4.5)
                                Positioned(
                                  left: 10,
                                  top: 10,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.55),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      child: Text(
                                        'Bestseller',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: IconButton.filled(
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() => app.toggleWishlistHotel(h.id));
                                  },
                                  icon: Icon(
                                    wish ? Icons.favorite : Icons.favorite_border,
                                    color: wish ? Colors.red : Colors.black87,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 12,
                                bottom: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.92),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        color: Colors.amber,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        h.rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      h.name,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.place, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          h.location,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${h.pricePerNight.toStringAsFixed(0)}',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'per night',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openFilters(BuildContext context, AppState app) {
    final locations = [
      '',
      ...{for (final h in app.hotels) h.location}
    ];
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        double tempMaxPrice = maxPrice;
        double tempMinRating = minRating;
        String tempLocation = location;
        return StatefulBuilder(
          builder: (context, setS) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFFFFF),
                      Color(0xFFF4F6FB),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filters',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                maxPrice = 1000;
                                minRating = 0;
                                location = '';
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            avatar: const Icon(Icons.attach_money, size: 18),
                            label: Text('\$${tempMaxPrice.toStringAsFixed(0)} max'),
                          ),
                          Chip(
                            avatar: const Icon(Icons.star_rounded,
                                size: 18, color: Colors.amber),
                            label: Text('${tempMinRating.toStringAsFixed(1)}+ rating'),
                          ),
                          Chip(
                            avatar: const Icon(Icons.place, size: 18),
                            label: Text(
                              tempLocation.isEmpty ? 'Any location' : tempLocation,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Max price'),
                          Text('\$${tempMaxPrice.toStringAsFixed(0)}'),
                        ],
                      ),
                      Slider(
                        value: tempMaxPrice,
                        min: 50,
                        max: 1000,
                        divisions: 95,
                        label: tempMaxPrice.toStringAsFixed(0),
                        onChanged: (v) => setS(() => tempMaxPrice = v),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Min rating'),
                          Text(tempMinRating.toStringAsFixed(1)),
                        ],
                      ),
                      Slider(
                        value: tempMinRating,
                        min: 0,
                        max: 5,
                        divisions: 10,
                        label: tempMinRating.toStringAsFixed(1),
                        onChanged: (v) => setS(() => tempMinRating = v),
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: tempLocation,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                        ),
                        items: locations
                            .map((l) => DropdownMenuItem(
                                  value: l,
                                  child: Text(l.isEmpty ? 'Any' : l),
                                ))
                            .toList(),
                        onChanged: (v) => setS(() => tempLocation = v ?? ''),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            setState(() {
                              maxPrice = tempMaxPrice;
                              minRating = tempMinRating;
                              location = tempLocation;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Show results'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
