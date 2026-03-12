import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart' as ap;
import '../providers/theme_provider.dart';
import '../widgets/widgets.dart';
import 'hotel_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  int _selectedCategoryIndex = 0;

  final List<String> _categories = [
    'All',
    'Hotels',
    'Resorts',
    'Villas',
    'Boutique'
  ];
  final List<Map<String, dynamic>> _destinations = [
    {
      'name': 'Santorini',
      'country': 'Greece',
      'image':
          'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=400'
    },
    {
      'name': 'Maldives',
      'country': 'Maldives',
      'image':
          'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?w=400'
    },
    {
      'name': 'Kyoto',
      'country': 'Japan',
      'image':
          'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=400'
    },
    {
      'name': 'Paris',
      'country': 'France',
      'image':
          'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400'
    },
    {
      'name': 'Dubai',
      'country': 'UAE',
      'image':
          'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=400'
    },
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<Hotel> get _filteredHotels {
    if (_selectedCategoryIndex == 0) return MockData.hotels;
    final cats = [
      HotelCategory.hotel,
      HotelCategory.hotel,
      HotelCategory.resort,
      HotelCategory.villa,
      HotelCategory.boutique
    ];
    return MockData.hotels
        .where((h) => h.category == cats[_selectedCategoryIndex])
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ap.AuthProvider>();
    final wishlistIds = auth.wishlistHotelIds;
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    final bg = isDark ? const Color(0xFF0F1117) : AppTheme.background;
    final cardBg = isDark ? const Color(0xFF1C1F2E) : Colors.white;
    final textLight = isDark ? Colors.white38 : AppTheme.textLight;
    final shadowColor = isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.12);
    final divColor = isDark ? Colors.white12 : AppTheme.divider;
    final textSec = isDark ? Colors.white60 : AppTheme.textSecondary;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ─── Hero Header ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  height: 280,
                  decoration:
                      const BoxDecoration(gradient: AppTheme.primaryGradient),
                ),
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.07,
                    child: Image.network(
                      'https://images.unsplash.com/photo-1488085061387-422e29b40080?w=800',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Good Morning! 👋',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white70, fontSize: 13)),
                                Text(
                                  auth.appUser?.name ??
                                      auth.firebaseUser?.displayName ??
                                      'Traveler',
                                  style: GoogleFonts.playfairDisplay(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            Stack(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.white30),
                                  ),
                                  child: const Icon(
                                      Icons.notifications_outlined,
                                      color: Colors.white,
                                      size: 24),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    width: 9,
                                    height: 9,
                                    decoration: const BoxDecoration(
                                        color: AppTheme.accent,
                                        shape: BoxShape.circle),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Where do you\nwant to explore?',
                          style: GoogleFonts.playfairDisplay(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              height: 1.2),
                        ),
                        const SizedBox(height: 22),
                        // Search
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: shadowColor,
                                  blurRadius: 16,
                                  offset: const Offset(0, 4))
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search,
                                  color: AppTheme.primary, size: 22),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text('Search destinations, hotels...',
                                    style: GoogleFonts.poppins(
                                        color: textLight,
                                        fontSize: 14)),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.accent.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.tune,
                                    color: AppTheme.accent, size: 18),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── Stats Row ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(22, 0, 22, 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.07),
                      blurRadius: 16,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _StatItem(
                      label: 'Destinations', value: '200+', icon: Icons.public),
                  _Divider(),
                  _StatItem(
                      label: 'Hotels', value: '1,500+', icon: Icons.hotel),
                  _Divider(),
                  _StatItem(
                      label: 'Happy Travelers',
                      value: '50K+',
                      icon: Icons.people),
                ],
              ),
            ),
          ),

          // ─── Popular Destinations ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: SectionHeader(
                  title: 'Popular Destinations',
                  actionLabel: 'View all',
                  onAction: () {}),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 140,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
                scrollDirection: Axis.horizontal,
                itemCount: _destinations.length,
                itemBuilder: (ctx, i) =>
                    _DestinationCard(dest: _destinations[i]),
              ),
            ),
          ),

          // ─── Category Filter ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 16),
              child: SectionHeader(
                  title: 'Featured Hotels',
                  actionLabel: 'View all',
                  onAction: () {}),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (ctx, i) => GestureDetector(
                  onTap: () => setState(() => _selectedCategoryIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedCategoryIndex == i
                          ? AppTheme.primary
                          : cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _selectedCategoryIndex == i
                              ? AppTheme.primary
                              : divColor),
                      boxShadow: _selectedCategoryIndex == i
                          ? [
                              BoxShadow(
                                  color: AppTheme.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3))
                            ]
                          : [],
                    ),
                    child: Text(
                      _categories[i],
                      style: TextStyle(
                        color: _selectedCategoryIndex == i
                            ? Colors.white
                            : textSec,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ─── Hotels List ────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final hotel = _filteredHotels[i];
                  hotel.isWishlisted = wishlistIds.contains(hotel.id);
                  return HotelCard(
                    hotel: hotel,
                    onTap: () => Navigator.push(
                        ctx,
                        MaterialPageRoute(
                            builder: (_) => HotelDetailScreen(hotel: hotel))),
                    onWishlistToggle: () async {
                      if (!auth.isAuthenticated) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please sign in to use favorites')),
                        );
                        return;
                      }
                      setState(() => hotel.isWishlisted = !hotel.isWishlisted);
                      await context
                          .read<ap.AuthProvider>()
                          .toggleWishlistHotel(hotel.id);
                    },
                  );
                },
                childCount: _filteredHotels.length,
              ),
            ),
          ),

          // ─── Travel Packages ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
              child: SectionHeader(
                  title: 'Travel Packages',
                  actionLabel: 'View all',
                  onAction: () {}),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
                scrollDirection: Axis.horizontal,
                itemCount: MockData.packages.length,
                itemBuilder: (ctx, i) =>
                    _PackageCard(package: MockData.packages[i]),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatItem(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final textPri = isDark ? Colors.white : AppTheme.textPrimary;
    final textSec = isDark ? Colors.white60 : AppTheme.textSecondary;

    return Column(
      children: [
        Icon(icon, color: AppTheme.primary, size: 24),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textPri)),
        Text(label,
            style:
                TextStyle(fontSize: 11, color: textSec)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final divColor = isDark ? Colors.white12 : AppTheme.divider;
    return Container(width: 1, height: 50, color: divColor);
  }
}

