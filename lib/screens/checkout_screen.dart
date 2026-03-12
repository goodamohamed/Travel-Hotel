import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart' as ap;
import '../providers/booking_provider.dart';
import '../providers/theme_provider.dart';
import 'main_navigation.dart';

class CheckoutScreen extends StatefulWidget {
  final Hotel hotel;
  const CheckoutScreen({super.key, required this.hotel});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with TickerProviderStateMixin {
  DateTime _checkIn = DateTime.now().add(const Duration(days: 3));
  late DateTime _checkOut;
  int _guests = 2;
  int _rooms = 1;
  bool _isProcessing = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _checkOut = DateTime.now().add(const Duration(days: 5));
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  int get _nights => _checkOut.difference(_checkIn).inDays;
  double get _subtotal =>
      widget.hotel.pricePerNight * (_nights > 0 ? _nights : 1) * _rooms;
  double get _taxes => _subtotal * 0.12;
  double get _serviceFee => 15;
  double get _totalPrice => _subtotal + _taxes + _serviceFee;

  void _confirmBooking() async {
    if (_nights <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-out must be after check-in date.')),
      );
      return;
    }
    final auth = context.read<ap.AuthProvider>();
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please sign in to complete your booking.')),
      );
      return;
    }
    setState(() => _isProcessing = true);
    final bp = context.read<BookingProvider>();
    final booking = await bp.createBooking(
      userId: auth.userId,
      hotelId: widget.hotel.id,
      hotelName: widget.hotel.name,
      hotelLocation: '${widget.hotel.location}, ${widget.hotel.country}',
      checkIn: _checkIn,
      checkOut: _checkOut,
      guests: _guests,
      rooms: _rooms,
      totalPrice: _totalPrice,
    );
    setState(() => _isProcessing = false);
    if (booking != null && mounted) {
      _showSuccessSheet(booking.confirmationCode);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(bp.error ?? 'Booking failed.')),
      );
    }
  }

  void _showSuccessSheet(String code) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SuccessSheet(
        hotelName: widget.hotel.name,
        confirmationCode: code,
        onDone: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (_) => const MainNavigation(initialIndex: 2)),
            (route) => false,
          );
        },
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _checkIn, end: _checkOut),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _checkIn = picked.start;
        _checkOut = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final bg = isDark ? const Color(0xFF0F1117) : AppTheme.background;
    final rootBg = isDark ? const Color(0xFF0F1117) : const Color(0xFFF6F8FF);
    final cardBg = isDark ? const Color(0xFF1C1F2E) : Colors.white;
    final textSec = isDark ? Colors.white60 : AppTheme.textSecondary;
    final divColor = isDark ? Colors.white12 : AppTheme.divider;

    return Scaffold(
      backgroundColor: bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  Container(
                    height: 200,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.07),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.arrow_back_rounded,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Complete Booking',
                                  style: GoogleFonts.playfairDisplay(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(widget.hotel.name,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -24),
                child: Container(
                  decoration: BoxDecoration(
                    color: rootBg,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HotelMiniCard(hotel: widget.hotel),
                        const SizedBox(height: 28),
                        _SectionTitle(
                            icon: Icons.calendar_month_rounded,
                            title: 'Select Dates'),
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: _selectDateRange,
                          child: _DatesCard(
                              checkIn: _checkIn,
                              checkOut: _checkOut,
                              nights: _nights),
                        ),
                        const SizedBox(height: 28),
                        _SectionTitle(
                            icon: Icons.people_alt_rounded,
                            title: 'Guests & Rooms'),
                        const SizedBox(height: 14),
                        Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  color: isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.05),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4))
                            ],
                          ),
                          child: Column(
                            children: [
                              _CounterRow(
                                icon: Icons.people_outline_rounded,
                                label: 'Guests',
                                subtitle: 'Adults & children',
                                value: _guests,
                                onChanged: (v) => setState(() => _guests = v),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 18),
                                child: Divider(
                                    height: 1,
                                    color: divColor.withOpacity(0.5)),
                              ),
                              _CounterRow(
                                icon: Icons.bed_outlined,
                                label: 'Rooms',
                                subtitle: 'Number of rooms',
                                value: _rooms,
                                onChanged: (v) => setState(() => _rooms = v),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        _SectionTitle(
                            icon: Icons.receipt_long_rounded,
                            title: 'Price Summary'),
                        const SizedBox(height: 14),
                        _PriceCard(
                          hotel: widget.hotel,
                          nights: _nights > 0 ? _nights : 1,
                          rooms: _rooms,
                          subtotal: _subtotal,
                          taxes: _taxes,
                          serviceFee: _serviceFee,
                          total: _totalPrice,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: cardBg,
          boxShadow: [
            BoxShadow(
                color: isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.08),
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
                Text('Total',
                    style:
                        TextStyle(color: textSec, fontSize: 11)),
                Text('\$${_totalPrice.toInt()}',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                        height: 1.1)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: _isProcessing ? null : _confirmBooking,
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: _isProcessing
                        ? null
                        : const LinearGradient(
                            colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)]),
                    color: _isProcessing ? divColor : null,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: _isProcessing
                        ? []
                        : [
                            BoxShadow(
                                color: AppTheme.primary.withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4))
                          ],
                  ),
                  child: Center(
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.lock_rounded,
                                  color: Colors.white, size: 14),
                              SizedBox(width: 6),
                              Text('Confirm Booking',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14)),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HotelMiniCard extends StatelessWidget {
  final Hotel hotel;
  const _HotelMiniCard({required this.hotel});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final cardBg = isDark ? const Color(0xFF1C1F2E) : Colors.white;
    final textPri = isDark ? Colors.white : AppTheme.textPrimary;
    final textSec = isDark ? Colors.white60 : AppTheme.textSecondary;
    final textLight = isDark ? Colors.white38 : AppTheme.textLight;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child:
                const Icon(Icons.hotel_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hotel.name,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: textPri),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.location_on,
                      size: 13, color: AppTheme.accent),
                  const SizedBox(width: 3),
                  Flexible(
                      child: Text('${hotel.location}, ${hotel.country}',
                          style: TextStyle(
                              color: textSec, fontSize: 12),
                          overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.star_rounded,
                      color: AppTheme.starColor, size: 14),
                  const SizedBox(width: 3),
                  Text('${hotel.rating}',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: textPri)),
                  Text(' (${hotel.reviewCount})',
                      style: TextStyle(
                          color: textLight, fontSize: 11)),
                ]),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${hotel.pricePerNight.toInt()}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: AppTheme.primary)),
              Text('/night',
                  style: TextStyle(color: textLight, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DatesCard extends StatelessWidget {
  final DateTime checkIn;
  final DateTime checkOut;
  final int nights;
  const _DatesCard(
      {required this.checkIn, required this.checkOut, required this.nights});

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final cardBg = isDark ? const Color(0xFF1C1F2E) : Colors.white;
    final textPri = isDark ? Colors.white : AppTheme.textPrimary;
    final textSec = isDark ? Colors.white60 : AppTheme.textSecondary;
    final textLight = isDark ? Colors.white38 : AppTheme.textLight;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.4) : AppTheme.primary.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: const [
                  Icon(Icons.flight_land_rounded,
                      size: 13, color: AppTheme.primary),
                  SizedBox(width: 4),
                  Text('CHECK-IN',
                      style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2)),
                ]),
                const SizedBox(height: 6),
                Text('${checkIn.day}',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 30,
                        color: textPri,
                        height: 1)),
                Text('${_months[checkIn.month - 1]} ${checkIn.year}',
                    style: TextStyle(
                        color: textSec,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: AppTheme.primary.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(children: [
                Text('$nights',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        height: 1)),
                const Text('nights',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
            const SizedBox(height: 6),
            Icon(Icons.edit_calendar_rounded,
                size: 14, color: textLight),
            Text('tap to edit',
                style: TextStyle(
                    color: textLight,
                    fontSize: 9,
                    fontWeight: FontWeight.w500)),
          ]),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.end, children: const [
                  Text('CHECK-OUT',
                      style: TextStyle(
                          color: AppTheme.accent,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2)),
                  SizedBox(width: 4),
                  Icon(Icons.flight_takeoff_rounded,
                      size: 13, color: AppTheme.accent),
                ]),
                const SizedBox(height: 6),
                Text('${checkOut.day}',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 30,
                        color: textPri,
                        height: 1)),
                Text('${_months[checkOut.month - 1]} ${checkOut.year}',
                    style: TextStyle(
                        color: textSec,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CounterRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final int value;
  final ValueChanged<int> onChanged;
  const _CounterRow(
      {required this.icon,
      required this.label,
      required this.subtitle,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final textPri = isDark ? Colors.white : AppTheme.textPrimary;
    final textSec = isDark ? Colors.white60 : AppTheme.textSecondary;
    final divColor = isDark ? Colors.white12 : AppTheme.divider;
    final textLight = isDark ? Colors.white38 : AppTheme.textLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: textPri)),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 11, color: textSec)),
              ],
            ),
          ),
          Row(children: [
            GestureDetector(
              onTap: value > 1 ? () => onChanged(value - 1) : null,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: value > 1
                      ? AppTheme.primary.withOpacity(0.1)
                      : divColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.remove_rounded,
                    size: 16,
                    color: value > 1 ? AppTheme.primary : textLight),
              ),
            ),
            SizedBox(
                width: 38,
                child: Text('$value',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: textPri,
                        fontWeight: FontWeight.w800, fontSize: 17))),
            GestureDetector(
              onTap: () => onChanged(value + 1),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)]),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: AppTheme.primary.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: const Icon(Icons.add_rounded,
                    size: 16, color: Colors.white),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final Hotel hotel;
  final int nights;
  final int rooms;
  final double subtotal;
  final double taxes;
  final double serviceFee;
  final double total;

  const _PriceCard(
      {required this.hotel,
      required this.nights,
      required this.rooms,
      required this.subtotal,
      required this.taxes,
      required this.serviceFee,
      required this.total});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final cardBg = isDark ? const Color(0xFF1C1F2E) : Colors.white;
    final textPri = isDark ? Colors.white : AppTheme.textPrimary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(children: [
        _PriceRow(
            label:
                '\$${hotel.pricePerNight.toInt()} × $nights nights × $rooms room${rooms > 1 ? 's' : ''}',
            value: '\$${subtotal.toInt()}'),
        const SizedBox(height: 10),
        _PriceRow(label: 'Taxes & fees (12%)', value: '\$${taxes.toInt()}'),
        const SizedBox(height: 10),
        _PriceRow(label: 'Service fee', value: '\$${serviceFee.toInt()}'),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: isDark ? null : const LinearGradient(
                colors: [Color(0xFFEEF4FF), Color(0xFFE3EEFF)]),
            color: isDark ? const Color(0xFF0F1117) : null,
            borderRadius: BorderRadius.circular(14),
          ),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Total',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: textPri)),
            Text('\$${total.toInt()}',
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: AppTheme.primary)),
          ]),
        ),
      ]),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  const _PriceRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final textPri = isDark ? Colors.white : AppTheme.textPrimary;
    final textSec = isDark ? Colors.white60 : AppTheme.textSecondary;

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Flexible(
          child: Text(label,
              style: TextStyle(
                  color: textSec, fontSize: 13))),
      Text(value,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: textPri)),
    ]);
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final textPri = isDark ? Colors.white : AppTheme.textPrimary;

    return Row(children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)]),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
      const SizedBox(width: 10),
      Text(title,
          style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textPri)),
    ]);
  }
}

class _SuccessSheet extends StatelessWidget {
  final String hotelName;
  final String confirmationCode;
  final VoidCallback onDone;
  const _SuccessSheet(
      {required this.hotelName,
      required this.confirmationCode,
      required this.onDone});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final cardBg = isDark ? const Color(0xFF1C1F2E) : Colors.white;
    final divColor = isDark ? Colors.white12 : AppTheme.divider;
    final textPri = isDark ? Colors.white : AppTheme.textPrimary;
    final textSec = isDark ? Colors.white60 : AppTheme.textSecondary;
    final bg = isDark ? const Color(0xFF0F1117) : AppTheme.background;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: divColor,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)]),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.check_rounded, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 18),
          Text('Booking Confirmed!',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 24, fontWeight: FontWeight.w700, color: textPri)),
          const SizedBox(height: 8),
          Text('Your stay at $hotelName is confirmed.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: textSec, fontSize: 14)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14)),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Confirmation Code',
                      style: TextStyle(
                          color: textSec, fontSize: 13)),
                  Text(confirmationCode,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                          fontSize: 14)),
                ]),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onDone,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)]),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                      color: AppTheme.primary.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5))
                ],
              ),
              child: const Center(
                child: Text('View My Bookings',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15)),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
