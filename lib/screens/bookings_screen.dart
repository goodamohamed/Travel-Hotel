import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/auth_provider.dart' as ap;
import '../providers/booking_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/widgets.dart';
import 'checkout_screen.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Booking> _filterByStatus(
      List<Booking> bookings, List<BookingStatus> statuses) {
    final filtered =
        bookings.where((b) => statuses.contains(b.status)).toList();
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ap.AuthProvider>();
    final bookingProvider = context.read<BookingProvider>();
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final bg = isDark ? const Color(0xFF0F1117) : AppTheme.background;
    final cardBg = isDark ? const Color(0xFF1C1F2E) : Colors.white;
    final textPri = isDark ? Colors.white : AppTheme.textPrimary;
    final textSec = isDark ? Colors.white60 : AppTheme.textSecondary;
    final divColor = isDark ? Colors.white12 : AppTheme.divider;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        title: Text('My Bookings',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: textPri)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: divColor),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(11),
                        boxShadow: [
                          BoxShadow(
                              color: AppTheme.primary.withOpacity(0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: textSec,
                      labelStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700, fontSize: 13),
                      unselectedLabelStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500, fontSize: 13),
                      tabs: const [
                        Tab(text: 'Upcoming'),
                        Tab(text: 'Completed'),
                        Tab(text: 'Cancelled'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // Navigate to CheckoutScreen, passing a fallback hotel since BookingsScreen isn't tied to one.
                    final fallbackHotel = Hotel(
                      id: 'h1',
                      name: 'Azure Santorini Resort',
                      location: 'Santorini',
                      country: 'Greece',
                      description: 'A beautiful resort fallback.',
                      pricePerNight: 420,
                      rating: 4.9,
                      reviewCount: 1876,
                      stars: 5,
                      images: [
                        'https://images.unsplash.com/photo-1570077188670-e3a8d69ac542?w=800'
                      ],
                      amenities: ['Pool', 'Spa', 'Free Wifi'],
                      lat: 36.3932,
                      lng: 25.4615,
                    );
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                    CheckoutScreen(hotel: fallbackHotel)));
                  },
                  child: Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.swap_horiz_rounded,
                        color: AppTheme.primary, size: 22),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: auth.isAuthenticated
          ? StreamBuilder<List<Booking>>(
              stream: bookingProvider.bookingsStream(auth.userId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
                }

                final bookings = snapshot.data ?? [];

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingList(_filterByStatus(bookings,
                        [BookingStatus.confirmed, BookingStatus.pending])),
                    _buildBookingList(_filterByStatus(
                        bookings, [BookingStatus.completed])),
                    _buildBookingList(_filterByStatus(
                        bookings, [BookingStatus.cancelled])),
                  ],
                );
              },
            )
          : Center(
              child: Text(
                'Please sign in to see your bookings',
                style: TextStyle(color: textSec),
              ),
            ),
    );
  }

  Widget _buildBookingList(List<Booking> bookings) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final textPri = isDark ? Colors.white : AppTheme.textPrimary;
    final textSec = isDark ? Colors.white60 : AppTheme.textSecondary;

    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.08),
                  shape: BoxShape.circle),
              child: const Icon(Icons.luggage_outlined,
                  color: AppTheme.primary, size: 36),
            ),
            const SizedBox(height: 16),
            Text('No bookings here',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: textPri)),
            const SizedBox(height: 6),
            Text('Start exploring and book your next adventure!',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: textSec, fontSize: 13)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: bookings.length,
      itemBuilder: (ctx, i) => _BookingCard(booking: bookings[i]),
    );
  }
}

// Booking Card

class _BookingCard extends StatelessWidget {
  final Booking booking;
  const _BookingCard({required this.booking});