class _DestinationCard extends StatelessWidget {
  final Map<String, dynamic> dest;
  const _DestinationCard({required this.dest});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final divColor = isDark ? Colors.white12 : AppTheme.divider;

    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 14),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: dest['image'],
              width: 110,
              height: 130,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: divColor),
              errorWidget: (_, __, ___) => Container(
                  color: isDark ? const Color(0xFF1C1F2E) : const Color(0xFFE8F0FE),
                  child: const Icon(Icons.landscape, color: AppTheme.primary)),
            ),
          ),
          Positioned.fill(
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                      decoration: const BoxDecoration(
                          gradient: AppTheme.heroGradient)))),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(dest['name'],
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                    textAlign: TextAlign.center),
                Text(dest['country'],
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageCard extends StatefulWidget {
  final TravelPackage package;
  const _PackageCard({required this.package});

  @override
  State<_PackageCard> createState() => _PackageCardState();
}

class _PackageCardState extends State<_PackageCard> {
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final divColor = isDark ? Colors.white12 : AppTheme.divider;

    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.1),
              blurRadius: 14,
              offset: const Offset(0, 4))
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: widget.package.image,
              width: 240,
              height: 210,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: divColor),
              errorWidget: (_, __, ___) =>
                  Container(color: isDark ? const Color(0xFF1C1F2E) : const Color(0xFFE8F0FE)),
            ),
          ),
          Positioned.fill(
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                      decoration: const BoxDecoration(
                          gradient: AppTheme.heroGradient)))),
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () => setState(() =>
                  widget.package.isWishlisted = !widget.package.isWishlisted),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle),
                child: Icon(
                    widget.package.isWishlisted
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: widget.package.isWishlisted
                        ? AppTheme.wishlistColor
                        : AppTheme.textSecondary,
                    size: 16),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 14,
            right: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.package.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.white70, size: 12),
                    const SizedBox(width: 2),
                    Flexible(
                        child: Text(widget.package.destination,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11),
                            overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${widget.package.nights} nights',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius: BorderRadius.circular(10)),
                      child: Text('From \$${widget.package.price.toInt()}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
