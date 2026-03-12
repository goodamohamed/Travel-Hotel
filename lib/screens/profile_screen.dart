import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:travel_hotel_app/PaymentScreen.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart' as ap;
import '../providers/booking_provider.dart';
import '../models/models.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ap.AuthProvider>();
    final bookingProvider = context.read<BookingProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    final displayName =
        auth.appUser?.name ?? auth.firebaseUser?.displayName ?? 'Traveler';
    final email = auth.appUser?.email ?? auth.firebaseUser?.email ?? '';
    final tier = auth.appUser?.membershipTier ?? 'Silver';
    final points = auth.appUser?.points ?? 0;
    final wishlistCount = auth.wishlistHotelIds.length;

    // ── Dynamic Colors
    final bg = isDark ? const Color(0xFF0F1117) : AppTheme.background;
    final cardBg = isDark ? const Color(0xFF1C1F2E) : Colors.white;
    final textPri = isDark ? Colors.white : AppTheme.textPrimary;
    final textSec = isDark ? Colors.white60 : AppTheme.textSecondary;
    final textLight = isDark ? Colors.white38 : AppTheme.textLight;
    final divColor = isDark ? Colors.white12 : AppTheme.divider;
    final iconBg = isDark
        ? AppTheme.primary.withOpacity(0.15)
        : AppTheme.primary.withOpacity(0.08);
    final shadowColor =
        isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.05);

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          // ─── Header
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  height: 200,
                  decoration:
                      const BoxDecoration(gradient: AppTheme.primaryGradient),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Row(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.person,
                              color: Colors.white, size: 36),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(displayName,
                                  style: GoogleFonts.playfairDisplay(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(email,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.accent.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text('$tier Member ✦',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.edit_outlined,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── Stats
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: shadowColor,
                      blurRadius: 14,
                      offset: const Offset(0, 4))
                ],
              ),
              child: auth.isAuthenticated
                  ? StreamBuilder<List<Booking>>(
                      stream: bookingProvider.bookingsStream(auth.userId),
                      builder: (context, snap) {
                        final trips = (snap.data ?? const <Booking>[]).length;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _ProfileStat(
                                value: '$trips',
                                label: 'Trips',
                                textPri: textPri,
                                textSec: textSec),
                            _VerticalDivider(color: divColor),
                            _ProfileStat(
                                value: '0',
                                label: 'Reviews',
                                textPri: textPri,
                                textSec: textSec),
                            _VerticalDivider(color: divColor),
                            _ProfileStat(
                                value: '$wishlistCount',
                                label: 'Wishlist',
                                textPri: textPri,
                                textSec: textSec),
                            _VerticalDivider(color: divColor),
                            _ProfileStat(
                                value: '$points',
                                label: 'Points',
                                textPri: textPri,
                                textSec: textSec),
                          ],
                        );
                      },
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ProfileStat(
                            value: '-',
                            label: 'Trips',
                            textPri: textPri,
                            textSec: textSec),
                        _VerticalDivider(color: divColor),
                        _ProfileStat(
                            value: '-',
                            label: 'Reviews',
                            textPri: textPri,
                            textSec: textSec),
                        _VerticalDivider(color: divColor),
                        _ProfileStat(
                            value: '-',
                            label: 'Wishlist',
                            textPri: textPri,
                            textSec: textSec),
                        _VerticalDivider(color: divColor),
                        _ProfileStat(
                            value: '-',
                            label: 'Points',
                            textPri: textPri,
                            textSec: textSec),
                      ],
                    ),
            ),
          ),

          // ─── Settings Sections
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _SettingsSection(
                    title: 'Account',
                    cardBg: cardBg,
                    textSec: textSec,
                    divColor: divColor,
                    items: [
                      _SettingsItem(
                        icon: Icons.person_outline,
                        label: 'Personal Information',
                        showArrow: true,
                        iconBg: iconBg,
                        textPri: textPri,
                        textSec: textSec,
                        textLight: textLight,
                      ),
                      _SettingsItem(
                        icon: Icons.credit_card_outlined,
                        label: 'Payment Methods',
                        showArrow: true,
                        iconBg: iconBg,
                        textPri: textPri,
                        textSec: textSec,
                        textLight: textLight,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PaymentScreen())),
                      ),
                      _SettingsItem(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        showArrow: true,
                        iconBg: iconBg,
                        textPri: textPri,
                        textSec: textSec,
                        textLight: textLight,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _SettingsSection(
                    title: 'Preferences',
                    cardBg: cardBg,
                    textSec: textSec,
                    divColor: divColor,
                    items: [
                      _SettingsItem(
                        icon: Icons.language_outlined,
                        label: 'Language & Region',
                        trailing: 'English',
                        showArrow: true,
                        iconBg: iconBg,
                        textPri: textPri,
                        textSec: textSec,
                        textLight: textLight,
                      ),
                      _SettingsItem(
                        icon: Icons.attach_money_outlined,
                        label: 'Currency',
                        trailing: 'USD',
                        showArrow: true,
                        iconBg: iconBg,
                        textPri: textPri,
                        textSec: textSec,
                        textLight: textLight,
                      ),
                      Consumer<ThemeProvider>(
                        builder: (context, themeProvider, child) {
                          return _SettingsItem(
                            icon: themeProvider.isDarkMode
                                ? Icons.dark_mode_outlined
                                : Icons.light_mode_outlined,
                            label: 'Dark Mode',
                            showToggle: true,
                            toggleValue: themeProvider.isDarkMode,
                            onToggle: (val) => themeProvider.toggleTheme(val),
                            iconBg: iconBg,
                            textPri: textPri,
                            textSec: textSec,
                            textLight: textLight,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _SettingsSection(
                    title: 'Support',
                    cardBg: cardBg,
                    textSec: textSec,
                    divColor: divColor,
                    items: [
                      _SettingsItem(
                        icon: Icons.help_outline,
                        label: 'Help Center',
                        showArrow: true,
                        iconBg: iconBg,
                        textPri: textPri,
                        textSec: textSec,
                        textLight: textLight,
                      ),
                      _SettingsItem(
                        icon: Icons.chat_bubble_outline,
                        label: 'Contact Support',
                        showArrow: true,
                        iconBg: iconBg,
                        textPri: textPri,
                        textSec: textSec,
                        textLight: textLight,
                      ),
                      _SettingsItem(
                        icon: Icons.star_outline,
                        label: 'Rate TravelMate',
                        showArrow: true,
                        iconBg: iconBg,
                        textPri: textPri,
                        textSec: textSec,
                        textLight: textLight,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 30),
                    child: OutlinedButton.icon(
                      onPressed: auth.isAuthenticated
                          ? () => context.read<ap.AuthProvider>().signOut()
                          : null,
                      icon: const Icon(Icons.logout,
                          color: AppTheme.wishlistColor),
                      label: const Text('Sign Out',
                          style: TextStyle(
                              color: AppTheme.wishlistColor,
                              fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.wishlistColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
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

// ─── Stat Widget
class _ProfileStat extends StatelessWidget {
  final String value, label;
  final Color textPri, textSec;
  const _ProfileStat(
      {required this.value,
      required this.label,
      required this.textPri,
      required this.textSec});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
          style: TextStyle(
              fontWeight: FontWeight.w800, fontSize: 18, color: textPri)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(fontSize: 11, color: textSec)),
    ]);
  }
}

// ─── Vertical Divider
class _VerticalDivider extends StatelessWidget {
  final Color color;
  const _VerticalDivider({required this.color});
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36, color: color);
}

// ─── Settings Section
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> items;
  final Color cardBg, textSec, divColor;
  const _SettingsSection(
      {required this.title,
      required this.items,
      required this.cardBg,
      required this.textSec,
      required this.divColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: textSec,
                  letterSpacing: 0.5)),
        ),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3))
            ],
          ),
          child: Column(
            children: items
                .asMap()
                .entries
                .map((e) => Column(children: [
                      e.value,
                      if (e.key < items.length - 1)
                        Divider(
                            height: 1,
                            indent: 54,
                            endIndent: 16,
                            color: divColor),
                    ]))
                .toList(),
          ),
        ),
      ],
    );
  }
}

// ─── Settings Item
class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final bool showArrow;
  final bool showToggle;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggle;
  final Color iconBg, textPri, textSec, textLight;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.trailing,
    this.showArrow = false,
    this.showToggle = false,
    this.toggleValue,
    this.onToggle,
    required this.iconBg,
    required this.textPri,
    required this.textSec,
    required this.textLight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
            color: iconBg, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      title: Text(label,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: textPri)),
      trailing: showToggle
          ? Switch(
              value: toggleValue ?? false,
              onChanged: onToggle,
              activeColor: AppTheme.primary)
          : trailing != null
              ? Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(trailing!,
                      style: TextStyle(color: textSec, fontSize: 13)),
                  if (showArrow)
                    Icon(Icons.chevron_right, color: textLight, size: 20),
                ])
              : showArrow
                  ? Icon(Icons.chevron_right, color: textLight, size: 20)
                  : null,
    );
  }
}
