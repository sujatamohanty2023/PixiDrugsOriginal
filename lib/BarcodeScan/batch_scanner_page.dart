import 'package:PixiDrugs/BarcodeScan/utilScanner/CornerPainter.dart';
import 'package:PixiDrugs/BarcodeScan/utilScanner/ScanLinePainter.dart';
import 'package:PixiDrugs/BarcodeScan/utilScanner/ScannerOverlayPainter.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:just_audio/just_audio.dart';
import '../constant/all.dart';

class BatchScannerPage extends StatefulWidget {
  const BatchScannerPage({super.key});

  @override
  State<BatchScannerPage> createState() => _BatchScannerPageState();
}

class _BatchScannerPageState extends State<BatchScannerPage>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isBusy = false;
  bool _found = false;
  bool _showedManualEntry = false;
  String? scannedText;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final AudioPlayer _player = AudioPlayer();
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 250).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
    _player.setAsset('assets/sound/scanner.mpeg');
    _startTimeout();
  }

  void _startTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 5), () {
      if (!_found && !_showedManualEntry) _showManualEntryBottomSheet();
    });
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
            (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();
      _cameraController!.startImageStream(_processCameraImage);

      if (mounted) setState(() {});
    } catch (e) {
      print('Camera initialization error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize camera: $e')),
        );
      }
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isBusy || _found) return;
    _isBusy = true;

    try {
      final inputImage = _convertCameraImage(
          image,
          _cameraController!.description.sensorOrientation
      );

      if (inputImage == null) {
        print('Image format not supported');
        return;
      }

      await scanBatchNumber(inputImage);
    } catch (e) {
      print("Batch OCR error: $e");
    } finally {
      _isBusy = false;
    }
  }

  InputImage? _convertCameraImage(CameraImage image, int rotation) {
    try {
      // Handle YUV_420_888 format
      if (image.format.group == ImageFormatGroup.yuv420) {
        final nv21 = _convertYUV420ToNV21(image);
        return InputImage.fromBytes(
          bytes: nv21,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: InputImageRotationValue.fromRawValue(rotation) ?? InputImageRotation.rotation0deg,
            format: InputImageFormat.nv21,
            bytesPerRow: image.width,
          ),
        );
      }
      // Handle BGRA8888 format
      else if (image.format.group == ImageFormatGroup.bgra8888) {
        final plane = image.planes.first;
        return InputImage.fromBytes(
          bytes: plane.bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: InputImageRotationValue.fromRawValue(rotation) ?? InputImageRotation.rotation0deg,
            format: InputImageFormat.bgra8888,
            bytesPerRow: plane.bytesPerRow,
          ),
        );
      }
      // Unsupported format
      else {
        print('Unsupported image format: ${image.format.group}');
        return null;
      }
    } catch (e) {
      print('Error converting camera image: $e');
      return null;
    }
  }

  Uint8List _convertYUV420ToNV21(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final yPlane = image.planes[0].bytes;
    final uPlane = image.planes[1].bytes;
    final vPlane = image.planes[2].bytes;

    final nv21 = Uint8List(width * height + (width * height ~/ 2));

    // Copy Y plane
    for (int i = 0; i < width * height; i++) {
      nv21[i] = yPlane[i];
    }

    // Interleave U and V planes
    int uvIndex = width * height;
    for (int row = 0; row < height ~/ 2; row++) {
      for (int col = 0; col < width ~/ 2; col++) {
        final uIndex = row * image.planes[1].bytesPerRow + col;
        final vIndex = row * image.planes[2].bytesPerRow + col;
        nv21[uvIndex++] = vPlane[vIndex];
        nv21[uvIndex++] = uPlane[uIndex];
      }
    }

    return nv21;
  }

  Future<void> scanBatchNumber(InputImage inputImage) async {
    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      final List<String> allLines = [];

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final text = line.text.trim();
          allLines.add(text);
          print('Scanned: $text');
        }
      }

      String? batchNo;

      // Match lines like: "Batch No", "Lot No", "B. No", etc.
      final labelPattern = RegExp(
        r'\b(?:batch\s*no|b[\.\s]*no|lot\s*no|lot)[\s:\-]*',
        caseSensitive: false,
      );

      // Match batch-like codes (alphanumeric, at least 4 chars, may include / - .)
      final batchFormatPattern = RegExp(
        r'^[A-Z]{0,3}[-/.\s]?[A-Z0-9]{3,}[A-Z0-9]$',
        caseSensitive: false,
      );

      // Skip words like MRP, price, expiry, date, etc.
      final ignoreWords = RegExp(
        r'(exp|expiry|mfg|mrp|max(?:imum)?|price|date|inclusive|jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)',
        caseSensitive: false,
      );

      // Exclude values that look like dates (e.g. 05/2026, 01-25, etc.)
      final datePattern = RegExp(
        r'^(0[1-9]|1[0-2]|[1-9])[\/\-\.](\d{2}|\d{4})$|^(\d{2}|\d{4})[\/\-\.](0[1-9]|1[0-2]|[1-9])$',
        caseSensitive: false,
      );

      for (int i = 0; i < allLines.length; i++) {
        final line = allLines[i];

        final labelMatch = labelPattern.firstMatch(line);
        if (labelMatch != null) {
          final afterLabel = line.substring(labelMatch.end).trim();

          if (afterLabel.isNotEmpty) {
            if (datePattern.hasMatch(afterLabel)) {
              print("❌ Skipped date-like value: $afterLabel");
              continue;
            }

            if (batchFormatPattern.hasMatch(afterLabel) && !ignoreWords.hasMatch(afterLabel)) {
              batchNo = afterLabel;
              break;
            }
          }

          // Look ahead for 2 lines to find value
          for (int j = 1; j <= 2 && i + j < allLines.length; j++) {
            final nextLine = allLines[i + j].trim();

            if (datePattern.hasMatch(nextLine)) {
              print("❌ Skipped date-like value: $nextLine");
              continue;
            }

            if (batchFormatPattern.hasMatch(nextLine) && !ignoreWords.hasMatch(nextLine)) {
              batchNo = nextLine;
              break;
            }
          }
        }

        if (batchNo != null) break;
      }

      if (batchNo != null && batchNo.isNotEmpty) {
        print("✅ Batch number found: $batchNo");
        _found = true;
        scannedText = batchNo;
        _timeoutTimer?.cancel();
        await _player.seek(Duration.zero);
        await _player.play();
        await _cameraController?.stopImageStream();

        if (mounted) {
          Navigator.pop(context, batchNo);
        }
      } else if (!_showedManualEntry) {
        _startTimeout(); // Try again
      }
    } catch (e) {
      print("❌ Error in scanBatchNumber: $e");
      if (!_showedManualEntry) {
        _showManualEntryBottomSheet();
      }
    }
  }


  void _showManualEntryBottomSheet() {
    if (!_found && mounted && !_showedManualEntry) {
      print("Showing manual entry dialog");
      _showedManualEntry = true;
      _timeoutTimer?.cancel();
      showDialog(
        context: context,
        builder: (_) => EditValueDialog(
          title: 'Batch No.',
          initialValue: '',
          type: 'batch',
        ),
      );
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _player.dispose();
    _timeoutTimer?.cancel();
    textRecognizer.close();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CameraPreview(_cameraController!),
          ),
          // Overlay
          Positioned.fill(
            child: CustomPaint(
              painter: ScannerOverlayPainter(cutOutSize: 300),
            ),
          ),
          // Scanner frame with animation
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