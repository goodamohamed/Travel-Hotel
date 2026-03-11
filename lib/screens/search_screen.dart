import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart' as ap;
import '../widgets/widgets.dart';
import 'hotel_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  // Hotel filters
  double _maxPrice = 1000;
  double _minRating = 0;
  int _selectedStars = 0;
  String _sortBy = 'rating';
  bool _showFilters = false;

  // Flight fields
  String _fromLocation = 'Cairo (CAI)';
  String _toLocation = 'Anywhere';
  DateTime? _flightDeparture;
  DateTime? _flightReturn;
  int _passengers = 1;
  String _flightClass = 'Economy';

  // Popular searches
  final List<Map<String, dynamic>> _trending = [
    {'label': 'Dubai', 'emoji': '🏙️'},
    {'label': 'Santorini', 'emoji': '🌊'},
    {'label': 'Maldives', 'emoji': '🌴'},
    {'label': 'Tokyo', 'emoji': '⛩️'},
    {'label': 'Paris', 'emoji': '🗼'},
    {'label': 'Cairo', 'emoji': '🏺'},
  ];

  @override
  // بنجهز الكنترولر بتاع التابات
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  // بنقفل الكنترولرز عشان مفيش تسريب
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<Hotel> get _filteredHotels {
    return MockData.hotels.where((h) {
      final q = _searchController.text.toLowerCase();
      final matchSearch = q.isEmpty ||
          h.name.toLowerCase().contains(q) ||
          h.location.toLowerCase().contains(q) ||
          h.country.toLowerCase().contains(q);
      return matchSearch &&
          h.pricePerNight <= _maxPrice &&
          h.rating >= _minRating &&
          (_selectedStars == 0 || h.stars == _selectedStars);
    }).toList()
      ..sort((a, b) {
        switch (_sortBy) {
          case 'price_asc':
            return a.pricePerNight.compareTo(b.pricePerNight);
          case 'price_desc':
            return b.pricePerNight.compareTo(a.pricePerNight);
          default:
            return b.rating.compareTo(a.rating);
        }
      });
  }

  bool get _hasQuery => _searchController.text.isNotEmpty;

  @override
  // بيرسم شاشة البحث بتاب الفنادق والطيران
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          // ده الهيدر اللي فوق
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Discover',
                                  style: GoogleFonts.playfairDisplay(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                              Text('Find Your Next Trip',
                                  style: GoogleFonts.playfairDisplay(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Icon(Icons.tune_rounded,
                                color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ده التابات
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
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
                          labelColor: AppTheme.primary,
                          unselectedLabelColor: Colors.white70,
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700, fontSize: 14),
                          unselectedLabelStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500, fontSize: 14),
                          tabs: const [
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.hotel_outlined, size: 16),
                                  SizedBox(width: 6),
                                  Text('Hotels'),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.flight_rounded, size: 16),
                                  SizedBox(width: 6),
                                  Text('Flights'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildHotelsTab(),
            _buildFlightsTab(),
          ],
        ),
      ),
    );
  }

  // ده جزء الفنادق
  Widget _buildHotelsTab() {
    final auth = context.watch<ap.AuthProvider>();

    return Column(
      children: [
        // ده شريط البحث
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: _SearchInputBox(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  hint: 'Hotels, cities, destinations...',
                  onChanged: (_) => setState(() {}),
                  onClear: () => setState(() => _searchController.clear()),
                ),
              ),
              const SizedBox(width: 10),
              _FilterToggleBtn(
                active: _showFilters,
                onTap: () => setState(() => _showFilters = !_showFilters),
              ),
            ],
          ),
        ),

        // ده جزء الفلاتر
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 280),
          crossFadeState:
              _showFilters ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: _buildFiltersPanel(),
          secondChild: const SizedBox(width: double.infinity),
        ),

        // ده جزء العدد والترتيب
        if (_hasQuery || _showFilters)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${_filteredHotels.length} results',
                      style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
                const Spacer(),
                const Text('Sort ',
                    style: TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary)),
                DropdownButton<String>(
                  value: _sortBy,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: AppTheme.primary, size: 18),
                  style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13),
                  items: const [
                    DropdownMenuItem(value: 'rating', child: Text('Top Rated')),
                    DropdownMenuItem(
                        value: 'price_asc', child: Text('Price ↑')),
                    DropdownMenuItem(
                        value: 'price_desc', child: Text('Price ↓')),
                  ],
                  onChanged: (v) => setState(() => _sortBy = v ?? 'rating'),
                ),
              ],
            ),
          ),

        // هنا هنجيب يا الترند يا النتائج
        Expanded(
          child: _hasQuery
              ? _buildHotelResults(auth)
              : _buildDiscoverView(auth),
        ),
      ],
    );
  }

  Widget _buildDiscoverView(ap.AuthProvider auth) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
      children: [
        // Trending searches
        Text('Trending Destinations',
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _trending
              .map((t) => _TrendingChip(
                    emoji: t['emoji'],
                    label: t['label'],
                    onTap: () => setState(() {
                      _searchController.text = t['label'];
                    }),
                  ))
              .toList(),
        ),

        const SizedBox(height: 28),

        // All hotels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('All Hotels',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary)),
            Text('${MockData.hotels.length} properties',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 14),
        ...MockData.hotels.map((hotel) {
          hotel.isWishlisted =
              auth.wishlistHotelIds.contains(hotel.id);
          return HotelCard(
            hotel: hotel,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => HotelDetailScreen(hotel: hotel))),
            onWishlistToggle: () => _toggleWishlist(auth, hotel),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildHotelResults(ap.AuthProvider auth) {
    final hotels = _filteredHotels;
    if (hotels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.07),
                  shape: BoxShape.circle),
              child: const Icon(Icons.search_off_rounded,
                  color: AppTheme.primary, size: 36),
            ),
            const SizedBox(height: 16),
            Text('No results for "${_searchController.text}"',
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 6),
            const Text('Try a different city or hotel name',
                style:
                    TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: hotels.length,
      itemBuilder: (ctx, i) {
        final hotel = hotels[i];
        hotel.isWishlisted = auth.wishlistHotelIds.contains(hotel.id);
        return HotelCard(
          hotel: hotel,
          onTap: () => Navigator.push(ctx,
              MaterialPageRoute(
                  builder: (_) => HotelDetailScreen(hotel: hotel))),
          onWishlistToggle: () => _toggleWishlist(auth, hotel),
        );
      },
    );
  }

  void _toggleWishlist(ap.AuthProvider auth, Hotel hotel) async {
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to save favourites')),
      );
      return;
    }
    setState(() => hotel.isWishlisted = !hotel.isWishlisted);
    await auth.toggleWishlistHotel(hotel.id);
  }

  Widget _buildFiltersPanel() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Max price / night',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppTheme.textPrimary)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('\$${_maxPrice.toInt()}',
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13)),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: _maxPrice,
              min: 50,
              max: 1000,
              divisions: 19,
              activeColor: AppTheme.primary,
              inactiveColor: AppTheme.divider,
              onChanged: (v) => setState(() => _maxPrice = v),
            ),
          ),

          // Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Min rating',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppTheme.textPrimary)),
              Row(children: [
                const Icon(Icons.star, color: AppTheme.starColor, size: 14),
                const SizedBox(width: 3),
                Text('${_minRating.toStringAsFixed(1)}+',
                    style: const TextStyle(
                        color: AppTheme.starColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 13)),
              ]),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 8),
              activeTrackColor: AppTheme.starColor,
              thumbColor: AppTheme.starColor,
              overlayColor: AppTheme.starColor.withOpacity(0.15),
            ),
            child: Slider(
              value: _minRating,
              min: 0,
              max: 5,
              divisions: 10,
              activeColor: AppTheme.starColor,
              inactiveColor: AppTheme.divider,
              onChanged: (v) => setState(() => _minRating = v),
            ),
          ),

          // Stars
          const Text('Stars',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 10),
          Row(
            children: [0, 3, 4, 5].map((s) {
              final active = _selectedStars == s;
              return GestureDetector(
                onTap: () => setState(() => _selectedStars = s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: active ? AppTheme.primaryGradient : null,
                    color: active ? null : AppTheme.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: active
                            ? AppTheme.primary
                            : AppTheme.divider),
                    boxShadow: active
                        ? [
                            BoxShadow(
                                color: AppTheme.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3))
                          ]
                        : [],
                  ),
                  child: Text(
                    s == 0 ? 'Any' : '$s ★',
                    style: TextStyle(
                        color: active
                            ? Colors.white
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // FLIGHTS TAB
  // ──────────────────────────────────────────────────────────────
  Widget _buildFlightsTab() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ── Search Form Card ───────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              // From / To with swap
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  Column(
                    children: [
                      _LocationField(
                        icon: Icons.flight_takeoff_rounded,
                        label: 'From',
                        value: _fromLocation,
                        iconColor: AppTheme.primary,
                        onTap: () =>
                            _openLocationPicker(isFrom: true),
                      ),
                      Container(
                          height: 1,
                          color: AppTheme.divider,
                          margin: const EdgeInsets.only(left: 46)),
                      _LocationField(
                        icon: Icons.flight_land_rounded,
                        label: 'To',
                        value: _toLocation,
                        iconColor: AppTheme.accent,
                        onTap: () =>
                            _openLocationPicker(isFrom: false),
                      ),
                    ],
                  ),
                  // Swap button
                  Positioned(
                    right: 0,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        final tmp = _fromLocation;
                        _fromLocation = _toLocation;
                        _toLocation = tmp;
                      }),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppTheme.primary.withOpacity(0.3)),
                        ),
                        child: const Icon(
                            Icons.swap_vert_rounded,
                            color: AppTheme.primary,
                            size: 20),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Dates row
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      icon: Icons.calendar_today_rounded,
                      label: 'Departure',
                      date: _flightDeparture,
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _flightDeparture ??
                              now.add(const Duration(days: 7)),
                          firstDate: now,
                          lastDate:
                              now.add(const Duration(days: 365)),
                          builder: (ctx, child) => Theme(
                            data: Theme.of(ctx).copyWith(
                                colorScheme: const ColorScheme.light(
                                    primary: AppTheme.primary)),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          setState(() {
                            _flightDeparture = picked;
                            if (_flightReturn != null &&
                                _flightReturn!.isBefore(picked)) {
                              _flightReturn =
                                  picked.add(const Duration(days: 1));
                            }
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DateField(
                      icon: Icons.event_rounded,
                      label: 'Return',
                      date: _flightReturn,
                      onTap: () async {
                        final now = DateTime.now();
                        final base = _flightDeparture ??
                            now.add(const Duration(days: 7));
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _flightReturn ??
                              base.add(const Duration(days: 3)),
                          firstDate: base,
                          lastDate:
                              now.add(const Duration(days: 365)),
                          builder: (ctx, child) => Theme(
                            data: Theme.of(ctx).copyWith(
                                colorScheme: const ColorScheme.light(
                                    primary: AppTheme.primary)),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          setState(() => _flightReturn = picked);
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Passengers + Class row
              Row(
                children: [
                  // Passengers counter
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.people_outline,
                              color: AppTheme.primary, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('$_passengers passenger${_passengers > 1 ? 's' : ''}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w500)),
                          ),
                          Row(children: [
                            _CounterBtn(
                              icon: Icons.remove,
                              enabled: _passengers > 1,
                              onTap: () => setState(
                                  () => _passengers--),
                            ),
                            const SizedBox(width: 6),
                            _CounterBtn(
                              icon: Icons.add,
                              enabled: _passengers < 9,
                              onTap: () => setState(
                                  () => _passengers++),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Class dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: DropdownButton<String>(
                      value: _flightClass,
                      underline: const SizedBox(),
                      isDense: true,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: AppTheme.primary, size: 18),
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                      items: const [
                        DropdownMenuItem(
                            value: 'Economy',
                            child: Text('Economy')),
                        DropdownMenuItem(
                            value: 'Business',
                            child: Text('Business')),
                        DropdownMenuItem(
                            value: 'First', child: Text('First')),
                      ],
                      onChanged: (v) =>
                          setState(() => _flightClass = v!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Search button
              _GradientButton(
                label: 'Search Flights',
                icon: Icons.search_rounded,
                onTap: () {
                  if (_flightDeparture == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Please select departure date')),
                    );
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Searching available flights…')),
                  );
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── Available Flights ──────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Available Flights',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('${MockData.flights.length} found',
                    style: const TextStyle(
                        color: AppTheme.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),

        ...MockData.flights
            .map((f) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FlightCard(flight: f, onTap: () {}),
                ))
            .toList(),

        const SizedBox(height: 30),
      ],
    );
  }

  void _openLocationPicker({required bool isFrom}) {
    final controller = TextEditingController(
        text: isFrom ? _fromLocation : _toLocation);
    final presets = [
      'Cairo (CAI)', 'Dubai (DXB)', 'Istanbul (IST)',
      'Riyadh (RUH)', 'Doha (DOH)', 'Jeddah (JED)',
      'London (LHR)', 'Paris (CDG)', 'Tokyo (NRT)',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final media = MediaQuery.of(ctx);
        final maxHeight = media.size.height -
            media.viewPadding.top -
            media.viewInsets.bottom -
            48;
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          constraints: BoxConstraints(maxHeight: maxHeight),
          padding: EdgeInsets.only(
              bottom: media.viewInsets.bottom + 24,
              left: 20,
              right: 20,
              top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                          color: AppTheme.divider,
                          borderRadius: BorderRadius.circular(2))),
                ),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(
                        isFrom
                            ? Icons.flight_takeoff_rounded
                            : Icons.flight_land_rounded,
                        color: AppTheme.primary,
                        size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(isFrom ? 'From where?' : 'Where to?',
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search city or airport...',
                    prefixIcon: const Icon(Icons.search,
                        color: AppTheme.primary, size: 20),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: AppTheme.divider)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: AppTheme.primary, width: 2)),
                    filled: true,
                    fillColor: AppTheme.background,
                  ),
                ),
                const SizedBox(height: 18),
                Text('Popular airports',
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: presets
                      .map((loc) => GestureDetector(
                            onTap: () {
                              controller.text = loc;
                              setState(() {
                                if (isFrom) {
                                  _fromLocation = loc;
                                } else {
                                  _toLocation = loc;
                                }
                              });
                              Navigator.pop(ctx);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.07),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color:
                                        AppTheme.primary.withOpacity(0.2)),
                              ),
                              child: Text(loc,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                _GradientButton(
                  label: 'Confirm',
                  icon: Icons.check_rounded,
                  onTap: () {
                    final v = controller.text.trim();
                    if (v.isEmpty) return;
                    setState(() {
                      if (isFrom) {
                        _fromLocation = v;
                      } else {
                        _toLocation = v;
                      }
                    });
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Supporting Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SearchInputBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchInputBox({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              color: AppTheme.textLight, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppTheme.primary, size: 22),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppTheme.textSecondary, size: 18),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14),
        ),
        style: const TextStyle(
            fontSize: 14, color: AppTheme.textPrimary),
      ),
    );
  }
}

class _FilterToggleBtn extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  const _FilterToggleBtn({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: active ? AppTheme.primaryGradient : null,
          color: active ? null : AppTheme.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: active ? AppTheme.primary : AppTheme.divider),
          boxShadow: active
              ? [
                  BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3))
                ]
              : [],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.tune_rounded,
                color: active ? Colors.white : AppTheme.textSecondary,
                size: 22),
            if (active)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                        color: AppTheme.accent,
                        shape: BoxShape.circle)),
              ),
          ],
        ),
      ),
    );
  }
}