  static const months = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 18,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          // ── Gradient header
          Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.hotel, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.hotelName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15),
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Row(children: [
                        const Icon(Icons.location_on,
                            color: Colors.white60, size: 12),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(booking.hotelLocation,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                BookingStatusBadge(status: booking.status),
              ],
            ),
          ),

          // ── Body 
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              children: [
                // ── Dates card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      // Check-in
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
                            const SizedBox(height: 5),
                            Text('${booking.checkIn.day}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 26,
                                    color: AppTheme.textPrimary,
                                    height: 1)),
                            Text(
                              '${months[booking.checkIn.month - 1]} ${booking.checkIn.year}',
                              style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      // Nights badge
                      Column(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                  color: AppTheme.primary.withOpacity(0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3)),
                            ],
                          ),
                          child: Column(children: [
                            Text('${booking.nights}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    height: 1)),
                            const Text('nights',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600)),
                          ]),
                        ),
                        const SizedBox(height: 6),
                        Row(children: [
                          Container(width: 20, height: 1, color: AppTheme.divider),
                          const Icon(Icons.arrow_forward,
                              size: 12, color: AppTheme.textLight),
                          Container(width: 20, height: 1, color: AppTheme.divider),
                        ]),
                      ]),
                      // Check-out
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: const [
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
                            const SizedBox(height: 5),
                            Text('${booking.checkOut.day}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 26,
                                    color: AppTheme.textPrimary,
                                    height: 1)),
                            Text(
                              '${months[booking.checkOut.month - 1]} ${booking.checkOut.year}',
                              style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ── Info chips
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Guests chip
                    _PillChip(
                      icon: Icons.people_outline,
                      label: '${booking.guests} guests',
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppTheme.success.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                                Icons.confirmation_number_outlined,
                                size: 13,
                                color: AppTheme.success),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                booking.confirmationCode,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.success,
                                    fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Total price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Total paid',
                            style: TextStyle(
                                color: AppTheme.textLight, fontSize: 10)),
                        Text('\$${booking.totalPrice.toInt()}',
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 20)),
                      ],
                    ),
                  ],
                ),

                // ── Action buttons ──────────────────────────────────
                if (booking.status == BookingStatus.confirmed ||
                    booking.status == BookingStatus.pending) ...[
                  const SizedBox(height: 16),
                  const _DashedDivider(),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _CancelButton(
                          onTap: () async {
                            final provider = context.read<BookingProvider>();
                            final ok = await _showConfirmDialog(
                              context,
                              title: 'Cancel Booking?',
                              message:
                                  'This action cannot be undone. Your booking will be cancelled.',
                              confirmLabel: 'Yes, Cancel',
                              isDestructive: true,
                            );
                            if (ok == true) {
                              await provider.cancelBooking(booking.id);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(child: _ViewDetailsButton()),
                    ],
                  ),

                  const SizedBox(height: 10),

                  _MarkCompletedButton(
                    onTap: () async {
                      final provider = context.read<BookingProvider>();
                      final ok = await _showConfirmDialog(
                        context,
                        title: 'Mark as Completed?',
                        message:
                            'Confirm your stay is done and move to Completed.',
                        confirmLabel: 'Mark Completed',
                        isDestructive: false,
                      );
                      if (ok == true) {
                        await provider.completeBooking(booking.id);
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required bool isDestructive,
  }) {
    return showDialog<bool>(
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
                  color: isDestructive
                      ? AppTheme.wishlistColor.withOpacity(0.1)
                      : AppTheme.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDestructive
                      ? Icons.cancel_outlined
                      : Icons.check_circle_outline,
                  color: isDestructive ? AppTheme.wishlistColor : AppTheme.success,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 8),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.5)),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppTheme.divider),
                        ),
                      ),
                      child: const Text('No, keep it',
                          style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDestructive
                            ? AppTheme.wishlistColor
                            : AppTheme.success,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(confirmLabel,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Buttons
// ─────────────────────────────────────────────────────────────────────────────

class _CancelButton extends StatefulWidget {
  final VoidCallback onTap;
  const _CancelButton({required this.onTap});
  @override
  State<_CancelButton> createState() => _CancelButtonState();
}

class _CancelButtonState extends State<_CancelButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.95)
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
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: AppTheme.wishlistColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppTheme.wishlistColor.withOpacity(0.4), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.close_rounded, color: AppTheme.wishlistColor, size: 18),
              SizedBox(width: 6),
              Text('Cancel',
                  style: TextStyle(
                      color: AppTheme.wishlistColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewDetailsButton extends StatefulWidget {
  const _ViewDetailsButton();
  @override
  State<_ViewDetailsButton> createState() => _ViewDetailsButtonState();
}

class _ViewDetailsButtonState extends State<_ViewDetailsButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.95)
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
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: AppTheme.primary.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.receipt_long_outlined, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text('View Details',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarkCompletedButton extends StatefulWidget {
  final VoidCallback onTap;
  const _MarkCompletedButton({required this.onTap});
  @override
  State<_MarkCompletedButton> createState() => _MarkCompletedButtonState();
}

class _MarkCompletedButtonState extends State<_MarkCompletedButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _pressed
              ? AppTheme.success.withOpacity(0.12)
              : AppTheme.success.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.success.withOpacity(_pressed ? 0.6 : 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle_outline_rounded,
                color: AppTheme.success, size: 17),
            SizedBox(width: 7),
            Text('Mark as Completed',
                style: TextStyle(
                    color: AppTheme.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _PillChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _PillChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        const dashW = 6.0;
        const gap = 4.0;
        final count = (constraints.maxWidth / (dashW + gap)).floor();
        return Row(
          children: List.generate(
            count,
            (_) => Container(
              width: dashW,
              height: 1,
              margin: const EdgeInsets.only(right: gap),
              color: AppTheme.divider,
            ),
          ),
        );
      },
    );
  }
}