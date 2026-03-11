import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:travel_hotel_app/screens/bookings_screen.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../providers/auth_provider.dart' as ap;
import '../widgets/widgets.dart';

class HotelDetailScreen extends StatefulWidget {
  final Hotel hotel;
  const HotelDetailScreen({super.key, required this.hotel});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  final PageController _pageController = PageController();
  late Hotel _hotel;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _hotel = widget.hotel;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ap.AuthProvider>();
    _hotel.isWishlisted = auth.wishlistHotelIds.contains(_hotel.id);
    final reviews = MockData.getHotelReviews(_hotel.id);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ده جزء الصور اللي فوق
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppTheme.primaryDark,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back,
                    color: AppTheme.textPrimary, size: 20),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () async {
                  if (!auth.isAuthenticated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please sign in to use favorites')),
                    );
                    return;
                  }
                  setState(() => _hotel.isWishlisted = !_hotel.isWishlisted);
                  await context
                      .read<ap.AuthProvider>()
                      .toggleWishlistHotel(_hotel.id);
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle),
                  child: Icon(
                    _hotel.isWishlisted
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: _hotel.isWishlisted
                        ? AppTheme.wishlistColor
                        : AppTheme.textPrimary,
                    size: 20,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle),
                child: const Icon(Icons.share_outlined,
                    color: AppTheme.textPrimary, size: 20),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _hotel.images.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (ctx, i) => CachedNetworkImage(
                      imageUrl: _hotel.images[i],
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                          color: AppTheme.divider,
                          child:
                              const Center(child: CircularProgressIndicator())),
                      errorWidget: (_, __, ___) => Container(
                          color: const Color(0xFFE8F0FE),
                          child: const Icon(Icons.hotel,
                              size: 80, color: AppTheme.primary)),
                    ),
                  ),
                  // ده تدرّج تحت عشان الكلام يبان
                  Positioned.fill(
                      child: Container(
                          decoration: const BoxDecoration(
                              gradient: AppTheme.heroGradient))),
                  // ده مؤشر الصور
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: _hotel.images.length,
                        effect: const ExpandingDotsEffect(
                          dotHeight: 6,
                          dotWidth: 6,
                          expansionFactor: 3,
                          activeDotColor: Colors.white,
                          dotColor: Colors.white38,
                        ),
                      ),
                    ),
                  ),
                  // ده عدد الصور
                  Positioned(
                    bottom: 12,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(12)),
                      child: Text('${_currentPage + 1}/${_hotel.images.length}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Content ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hotel Overview ─────────────────────────────
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(_hotel.name,
                                  style: GoogleFonts.playfairDisplay(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary)),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('\$${_hotel.pricePerNight.toInt()}',
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.primary)),
                                const Text('per night',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: AppTheme.accent, size: 16),
                            const SizedBox(width: 4),
                            Text('${_hotel.location}, ${_hotel.country}',
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13)),
                            const SizedBox(width: 12),
                            ...List.generate(
                                _hotel.stars,
                                (_) => const Icon(Icons.star,
                                    color: AppTheme.starColor, size: 14)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text('${_hotel.rating}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15)),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RatingBarIndicator(
                                  rating: _hotel.rating,
                                  itemBuilder: (ctx, i) => const Icon(
                                      Icons.star,
                                      color: AppTheme.starColor),
                                  itemCount: 5,
                                  itemSize: 16,
                                ),
                                Text('${_hotel.reviewCount} reviews',
                                    style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text('About',
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary)),
                        const SizedBox(height: 8),
                        Text(_hotel.description,
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                                height: 1.6)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Amenities ──────────────────────────────────
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Amenities',
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary)),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _hotel.amenities
                              .map((a) => AmenityChip(label: a))
                              .toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Map Placeholder ────────────────────────────
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Location',
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary)),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 160,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F0FE),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Map grid lines
                                CustomPaint(
                                    painter: _MapGridPainter(),
                                    size: Size.infinite),
                                // Pin
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                          color: AppTheme.primary,
                                          shape: BoxShape.circle),
                                      child: const Icon(Icons.hotel,
                                          color: Colors.white, size: 20),
                                    ),
                                    Container(
                                        width: 2,
                                        height: 10,
                                        color: AppTheme.primary),
                                    Container(
                                        width: 10,
                                        height: 4,
                                        decoration: BoxDecoration(
                                            color: AppTheme.primary
                                                .withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(4))),
                                  ],
                                ),
                                Positioned(
                                  bottom: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                        color: AppTheme.primary,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: const Text('View on Map',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: AppTheme.accent, size: 14),
                            const SizedBox(width: 4),
                            Flexible(
                                child: Text(
                                    '${_hotel.location}, ${_hotel.country} • Lat: ${_hotel.lat}, Lng: ${_hotel.lng}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary))),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Reviews ────────────────────────────────────
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Guest Reviews',
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary)),
                            Text('See all',
                                style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...reviews.map((r) => _ReviewCard(review: r)).toList(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      // ── Booking CTA Bar ──────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -4))
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Price per night',
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$${_hotel.pricePerNight.toInt()}',
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary)),
                    const Text(' /night',
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.textSecondary)),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => BookingsScreen())),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  backgroundColor: AppTheme.primary,
                ),
                child: const Text('Book Now',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primary,
                child: Text(review.userAvatar,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    Text(
                        '${review.date.day}/${review.date.month}/${review.date.year}',
                        style: const TextStyle(
                            color: AppTheme.textLight, fontSize: 11)),
                  ],
                ),
              ),
              RatingBarIndicator(
                rating: review.rating,
                itemBuilder: (ctx, i) =>
                    const Icon(Icons.star, color: AppTheme.starColor),
                itemCount: 5,
                itemSize: 14,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(review.comment,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary.withOpacity(0.1)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