class _TrendingChip extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;
  const _TrendingChip(
      {required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.divider),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _LocationField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final VoidCallback onTap;

  const _LocationField({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textLight,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 15,
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppTheme.textLight, size: 18),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final IconData icon;
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateField({
    required this.icon,
    required this.label,
    required this.date,
    required this.onTap,
  });

  static const _months = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ];

  @override
  Widget build(BuildContext context) {
    final hasDate = date != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hasDate
              ? AppTheme.primary.withOpacity(0.05)
              : AppTheme.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: hasDate
                  ? AppTheme.primary.withOpacity(0.3)
                  : AppTheme.divider),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: hasDate ? AppTheme.primary : AppTheme.textLight,
                size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 9,
                          color: hasDate
                              ? AppTheme.primary
                              : AppTheme.textLight,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  Text(
                    hasDate
                        ? '${date!.day} ${_months[date!.month - 1]}'
                        : 'Select date',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: hasDate
                            ? AppTheme.textPrimary
                            : AppTheme.textLight),
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

class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _CounterBtn(
      {required this.icon,
      required this.enabled,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: enabled
              ? AppTheme.primary.withOpacity(0.1)
              : AppTheme.divider,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            size: 14,
            color: enabled ? AppTheme.primary : AppTheme.textLight),
      ),
    );
  }
}

class _GradientButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _GradientButton(
      {required this.label,
      required this.icon,
      required this.onTap});

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: AppTheme.primary.withOpacity(0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 5)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(widget.label,
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}