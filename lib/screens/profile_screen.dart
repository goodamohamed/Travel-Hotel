import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart' as ap;
import '../providers/booking_provider.dart';
import '../models/models.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ap.AuthProvider>();
    final bookingProvider = context.read<BookingProvider>();
    final displayName = auth.appUser?.name ?? auth.firebaseUser?.displayName ?? 'Traveler';
    final email = auth.appUser?.email ?? auth.firebaseUser?.email ?? '';
    final tier = auth.appUser?.membershipTier ?? 'Silver';
    final points = auth.appUser?.points ?? 0;
    final wishlistCount = auth.wishlistHotelIds.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ─── Header ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  height: 200,
                  decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Row(
                      children: [
                        Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.person, color: Colors.white, size: 36),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(displayName, style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(email, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.accent.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text('$tier Member ✦', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── Stats ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 14, offset: const Offset(0, 4))],
              ),
              child: auth.isAuthenticated
                  ? StreamBuilder<List<Booking>>(
                      stream: bookingProvider.bookingsStream(auth.userId),
                      builder: (context, snap) {
                        final trips = (snap.data ?? const <Booking>[]).length;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _ProfileStat(value: '$trips', label: 'Trips'),
                            const _VerticalDivider(),
                            const _ProfileStat(value: '0', label: 'Reviews'),
                            const _VerticalDivider(),
                            _ProfileStat(value: '$wishlistCount', label: 'Wishlist'),
                            const _VerticalDivider(),
                            _ProfileStat(value: '$points', label: 'Points'),
                          ],
                        );
                      },
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ProfileStat(value: '-', label: 'Trips'),
                        _VerticalDivider(),
                        _ProfileStat(value: '-', label: 'Reviews'),
                        _VerticalDivider(),
                        _ProfileStat(value: '-', label: 'Wishlist'),
                        _VerticalDivider(),
                        _ProfileStat(value: '-', label: 'Points'),
                      ],
                    ),
            ),
          ),

          // ─── Settings Sections ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _SettingsSection(
                    title: 'Account',
                    items: const [
                      _SettingsItem(icon: Icons.person_outline, label: 'Personal Information', showArrow: true),
                      _SettingsItem(icon: Icons.credit_card_outlined, label: 'Payment Methods', showArrow: true),
                      _SettingsItem(icon: Icons.notifications_outlined, label: 'Notifications', showArrow: true),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _SettingsSection(
                    title: 'Preferences',
                    items: const [
                      _SettingsItem(icon: Icons.language_outlined, label: 'Language & Region', trailing: 'English', showArrow: true),
                      _SettingsItem(icon: Icons.attach_money_outlined, label: 'Currency', trailing: 'USD', showArrow: true),
                      _SettingsItem(icon: Icons.dark_mode_outlined, label: 'Dark Mode', showToggle: true),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _SettingsSection(
                    title: 'Support',
                    items: const [
                      _SettingsItem(icon: Icons.help_outline, label: 'Help Center', showArrow: true),
                      _SettingsItem(icon: Icons.chat_bubble_outline, label: 'Contact Support', showArrow: true),
                      _SettingsItem(icon: Icons.star_outline, label: 'Rate TravelMate', showArrow: true),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 30),
                    child: OutlinedButton.icon(
                      onPressed: auth.isAuthenticated ? () => context.read<ap.AuthProvider>().signOut() : null,
                      icon: const Icon(Icons.logout, color: AppTheme.wishlistColor),
                      label: const Text('Sign Out', style: TextStyle(color: AppTheme.wishlistColor, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.wishlistColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;
  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.textPrimary)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 36, color: AppTheme.divider);
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;
  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textSecondary, letterSpacing: 0.5)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Column(
            children: items.asMap().entries.map((e) => Column(
              children: [
                e.value,
                if (e.key < items.length - 1) const Divider(height: 1, indent: 54, endIndent: 16),
              ],
            )).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final bool showArrow;
  final bool showToggle;
  const _SettingsItem({required this.icon, required this.label, this.trailing, this.showArrow = false, this.showToggle = false});

  @override
  State<_SettingsItem> createState() => _SettingsItemState();
}

class _SettingsItemState extends State<_SettingsItem> {
  bool _toggled = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
        child: Icon(widget.icon, color: AppTheme.primary, size: 20),
      ),
      title: Text(widget.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
      trailing: widget.showToggle
          ? Switch(value: _toggled, onChanged: (v) => setState(() => _toggled = v), activeColor: AppTheme.primary)
          : widget.trailing != null
              ? Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(widget.trailing!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  if (widget.showArrow) const Icon(Icons.chevron_right, color: AppTheme.textLight, size: 20),
                ])
              : widget.showArrow
                  ? const Icon(Icons.chevron_right, color: AppTheme.textLight, size: 20)
                  : null,
    );
  }
}
