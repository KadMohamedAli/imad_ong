import 'package:flutter/material.dart';

class MapPainter extends CustomPainter {
  final Map<String, dynamic> beacons;
  final double currentX;
  final double currentY;
  final double minX;
  final double minY;

  static const double scale = 50.0;
  static const double beaconSize = 20.0;
  static const double gridSize = scale; // Grid spacing

  MapPainter({
    required this.beacons,
    required this.currentX,
    required this.currentY,
    required this.minX,
    required this.minY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Draw grid lines
    paint.color = Colors.grey.shade400;
    paint.strokeWidth = 1.0;

    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw beacons
    paint.color = Colors.blue;
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    beacons.forEach((name, beacon) {
      final offsetX = (beacon.x - minX) * scale;
      final offsetY = (beacon.y - minY) * scale;
      final pos = Offset(offsetX, offsetY);

      final rect = Rect.fromCenter(
        center: pos,
        width: beaconSize,
        height: beaconSize,
      );
      canvas.drawRect(rect, paint);

      // Draw label
      textPainter.text = TextSpan(
        text: name,
        style: const TextStyle(color: Colors.black, fontSize: 12),
      );
      textPainter.layout();
      final labelOffset = Offset(
        pos.dx - textPainter.width / 2,
        pos.dy - beaconSize / 2 - textPainter.height,
      );
      textPainter.paint(canvas, labelOffset);
    });

    // Draw current position as red circle
    paint.color = Colors.red;
    final posX = (currentX - minX) * scale;
    final posY = (currentY - minY) * scale;
    final pos = Offset(posX, posY);
    canvas.drawCircle(pos, 8.0, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
