import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart' as ap;
import '../widgets/widgets.dart';
import 'hotel_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});
  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Hotel> _wishlisted(List<String> ids) =>
      MockData.hotels.where((h) => ids.contains(h.id)).toList();
  List<TravelPackage> get _wishlistedPackages =>
      MockData.packages.where((p) => p.isWishlisted).toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ap.AuthProvider>();
    final wishlistIds = auth.wishlistHotelIds;
    final wishlistedHotels = _wishlisted(wishlistIds);
    final packages = _wishlistedPackages;
    final totalSaved = wishlistedHotels.length + packages.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverToBoxAdapter(
            child: _buildHeader(
                context, auth, totalSaved, wishlistedHotels, packages),
          ),
        ],
        body: totalSaved == 0
            ? _buildEmptyState()
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildHotelsTab(auth, wishlistedHotels),
                  _buildPackagesTab(packages),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ap.AuthProvider auth,
      int totalSaved, List<Hotel> hotels, List<TravelPackage> packages) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Wishlist',
                          style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(
                        totalSaved == 0
                            ? 'Nothing saved yet'
                            : '$totalSaved saved ${totalSaved == 1 ? 'place' : 'places'}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(children: [
                      const Icon(Icons.favorite,
                          color: AppTheme.wishlistColor, size: 16),
                      const SizedBox(width: 6),
                      Text('$totalSaved',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14)),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (totalSaved > 0) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _StatPill(
                        icon: Icons.hotel_outlined,
                        label: '${hotels.length} Hotels'),
                    const SizedBox(width: 10),
                    _StatPill(
                        icon: Icons.luggage_outlined,
                        label: '${packages.length} Packages'),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _confirmClearAll(context, auth, packages),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppTheme.wishlistColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.wishlistColor.withOpacity(0.4)),
                        ),
                        child: const Row(children: [
                          Icon(Icons.delete_outline,
                              color: Colors.white70, size: 14),
                          SizedBox(width: 5),
                          Text('Clear all',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: AppTheme.primary,
                    unselectedLabelColor: Colors.white70,
                    labelStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700, fontSize: 13),
                    unselectedLabelStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500, fontSize: 13),
                    tabs: [
                      Tab(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            const Icon(Icons.hotel_outlined, size: 15),
                            const SizedBox(width: 5),
                            Text('Hotels (${hotels.length})'),
                          ])),
                      Tab(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            const Icon(Icons.luggage_outlined, size: 15),
                            const SizedBox(width: 5),
                            Text('Packages (${packages.length})'),
                          ])),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelsTab(ap.AuthProvider auth, List<Hotel> hotels) {
    if (hotels.isEmpty)
      return _buildTabEmpty(
          icon: Icons.hotel_outlined,
          message: 'No saved hotels yet',
          sub: 'Tap ♡ on any hotel to save it here');
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
      itemCount: hotels.length,
      itemBuilder: (ctx, i) {
        final hotel = hotels[i];
        hotel.isWishlisted = true;
        return _WishlistHotelCard(
          hotel: hotel,
          onTap: () => Navigator.push(
              ctx,
              MaterialPageRoute(
                  builder: (_) => HotelDetailScreen(hotel: hotel))),
          onRemove: () async => await auth.toggleWishlistHotel(hotel.id),
        );
      },
    );
  }

  Widget _buildPackagesTab(List<TravelPackage> packages) {
    if (packages.isEmpty)
      return _buildTabEmpty(
          icon: Icons.luggage_outlined,
          message: 'No saved packages yet',
          sub: 'Explore travel packages and save your favourites');
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
      itemCount: packages.length,
      itemBuilder: (_, i) => _WishlistPackageCard(
          package: packages[i],
          onRemove: () => setState(() => packages[i].isWishlisted = false)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.7, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppTheme.wishlistColor.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppTheme.wishlistColor.withOpacity(0.2), width: 2),
              ),
              child: const Icon(Icons.favorite_border,
                  color: AppTheme.wishlistColor, size: 44),
            ),
          ),
          const SizedBox(height: 22),
          Text('Nothing saved yet',
              style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 10),
          const Text('Save hotels and packages you love\nby tapping the ♡ icon',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 14, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildTabEmpty(
      {required IconData icon, required String message, required String sub}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.07),
                shape: BoxShape.circle),
            child: Icon(icon, color: AppTheme.primary, size: 32),
          ),
          const SizedBox(height: 14),
          Text(message,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 6),
          Text(sub,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context, ap.AuthProvider auth,
      List<TravelPackage> packages) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                    color: AppTheme.wishlistColor.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline,
                    color: AppTheme.wishlistColor, size: 28),
              ),
              const SizedBox(height: 14),
              Text('Clear Wishlist?',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 8),
              const Text('All saved hotels and packages will be removed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.5)),
              const SizedBox(height: 22),
              Row(children: [
                Expanded(
                    child: TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppTheme.divider)),
                  ),
                  child: const Text('Cancel',
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600)),
                )),
                const SizedBox(width: 10),
                Expanded(
                    child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.wishlistColor,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Clear all',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                )),
              ]),
            ],
          ),
        ),
      ),
    );
    if (ok == true)
      setState(() {
        for (var p in packages) p.isWishlisted = false;
      });
  }
}

