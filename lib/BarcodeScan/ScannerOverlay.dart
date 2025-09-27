import '../BarcodeScan/utilScanner/CornerPainter.dart';
import '../BarcodeScan/utilScanner/ScanLinePainter.dart';
import '../BarcodeScan/utilScanner/ScannerOverlayPainter.dart';

import '../../constant/all.dart';

class ScannerOverlay extends StatelessWidget {
  final Animation<double> animation;

  const ScannerOverlay({required this.animation});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          CustomPaint(
            painter: ScannerOverlayPainter(cutOutSize: 300),
          ),
          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                children: [
                  CustomPaint(
                    size: const Size(250, 250),
                    painter: CornerPainter(color: Colors.white),
                  ),
                  AnimatedBuilder(
                    animation: animation,
                    builder: (_, __) => CustomPaint(
                      size: const Size(250, 250),
                      painter: ScanLinePainter(yPos: animation.value),
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
