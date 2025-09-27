import 'package:flutter/services.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../AIResponse/BatchInfoResponse.dart';
import '../ReturnProduct/ReturnProductList.dart';
import '../Stock/ProductList.dart';
import '../search/customerModel.dart';
import '../../constant/all.dart';
import 'utilScanner/CornerPainter.dart';
import 'utilScanner/ScanLinePainter.dart';
import 'utilScanner/ScannerOverlayPainter.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class QuikScanPageOld extends StatefulWidget {
  final CartTypeSelection? cartTypeSelection;
  final CustomerModel? selectedCustomer;

  const QuikScanPageOld({
    super.key,
    this.cartTypeSelection,
    this.selectedCustomer,
  });

  @override
  State<QuikScanPageOld> createState() => _QuikScanPageOldState();
}

class _QuikScanPageOldState extends State<QuikScanPageOld>
    with SingleTickerProviderStateMixin {
  bool showButtons = true;

  String? scannedCode;
  bool isScanned = false;
  bool isScanning = false;

  late AnimationController _animationController;
  late Animation<double> _animation;
  // final AudioPlayer _player = AudioPlayer(); // Temporarily disabled
  bool isloader=false;

  Timer? _scanTimer;
  List<InvoiceItem> searchResults = [];

  final MobileScannerController _scannerController =
  MobileScannerController(facing: CameraFacing.back);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0, end: 250).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    // _player.setAsset('assets/sound/scanner.mpeg'); // Temporarily disabled
  }

  @override
  void dispose() {
    _animationController.dispose();
    // _player.dispose(); // Temporarily disabled
    _scanTimer?.cancel();
    _scannerController.dispose();
    super.dispose();
  }

  void startScanning() {
    if (isScanning) return;

    setState(() {
      isScanning = true;
      isScanned = false;
      showButtons = false;
    });

    _animationController.repeat();

    _scanTimer?.cancel();
    _scanTimer = Timer(const Duration(seconds: 3), () {
      stopScanning();
      if (!isScanned && mounted) {
        setState(() => showButtons = true);
      }
    });
  }

  void stopScanning() {
    if (!isScanning) return;
    setState(() => isScanning = false);
    _animationController.stop();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!isScanning || isScanned) return;

    final code = capture.barcodes.first.rawValue;
    if (code != null && code.isNotEmpty) {
      setState(() {
        scannedCode = code;
        isScanned = true;
      });

      _scanTimer?.cancel();
      stopScanning();

      addToCart(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocListener<ApiCubit, ApiState>(
        listener: (context, state) {
          if (state is BarcodeScanLoaded && state.source=='scan') {
            searchResults = state.list;
            if (searchResults.isNotEmpty && searchResults.length==1) {
              context.read<CartCubit>().addToCart(searchResults.first, 1, type: CartType.main);
            } else if (searchResults.isNotEmpty && searchResults.length>1) {
              AppRoutes.navigateTo(context, ProductListPage(flag: 4,searchResults:searchResults));
            }
            setState(() {
              isloader=false;
              showButtons = true;
            });
          } else if (state is BarcodeScanError) {
            AppUtils.showSnackBar(context,state.error);
            setState(() {
              isloader=false;
              showButtons = true;
            });
          }
        },
        child: SafeArea(
          child: Stack(
            children: [
              /// Camera always fullscreen
              MobileScanner(
                controller: _scannerController,
                fit: BoxFit.cover,
                onDetect: _onDetect,
              ),

              /// Scanner overlay (square cutout)
              Positioned.fill(
                child: CustomPaint(
                  painter: ScannerOverlayPainter(cutOutSize: 300),
                ),
              ),

              /// Red scanline + corners
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
                      if (isScanning)
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (_, __) => CustomPaint(
                            size: const Size(250, 250),
                            painter: ScanLinePainter(
                                yPos: _animation.value
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Center(
                  child: isloader?CircularProgressIndicator(color: Colors.white,):SizedBox()
              ),

              /// Back button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              /// Cart Icon with Badge (Top-Right, updates via CartCubit)
              if(widget.cartTypeSelection==null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: BlocBuilder<CartCubit, CartState>(
                    builder: (context, state) {
                      final cartItems = state.cartItems ?? [];
                      if(cartItems.isNotEmpty) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _buildActionButton(
                              icon: Icons.shopping_cart,
                              text: "Go to Cart",
                              onTap: () {
                                Navigator.pop(context, {"goToCart": true});
                              },
                            ),

                            /// Show badge only if cart has items
                            if (cartItems.isNotEmpty)
                              Positioned(
                                right: -4,
                                top: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Text(
                                    '${cartItems.length}', // cart item count
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      }else{
                        return SizedBox();
                      }
                    },
                  ),
                ),

            ],
          ),
        ),
      ),

      /// Floating buttons only if not scanning
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: showButtons
          ? Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
              icon: Icons.add,
              text: "Add Manually",
              onTap: () {
                if (widget.cartTypeSelection != null) {
                  AddManualClickReturn();
                } else {
                  AddManualClick();
                }
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.qr_code_scanner,
              text: "Scan Barcode",
              onTap: startScanning, // ✅ directly start scanning
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.format_list_numbered,
              text: "Scan Batch No.",
              onTap: () async {
                Scan_BatchNo_MedicineName(flag:1);
              },
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.medical_information,
              text: "Scan Medicine Name",
              onTap: () async {
                Scan_BatchNo_MedicineName(flag:2);
              },
            ),
          ],
        ),
      )
          : null,
    );
  }
  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.kPrimary, AppColors.secondaryColor],
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: width * 0.05),
            const SizedBox(width: 8),
            MyTextfield.textStyle_w600(
              text,
              width * 0.045,
              Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> AddManualClickReturn() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReturnProductListPage(
          cartTypeSelection: widget.cartTypeSelection,
          selectedCustomer: widget.selectedCustomer,
        ),
      ),
    );
    if (result != null) {
      Navigator.pop(context, result);
    }
  }

  Future<void> AddManualClick() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductListPage(flag: 4)),
    );
    if (result != null && result is Map && result["goToCart"] == true) {
      Navigator.pop(context, {"goToCart": true});
    }
  }
  Future<void> addToCart(String code) async {
    if (code.isNotEmpty) {
      // _player.seek(Duration.zero);
      // _player.play(); // Temporarily disabled

      if (widget.cartTypeSelection != null) {
        // Returning back with scanned code for return flow
        Navigator.pop(context, {'code': code});
        return;
      }

      // Normal sale flow
      final userId = await SessionManager.getParentingId();
      setState(() {
        isloader = true;
        showButtons = false;
      });
      await context.read<ApiCubit>().BarcodeScan(
        code: code,
        storeId: userId!,
      );
    } else {
      AppUtils.showSnackBar(context, "❌ No information found");
    }
  }

  Future<void> Scan_BatchNo_MedicineName({required int flag}) async {
    dynamic scannedDocuments;
    try {
      scannedDocuments = await FlutterDocScanner().getScannedDocumentAsImages(page: 1);
      print("🔍 Raw scannedDocuments = $scannedDocuments");
    } on PlatformException {
      AppUtils.showSnackBar(context, "Failed to scan document.");
      return;
    }

    if (scannedDocuments == null || !(scannedDocuments is Map) || !scannedDocuments.containsKey("Uri")) {
      AppUtils.showSnackBar(context, "No document scanned.");
      return;
    }

    var page = scannedDocuments["Uri"]; // ← This is likely a String or Page object, NOT a List

    print("✅ Page runtimeType: ${page.runtimeType}");
    print("✅ Page value: $page");

    String? rawUri;

    // CASE 1: It's already a String like "Page{imageUri=...}"
    if (page is String) {
      final regex = RegExp(r'Page\{imageUri=([^}]+\.jpg)\}');
      final match = regex.firstMatch(page);
      rawUri = match?.group(1);
    }
    // CASE 2: It's an object with .imageUri property
    else if (page is dynamic && page.imageUri != null) {
      rawUri = page.imageUri as String?;
    }
    // CASE 3: It's a Map
    else if (page is Map<String, dynamic> && page.containsKey('imageUri')) {
      rawUri = page['imageUri'] as String?;
    }

    if (rawUri == null || rawUri.isEmpty) {
      AppUtils.showSnackBar(context, "Could not extract image path.");
      print("⚠️ Failed to extract imageUri from: $page");
      return;
    }

    print("✅ Extracted rawUri: $rawUri");

    // Convert file:// URI to local path
    String localPath = rawUri.startsWith('file://') ? rawUri.replaceFirst('file://', '') : rawUri;

    final file = File(localPath);
    if (!await file.exists()) {
      AppUtils.showSnackBar(context, "Image file not found.");
      print("⚠️ File does not exist at: $localPath");
      return;
    }

    setState(() {
      isloader=true;
      showButtons=false;
    });

    try {
      final inputImage = InputImage.fromFile(file);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await textRecognizer.processImage(inputImage);
      textRecognizer.close();

      if (recognizedText.text.isEmpty) {
        AppUtils.showSnackBar(context, "No text recognized.");
        return;
      }

      print("📄 Recognized Text: ${recognizedText.text}");
      await scanBatchNumberAIText(recognizedText.text,flag);

    } catch (e) {
      print("❌ OCR Error: $e");
      AppUtils.showSnackBar(context, "Text recognition failed: $e");
    } finally {
      setState(() => isloader = false);
    }
  }


  Future<void> scanBatchNumberAIText(String text, int flag) async {
    try {
      final formData = FormData.fromMap({
        'fullText': text,
        'requirement':
        'Extract batch number and medicine name if present. Keep it structured.',
        'type': '1',
      });

      final dio = Dio();
      final response = await dio.post(
        'https://pixi.dexcy.in/api/process',
        data: formData,
      );

      if (response.statusCode == 200) {
        final json = response.data;
        print('📄 API Raw: ${json.toString()}');

        if (json['data'] is List && json['data'].isNotEmpty) {
          final parsed =
          json['data'].map((e) => MedicineData.fromJson(e)).toList();

          final MedicineData first = parsed.first;
          if(flag==1) {
            if (first.batch != null) {
              print("✅ API AI batch number found: ${first.name}");
              await addToCart(first.batch ?? '');
            } else {
              AppUtils.showSnackBar(context, "❌ No Batch no. found");
            }
          }
          if(flag==2) {
            if (first.name != null) {
              print("✅ API AI name found: ${first.name}");
              await addToCart(first.name ?? '');
            } else {
              AppUtils.showSnackBar(context, "❌ No Medicine name found");
            }
          }
          setState(() {
            isloader=false;
            showButtons=true;
          });
        }
      } else {
        print("❌ API call failed: ${response.statusMessage}");
      }
    } catch (e) {
      print("❌ Error in scanBatchNumberAI: $e");
    }
    return null;
  }
}
