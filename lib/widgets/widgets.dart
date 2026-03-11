import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

// ده كارت الفندق اللي بيظهر في القوائم
class HotelCard extends StatefulWidget {
  final Hotel hotel;
  final VoidCallback onTap;
  final VoidCallback onWishlistToggle;

  const HotelCard({
    super.key,
    required this.hotel,
    required this.onTap,
    required this.onWishlistToggle,
  });

  @override
  // بيربط الـ Widget بالـ State اللي بتدير الحركة والتفاعل
  State<HotelCard> createState() => _HotelCardState();
}

class _HotelCardState extends State<HotelCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  // بنجهّز أنيميشن الضغط/اللمس بتاع الكارد
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  // تنظيف الكنترولر عشان مايحصلش تسريب في الذاكرة
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  // بيرسم كارت الفندق بالشكل والتفاعل اللي ظاهرين في الـ UI
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ده جزء صورة الفندق
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: widget.hotel.images.first,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (ctx, url) => Container(
                        height: 200,
                        color: AppTheme.divider,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (ctx, url, err) => Container(
                        height: 200,
                        color: const Color(0xFFE8F0FE),
                        child: const Icon(Icons.hotel, size: 60, color: AppTheme.primary),
                      ),
                    ),
                  ),
                  // ده تدرّج فوق الصورة عشان الكلام يبان
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: Container(decoration: const BoxDecoration(gradient: AppTheme.heroGradient)),
                    ),
                  ),
                  // ده بادج بسيط لو فيه تاج زي Best Value
                  if (widget.hotel.tag.isNotEmpty)
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.hotel.tag,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  // ده زرار القلب بتاع الوِش ليست
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: widget.onWishlistToggle,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.hotel.isWishlisted ? Icons.favorite : Icons.favorite_border,
                          color: widget.hotel.isWishlisted ? AppTheme.wishlistColor : AppTheme.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  // ده مكان الفندق والسعر فوق الصورة من تحت
                  Positioned(
                    bottom: 12,
                    left: 14,
                    right: 14,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.white70, size: 14),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  '${widget.hotel.location}, ${widget.hotel.country}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '\$${widget.hotel.pricePerNight.toInt()}/night',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // ده تفاصيل الفندق تحت الصورة
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            widget.hotel.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: List.generate(
                            widget.hotel.stars,
                            (i) => const Icon(Icons.star, color: AppTheme.starColor, size: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${widget.hotel.rating}',
                            style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 8),
                        RatingBarIndicator(
                          rating: widget.hotel.rating,
                          itemBuilder: (ctx, i) => const Icon(Icons.star, color: AppTheme.starColor),
                          itemCount: 5,
                          itemSize: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(${widget.hotel.reviewCount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')})',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: widget.hotel.amenities.take(4).map((a) => AmenityChip(label: a)).toList().cast<Widget>(),
                    ),
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

// ده شيب للمميزات زي واي فاي وجيم
class AmenityChip extends StatelessWidget {
  final String label;
  const AmenityChip({super.key, required this.label});

  // بنختار أيقونة مناسبة حسب اسم الميزة
  IconData _icon() {
    switch (label.toLowerCase()) {
      case 'free wifi': return Icons.wifi;
      case 'pool': case 'private pool': case 'private infinity pool': return Icons.pool;
      case 'spa': return Icons.spa;
      case 'gym': return Icons.fitness_center;
      case 'restaurant': return Icons.restaurant;
      case 'bar': case 'rooftop bar': return Icons.local_bar;
      case 'sea view': case 'city views': return Icons.visibility;
      case 'breakfast included': case 'traditional breakfast': return Icons.free_breakfast;
      default: return Icons.check_circle_outline;
    }
  }

  @override
  // بيرسم الشيبات بالمظهر بتاعها
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon(), size: 12, color: AppTheme.primary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ده عنوان قسم ومعاه اختيارياً زرار أكشن
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  // بيرسم العنوان والزرار لو موجود
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

// ده كارت الرحلة اللي بيظهر في النتائج
class FlightCard extends StatelessWidget {
  final Flight flight;
  final VoidCallback onTap;

  const FlightCard({super.key, required this.flight, required this.onTap});

  @override
  // بيرسم كارت الرحلة
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(flight.airlineCode, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(flight.airline, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary)),
                      Text(flight.flightClass, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$${flight.price.toInt()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                    const Text('per person', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(flight.departureTime, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                    Text(flight.fromCode, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                    Text(flight.from, style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(flight.duration, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const SizedBox(width: 8),
                          Expanded(child: Container(height: 1, color: AppTheme.divider)),
                          Container(
                            width: 7, height: 7,
                            decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                          ),
                          Expanded(child: Container(height: 1, color: AppTheme.divider)),
                          const Icon(Icons.flight_takeoff, size: 16, color: AppTheme.primary),
                          const SizedBox(width: 8),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        flight.stops == 0 ? 'Nonstop' : '${flight.stops} stop',
                        style: TextStyle(
                          fontSize: 11,
                          color: flight.stops == 0 ? AppTheme.success : AppTheme.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(flight.arrivalTime, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                    Text(flight.toCode, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                    Text(flight.to, style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ده بادج حالة الحجز
class BookingStatusBadge extends StatelessWidget {
  final BookingStatus status;
  const BookingStatusBadge({super.key, required this.status});

  @override
  // بيرسم بادج الحالة باللون المناسب
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case BookingStatus.confirmed:
        color = AppTheme.success; label = 'Confirmed'; break;
      case BookingStatus.pending:
        color = AppTheme.warning; label = 'Pending'; break;
      case BookingStatus.cancelled:
        color = AppTheme.wishlistColor; label = 'Cancelled'; break;
      case BookingStatus.completed:
        color = AppTheme.textSecondary; label = 'Completed'; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

// ده شريط بحث بسيط ينفع كـ input أو زرار
class TravelSearchBar extends StatelessWidget {
  final String hint;
  final IconData icon;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final bool readOnly;

  const TravelSearchBar({
    super.key,
    required this.hint,
    this.icon = Icons.search,
    this.controller,
    this.onTap,
    this.readOnly = false,
  });

  @override
  // بيرسم شريط البحث
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: readOnly
                  ? Text(hint, style: const TextStyle(color: AppTheme.textLight, fontSize: 14))
                  : TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: hint,
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                    ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Search', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}
