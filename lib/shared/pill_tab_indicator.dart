import 'package:flutter/material.dart';

class PillTabIndicator extends Decoration {
  final Color color;
  final double radius;
  @override
  final EdgeInsetsGeometry padding;

  const PillTabIndicator({
    required this.color,
    this.radius = 12,
    this.padding = const EdgeInsets.all(6),
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _PillPainter(color, radius, padding);
  }
}

class _PillPainter extends BoxPainter {
  final Color color;
  final double radius;
  final EdgeInsetsGeometry padding;
  _PillPainter(this.color, this.radius, this.padding);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration config) {
    final rect = offset & config.size!;
    final insets = padding.resolve(TextDirection.ltr);
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        rect.left + insets.left,
        rect.top + insets.top,
        rect.width - insets.horizontal,
        rect.height - insets.vertical,
      ),
      Radius.circular(radius),
    );
    final paint = Paint()..color = color;
    canvas.drawRRect(r, paint);
  }
}

