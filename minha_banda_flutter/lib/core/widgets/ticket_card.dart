import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Signature ticket-stub card — left semicircle cutout + right dashed border.
class TicketCard extends StatelessWidget {
  const TicketCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.fromLTRB(20, 14, 14, 14),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _TicketPainter(),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class _TicketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const r = 9.0;
    final borderPaint = Paint()
      ..color = AppColors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final bgPaint = Paint()
      ..color = AppColors.stageBlack2
      ..style = PaintingStyle.fill;

    // Background path with left semicircle cutout
    final path = Path();
    path.moveTo(16, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(16, size.height);
    // left semicircle notch going outward (left side)
    path.lineTo(r, size.height);
    path.arcToPoint(
      Offset(r, 0),
      radius: const Radius.circular(r),
      clockwise: false,
    );
    path.close();

    // Rounded rect base clipping
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    );
    canvas.save();
    canvas.clipRRect(rrect);

    // Fill background
    final fullRect = Path()..addRRect(rrect);
    canvas.drawPath(fullRect, bgPaint);

    // Cut the notch circle from the left
    final notchPath = Path()
      ..addOval(Rect.fromCircle(center: Offset(0, size.height / 2), radius: r + 1));
    canvas.drawPath(notchPath, Paint()..color = AppColors.stageBlack..style = PaintingStyle.fill);

    canvas.restore();

    // Draw border (full rounded rect)
    canvas.drawRRect(rrect, borderPaint);

    // Left notch border arc
    final notchBorder = Path()
      ..addArc(
        Rect.fromCircle(center: Offset(0, size.height / 2), radius: r),
        -1.5708,
        3.1416,
      );
    canvas.drawPath(notchBorder, borderPaint);

    // Right dashed border
    final dashPaint = Paint()
      ..color = AppColors.line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const dashHeight = 6.0;
    const dashGap = 4.0;
    double y = 16;
    while (y < size.height - 16) {
      canvas.drawLine(Offset(size.width, y), Offset(size.width, y + dashHeight), dashPaint);
      y += dashHeight + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
