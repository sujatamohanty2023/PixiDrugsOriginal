import 'package:PixiDrugs/BarcodeScan/utilScanner/CornerPainter.dart';
import 'package:PixiDrugs/BarcodeScan/utilScanner/ScanLinePainter.dart';
import 'package:PixiDrugs/BarcodeScan/utilScanner/ScannerOverlayPainter.dart';
import 'package:PixiDrugs/constant/all.dart';
import 'package:http_parser/http_parser.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';

import '../AIResponse/BatchInfoResponse.dart';
import '../Stock/ProductList.dart';
import 'barcode_screen_page.dart';
import 'batch_scanner_page.dart';

class QuikScanPage extends StatefulWidget {
  QuikScanPage({super.key});

  @override
  State<QuikScanPage> createState() => _QuikScanPageState();
}

class _QuikScanPageState extends State<QuikScanPage> with SingleTickerProviderStateMixin {
  int selectedTab = 0; // 0 =Barcode, 1 =  Batch Info
  final player = AudioPlayer();

  bool isLoading = false;
  bool isProcessing = false;
  String? lastScanned; // remember last scanned value

  late AnimationController _animationController;
  late Animation<double> _animation;
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    returnImage: true,  // Enable image capture
  );

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

    player.setAsset('assets/sound/scanner.mpeg');
  }
  @override
  void dispose() {
    _animationController.dispose();
    player.dispose();
    super.dispose();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isLoading = false;
  }
  /// ✅ Play beep
  Future<void> playBeep() async {
    try {
      await player.play();
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  /// ✅ Manual scan
  Future<void> onScanButtonPressed() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.6),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: const Color(0xFF2E3A59),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  MyTextfield.textStyle_w600(
                    "ScanPage",
                    SizeConfig.screenWidth! * 0.040,
                    Colors.white,
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              color: const Color(0xFF2E3A59),
              child: Row(
                children: [
                  _buildTabButton("Scan Barcode", 0),
                  _buildTabButton("Scan Batch No.", 1),
                ],
              ),
            ),

            // === Scanner ===
            Expanded(
              child: selectedTab==0?BarcodeScannerPage():BatchScannerPage(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondaryColor,
        child: const Icon(Icons.edit, color: Colors.white),
        onPressed: (){
          AppRoutes.navigateTo(context, ProductListPage(flag: 4));
        },
      ),
    );
  }
/*Widget BarcodeScanWidget(){
  return Stack(
    children: [
      MobileScanner(
        controller:controller,
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

      Positioned(
        bottom: 40,
        left: 0,
        right: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: isLoading ? null : onScanButtonPressed,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: AppColors.secondaryColor,
                  shape: BoxShape.circle,
                ),
                child: isLoading
                    ? const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
                    : const Icon(Icons.qr_code_scanner, size: 35, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            MyTextfield.textStyle_w600(
              selectedTab == 0
                  ? (isLoading ? "Scanning..." : "Tap to Scan Barcode")
                  : (isLoading ? "Scanning..." : "Tap to Scan Batch Info"),
              SizeConfig.screenWidth! * 0.032,
              Colors.white70,
            ),
          ],
        ),
      )

    ],
  );
}

  void _onDetect(BarcodeCapture capture) async {
    if (isProcessing) return;

    isProcessing = true;

    final code = capture.barcodes.firstOrNull?.rawValue;
    final hasImage = capture.image != null;

    if (selectedTab == 0) {
      // Barcode scan
      if (code == null || code == lastScanned) {
        isProcessing = false;
        return;
      }

      setState(() {
        isLoading = false;
        lastScanned = code;
      });

      controller.stop();

      await playBeep();
      if (mounted) Navigator.pop(context, code);

      controller.start();
      setState(() => isLoading = true);
      isProcessing = false;
      return;
    }*//*else {
      // Batch scan
      if (!hasImage) {
        print("⚠️ No image available for batch scanning.");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("No image captured. Please try again.")),
          );
        }
        isProcessing = false;
        return;
      }
      await ScanBatchNo(capture);
      controller.start();
      setState(() => isLoading = true);
      isProcessing = false;
    }*//*
  }

  Future<void> ScanBatchNo(BarcodeCapture capture) async {
    try {
      final imageBytes = capture.image;

      if (imageBytes == null) {
        debugPrint("⚠️ No image captured from scanner.");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No image captured. Please try again.")),
          );
        }
        return;
      }

      final imagePath = await _saveImage(imageBytes);
      debugPrint("📸 Saved scan image at: $imagePath");

      await scanBatchNumberAI(imagePath);

    } catch (e) {
      debugPrint("❌ Error capturing image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to scan batch: $e")),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<String> _saveImage(Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(path);
    await file.writeAsBytes(bytes);
    return path;
  }
  Future<void> scanBatchNumberAI(String imagePath) async {
    try {
      var multipartFile=await createMultipartFile(imagePath);
      final formData = FormData.fromMap({
        'files': multipartFile,
        'requirement': 'Analyze this document and provide a detailed summary with key insights, main points, and actionable recommendations.',
        'type': '1',
      });

      final dio = Dio();
      final response = await dio.post(
        'https://pixi.dexcy.in/api/process',
        data: formData,
      );

      if (response.statusCode == 200) {
        final json = response.data;
        print('📄 API status: ${json['status']}');
        print('📄 API data: ${json['data'].toString()}');

        final parsed =  json['data'].map((e) => MedicineData.fromJson(e)).toList();
        print('📄 API Total Items: ${parsed.length}');
        for (var medicine in parsed) {
          print('🔹 API Brand Name: ${medicine.brandName}');
          final batch = medicine.batchDetails;
          if (batch != null) {
            print('🔢 API Batch Number: ${batch.batchNumber}');
          } else {
            print('⚠️ API No batch details found.');
          }
        }
        if (parsed.isNotEmpty) {
          final batchNumber = parsed.first.batchDetails?.batchNumber;
          final medicineName = parsed.first.brandName;
          if (batchNumber != null && batchNumber.isNotEmpty) {
            setState(() {
              isLoading = true;
            });
            await playBeep();
            if (mounted) Navigator.pop(context, batchNumber);
            return;
          } else if (medicineName != null && medicineName.isNotEmpty) {
            setState(() {
              isLoading = true;
            });
            await playBeep();
            if (mounted) Navigator.pop(context, medicineName);
            return;
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No batch info found. Try again.")),
          );
        }

      }else {
        print("❌ API call failed: ${response.statusMessage}");
      }
    } catch (e) {
      print("❌ Error in scanBatchNumberAI: $e");
    }
  }
  Future<MultipartFile> createMultipartFile(String path) async {
    String extension = path.split('.').last.toLowerCase();
    MediaType contentType;

    switch (extension) {
      case 'pdf':
        contentType = MediaType('application', 'pdf');
        break;
      case 'jpg':
      case 'jpeg':
        contentType = MediaType('image', 'jpeg');
        break;
      case 'png':
        contentType = MediaType('image', 'png');
        break;
      default:
        contentType = MediaType('application', 'octet-stream');
    }

    return await MultipartFile.fromFile(
      path,
      filename: path.split('/').last,
      contentType: contentType,
    );
  }*/
  Widget _buildTabButton(String title, int index) {
    final isSelected = selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() {
          selectedTab = index;
          lastScanned = null;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.secondaryColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: MyTextfield.textStyle_w600(
            title,
            SizeConfig.screenWidth! * 0.032,
            isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

}