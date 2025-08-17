import '../../constant/all.dart';

class ScanLinePainter extends CustomPainter {
  final double yPos;
  ScanLinePainter({required this.yPos});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    const double lineHeight = 2.0;
    canvas.drawRect(
      Rect.fromLTWH(0, yPos - lineHeight / 2, size.width, lineHeight),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant ScanLinePainter oldDelegate) {
    return oldDelegate.yPos != yPos;
  }
}