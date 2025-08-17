
import '../../constant/all.dart';

class ScannerOverlayPainter extends CustomPainter {
  final double cutOutSize;

  ScannerOverlayPainter({required this.cutOutSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final cutOutOffset = Offset(
      (size.width - cutOutSize) / 2,
      (size.height - cutOutSize) / 2,
    );

    final cutOutRect = Rect.fromLTWH(
      cutOutOffset.dx,
      cutOutOffset.dy,
      cutOutSize,
      cutOutSize,
    );

    // Draw dark overlay with transparent center
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(RRect.fromRectXY(cutOutRect, 16, 16)),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}