// ده كارت الفندق في الوِش ليست
class _WishlistHotelCard extends StatefulWidget {
  final Hotel hotel;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  const _WishlistHotelCard(
      {required this.hotel, required this.onTap, required this.onRemove});
  @override
  // بيربط الـ Widget بالـ State بتاع الكارت
  State<_WishlistHotelCard> createState() => _WishlistHotelCardState();
}

class _WishlistHotelCardState extends State<_WishlistHotelCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  // بنجهز أنيميشن الضغط
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 130));
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  // بنقفل الكنترولر بتاع الأنيميشن
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  // بيرسم كارت الفندق في الوِش ليست
  Widget build(BuildContext context) {
    final hotel = widget.hotel;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 14,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    child: CachedNetworkImage(
                      imageUrl: hotel.images.isNotEmpty ? hotel.images[0] : '',
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                          height: 180,
                          color: AppTheme.divider,
                          child: const Center(
                              child:
                                  CircularProgressIndicator(strokeWidth: 2))),
                      errorWidget: (_, __, ___) => Container(
                          height: 180,
                          color: const Color(0xFFE8F0FE),
                          child: const Icon(Icons.landscape,
                              color: AppTheme.primary, size: 40)),
                    ),
                  ),
                  Positioned.fill(
                      child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20)),
                          child: Container(
                              decoration: const BoxDecoration(
                                  gradient: AppTheme.heroGradient)))),
                  if (hotel.tag.isNotEmpty)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                            gradient: AppTheme.sunsetGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  color: AppTheme.accent.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2))
                            ]),
                        child: Text(hotel.tag,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: widget.onRemove,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.favorite,
                            color: AppTheme.wishlistColor, size: 20),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          const Icon(Icons.location_on,
                              color: Colors.white70, size: 13),
                          const SizedBox(width: 3),
                          Text('${hotel.location}, ${hotel.country}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ]),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(20)),
                          child: Text('\$${hotel.pricePerNight.toInt()}/night',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(hotel.name,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: AppTheme.textPrimary),
                                overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                              color: AppTheme.starColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(children: [
                            const Icon(Icons.star,
                                color: AppTheme.starColor, size: 13),
                            const SizedBox(width: 3),
                            Text(hotel.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    color: AppTheme.starColor)),
                          ]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${hotel.reviewCount} reviews · ${hotel.stars}★ Hotel',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12)),
                    if (hotel.amenities.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: hotel.amenities
                              .take(4)
                              .map<Widget>((a) => AmenityChip(label: a))
                              .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ده كارت الباكدج في الوِش ليست
class _WishlistPackageCard extends StatelessWidget {
  final TravelPackage package;
  final VoidCallback onRemove;
  const _WishlistPackageCard({required this.package, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20)),
                child: CachedNetworkImage(
                  imageUrl: package.image,
                  width: 120,
                  height: 130,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                      width: 120, height: 130, color: AppTheme.divider),
                  errorWidget: (_, __, ___) => Container(
                      width: 120,
                      height: 130,
                      color: const Color(0xFFE8F0FE),
                      child:
                          const Icon(Icons.landscape, color: AppTheme.primary)),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text('${package.nights}N',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Text(package.title,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppTheme.textPrimary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                              color: AppTheme.wishlistColor.withOpacity(0.1),
                              shape: BoxShape.circle),
                          child: const Icon(Icons.favorite,
                              color: AppTheme.wishlistColor, size: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(children: [
                    const Icon(Icons.location_on,
                        color: AppTheme.accent, size: 12),
                    const SizedBox(width: 3),
                    Flexible(
                        child: Text(package.destination,
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 11),
                            overflow: TextOverflow.ellipsis)),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.star, color: AppTheme.starColor, size: 12),
                    const SizedBox(width: 3),
                    Text(package.rating.toStringAsFixed(1),
                        style: const TextStyle(
                            color: AppTheme.starColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
                  ]),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${package.includes.length} included',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 11)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text('\$${package.price.toInt()}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatPill({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white70, size: 13),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
