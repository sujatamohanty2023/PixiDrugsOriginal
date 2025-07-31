
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:just_audio/just_audio.dart';

import '../Dialog/edit_value_dialog.dart';
import '../constant/color.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage>
    with SingleTickerProviderStateMixin {
  String? scannedCode;
  bool isScanned = false;

  late AnimationController _animationController;
  late Animation<double> _animation;
  final AudioPlayer _player = AudioPlayer();

  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 250).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    _player.setAsset('assets/sound/scanner.mpeg');

    _startTimeout(); // Start timeout timer
  }

  void _startTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 3), () {
      if (!isScanned) {
        _showManualEntryBottomSheet();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _player.dispose();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (isScanned) return;

    final code = capture.barcodes.first.rawValue;
    if (code != null && code.isNotEmpty) {
      setState(() {
        scannedCode = code;
        isScanned = true;
      });
      _timeoutTimer?.cancel(); // Cancel timeout
      _player.seek(Duration.zero);
      _player.play();
      Navigator.pop(context, scannedCode);
    }
  }
  void _showManualEntryBottomSheet() {
    showDialog(
      context: context,
      builder: (_) => EditValueDialog(
          title: 'BarCode No.',
          initialValue: '',
          type:'barcode'
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.normal,
              facing: CameraFacing.back,
            ),
            fit: BoxFit.cover,
            onDetect: _onDetect,
          ),

          // 🔲 Shadow overlay with transparent cutout
          Positioned.fill(
            child: CustomPaint(
              painter: _ScannerOverlayPainter(cutOutSize: 300),
            ),
          ),

          // 🔲 Center scanner frame (corners + animation)
          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                children: [
                  CustomPaint(
                    size: const Size(350, 350),
                    painter: _CornerPainter(color: Colors.white),
                  ),
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (_, __) => CustomPaint(
                      size: const Size(250, 250),
                      painter: _ScanLinePainter(yPos: _animation.value),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.kPrimary,
        child: const Icon(Icons.edit, color: Colors.white),
        onPressed: _showManualEntryBottomSheet,
      ),
    );
  }
}
class _ScannerOverlayPainter extends CustomPainter {
  final double cutOutSize;

  _ScannerOverlayPainter({required this.cutOutSize});

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

class _CornerPainter extends CustomPainter {
  final Color color;
  final double length;
  final double radius;
  final double strokeWidth;

  _CornerPainter({
    required this.color,
    this.length = 30.0,
    this.radius = 10.0,
    this.strokeWidth = 6.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Top-left corner
    path.moveTo(0, radius);
    path.arcToPoint(
      Offset(radius, 0),
      radius: Radius.circular(radius),
      clockwise: true,
    );
    path.lineTo(length, 0);
    path.moveTo(0, radius);
    path.lineTo(0, length);

    // Top-right corner
    path.moveTo(size.width - length, 0);
    path.lineTo(size.width - radius, 0);
    path.arcToPoint(
      Offset(size.width, radius),
      radius: Radius.circular(radius),
      clockwise: true,
    );
    path.lineTo(size.width, length);

    // Bottom-right corner
    path.moveTo(size.width, size.height - length);
    path.lineTo(size.width, size.height - radius);
    path.arcToPoint(
      Offset(size.width - radius, size.height),
      radius: Radius.circular(radius),
      clockwise: true,
    );
    path.lineTo(size.width - length, size.height);

    // Bottom-left corner
    path.moveTo(length, size.height);
    path.lineTo(radius, size.height);
    path.arcToPoint(
      Offset(0, size.height - radius),
      radius: Radius.circular(radius),
      clockwise: true,
    );
    path.lineTo(0, size.height - length);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}


class _ScanLinePainter extends CustomPainter {
  final double yPos;
  _ScanLinePainter({required this.yPos});

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
  bool shouldRepaint(covariant _ScanLinePainter oldDelegate) {
    return oldDelegate.yPos != yPos;
  }
}


