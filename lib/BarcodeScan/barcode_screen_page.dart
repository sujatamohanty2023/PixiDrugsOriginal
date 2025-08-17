
import 'dart:async';

import 'package:PixiDrugs/BarcodeScan/utilScanner/CornerPainter.dart';
import 'package:PixiDrugs/BarcodeScan/utilScanner/ScanLinePainter.dart';
import 'package:PixiDrugs/BarcodeScan/utilScanner/ScannerOverlayPainter.dart';
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
              painter: ScannerOverlayPainter(cutOutSize: 300),
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
                    painter: CornerPainter(color: Colors.white),
                  ),
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (_, __) => CustomPaint(
                      size: const Size(250, 250),
                      painter: ScanLinePainter(yPos: _animation.value),
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







