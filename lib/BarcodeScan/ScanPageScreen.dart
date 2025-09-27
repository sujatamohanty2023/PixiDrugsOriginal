import 'package:flutter/services.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../AIResponse/BatchInfoResponse.dart';
import '../ReturnProduct/ReturnCustomerCart.dart';
import '../ReturnProduct/ReturnProductList.dart';
import '../ReturnProduct/ReturnStockiestCart.dart';
import '../Stock/ProductList.dart';
import '../search/customerModel.dart';
import '../../constant/all.dart';
import 'utilScanner/CornerPainter.dart';
import 'utilScanner/ScanLinePainter.dart';
import 'utilScanner/ScannerOverlayPainter.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class QuikScanPage extends StatefulWidget {
  final CartTypeSelection? cartTypeSelection;
  final CustomerModel? selectedCustomer;

  const QuikScanPage({
    super.key,
    this.cartTypeSelection,
    this.selectedCustomer,
  });

  @override
  State<QuikScanPage> createState() => _QuikScanPageState();
}

class _QuikScanPageState extends State<QuikScanPage>
    with SingleTickerProviderStateMixin {
  bool showButtons = true;

  String? scannedCode;
  bool isScanned = false;
  bool isScanning = false;

  late AnimationController _animationController;
  late Animation<double> _animation;
   final AudioPlayer _player = AudioPlayer();
  bool isloader = false;

  Timer? _scanTimer;
  List<InvoiceItem> searchResults = [];

  final MobileScannerController _scannerController = MobileScannerController(
    facing: CameraFacing.back,
  );

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

     _player.setAsset('assets/sound/scanner.mpeg');
  }

  @override
  void dispose() {
    _animationController.dispose();
     _player.dispose();
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
        listener: (context, state) async {
          if (state is BarcodeScanLoaded && state.source == 'scan') {
            searchResults = state.list;
            if (widget.cartTypeSelection == null) {
              if (searchResults.isNotEmpty && searchResults.length == 1) {
                context.read<CartCubit>().addToCart(
                  searchResults.first,
                  1,
                  type: CartType.main,
                );
              } else if (searchResults.isNotEmpty && searchResults.length > 1) {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductListPage(flag: 4, searchResults: searchResults)),
                );
                if (result != null && result is Map && result["goToCart"] == true) {
                  Navigator.pop(context, {"goToCart": true});
                }
              }
            } else if (widget.cartTypeSelection == CartTypeSelection.StockiestReturn) {
              if (searchResults.isNotEmpty && searchResults.length == 1) {
                final cartCubit = context.read<CartCubit>();
                final scannedItem = searchResults.first;

                if(cartCubit.state.cartItems.isEmpty) {
                  var selectedSeller = CustomerModel(
                    id: scannedItem.sellerId ?? 0,
                    name: scannedItem.sellerName ?? '',
                    phone: scannedItem.sellerPhone ?? '',
                    address: '',
                  );
                  cartCubit.addToCart(scannedItem, 1, type: CartType.main);
                  AppRoutes.navigateTo(
                    context,
                    ReturnStockiestCart(selectedCustomer: selectedSeller),
                  );
                  Navigator.pop(context);
                }else{
                  // Check seller matches
                  if (widget.selectedCustomer !=null && widget.selectedCustomer?.id != scannedItem.sellerId) {
                    AppUtils.showSnackBar(context, 'Different Seller Item');
                    return;
                  }
                  bool alreadyInCart = cartCubit.state.cartItems.any(
                        (i) => i.id == scannedItem.id && i.batch == scannedItem.batch,
                  );

                  if (!alreadyInCart && state.source == 'scan') {
                    cartCubit.addToCart(scannedItem, 1, type: CartType.main);
                  } else if (alreadyInCart && state.source == 'scan') {
                    cartCubit.incrementQuantity(
                      scannedItem.id!,
                      type: CartType.main,
                    );
                  }
                }
              } else {
                 final result = await Navigator.push(
                   context,
                   MaterialPageRoute(
                     builder:
                         (context) => ReturnProductListPage(
                       cartTypeSelection: widget.cartTypeSelection,
                       selectedCustomer: widget.selectedCustomer,
                             searchResults:searchResults
                     ),
                   ),
                 );
                 if (result != null && result['goToReturnCart'] == true ){
                    if(widget.selectedCustomer!=null ) {
                      Navigator.pop(context);
                    }else{
                      ReturnCartCall(widget.selectedCustomer!);
                    }
                }
              }
            }
            setState(() {
              isloader = false;
              showButtons = true;
            });
          } else if (state is BarcodeScanError) {
            AppUtils.showSnackBar(context, state.error);
            setState(() {
              isloader = false;
              showButtons = true;
            });
          } else if (state is CustomerBarcodeScanLoaded && state.source == 'scan') {
            final cartCubit = context.read<CartCubit>();
            if (state.list.isNotEmpty) {
              if (cartCubit.state.cartItems.isEmpty && widget.selectedCustomer == null) {
                AppRoutes.navigateTo(
                  context,
                  ReturnCustomerCart(searchResults:state.list),
                );
              } else if(cartCubit.state.cartItems.isNotEmpty && state.list.length == 1){
                final cartCubit = context.read<CartCubit>();
                final scannedItem = state.list.first;
                // If seller is not set, initialize it first
                var selectedCustomer = CustomerModel(
                  id: scannedItem.customerId ?? 0,
                  name: scannedItem.customerName ?? '',
                  phone: scannedItem.customerPhone ?? '',
                  address: '',
                );

                // Check if item already in cart
                bool alreadyInCart = cartCubit.state.cartItems.any(
                      (i) => i.id == scannedItem.id && i.batch == scannedItem.batch,
                );

                if (!alreadyInCart && state.source == 'scan') {
                  cartCubit.addToCart(scannedItem, 1, type: CartType.main,isCustomerReturn:true);
                } else if (alreadyInCart && state.source == 'scan') {
                  cartCubit.incrementQuantity(
                    scannedItem.id!,
                    type: CartType.main,
                  );
                }
                AppRoutes.navigateTo(
                  context,
                  ReturnStockiestCart(selectedCustomer: selectedCustomer),
                );
              }else if(cartCubit.state.cartItems.isNotEmpty && state.list.length>1){
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ReturnProductListPage(
                        cartTypeSelection: widget.cartTypeSelection,
                        selectedCustomer: widget.selectedCustomer,
                        searchResults:searchResults
                    ),
                  ),
                );
                if (result != null && result['goToReturnCart'] == true ){
                  if(widget.selectedCustomer!=null ) {
                    Navigator.pop(context);
                  }else{
                    ReturnCartCall(widget.selectedCustomer!);
                  }
                }
              }
            }
          } else if (state is CustomerBarcodeScanError) {
            AppUtils.showSnackBar(context, state.error);
              setState(() {
                    isloader = false;
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
                          builder:
                              (_, __) => CustomPaint(
                                size: const Size(250, 250),
                                painter: ScanLinePainter(
                                  yPos: _animation.value,
                                ),
                              ),
                        ),
                    ],
                  ),
                ),
              ),
              Center(
                child:
                    isloader
                        ? CircularProgressIndicator(color: Colors.white)
                        : SizedBox(),
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
              if (widget.cartTypeSelection == null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: BlocBuilder<CartCubit, CartState>(
                    builder: (context, state) {
                      final cartItems = state.cartItems ?? [];
                      if (cartItems.isNotEmpty) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _buildActionButton(
                              icon: Icons.shopping_cart,
                              text: "Go to Cart",
                              onTap: () {
                                if(widget.cartTypeSelection==null) {
                                  Navigator.pop(context, {"goToCart": true});
                                }else{
                                  ReturnCartCall(widget.selectedCustomer!);
                                }
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
                      } else {
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
      floatingActionButton:
          showButtons
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
                        Scan_BatchNo_MedicineName(flag: 1);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      icon: Icons.medical_information,
                      text: "Scan Medicine Name",
                      onTap: () async {
                        Scan_BatchNo_MedicineName(flag: 2);
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
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: width * 0.05),
            const SizedBox(width: 8),
            MyTextfield.textStyle_w600(text, width * 0.045, Colors.white),
          ],
        ),
      ),
    );
  }
  Future<void> AddManualClickReturn() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ReturnProductListPage(
              cartTypeSelection: widget.cartTypeSelection,
              selectedCustomer: widget.selectedCustomer,
            ),
      ),
    );

    if (result != null && result['selectedCustomer']!=null) {
      CustomerModel? selectedCustomer = result['selectedCustomer'];

      if (selectedCustomer != null) {
        ReturnCartCall(selectedCustomer);
      }
    }else if (result != null && result['goToReturnCart'] == true ){
        if(widget.selectedCustomer!=null ) {
          Navigator.pop(context);
        }else{
          ReturnCartCall(widget.selectedCustomer!);
        }
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
    scannedCode=code;
    if (code.isNotEmpty) {
       _player.seek(Duration.zero);
       _player.play();

      // Normal sale flow
      final userId = await SessionManager.getParentingId();
      setState(() {
        isloader = true;
        showButtons = false;
      });
      if (widget.cartTypeSelection == CartTypeSelection.CustomerReturn) {
        context.read<ApiCubit>().customerbarcode(
          code: code,
          storeId: userId!,
          customer_id: '',
        );
      } else if (widget.cartTypeSelection ==
              CartTypeSelection.StockiestReturn ||
          widget.cartTypeSelection == null) {
        await context.read<ApiCubit>().BarcodeScan(
          code: code,
          storeId: userId!,
        );
      }
    } else {
      AppUtils.showSnackBar(context, "❌ No information found");
    }
  }
  String _normalizeUri(String rawUri) {
    if (rawUri.startsWith('file://')) {
      return rawUri.replaceFirst('file://', '');
    }
    return rawUri;
  }

  Future<void> Scan_BatchNo_MedicineName({required int flag}) async {
    dynamic scannedDocuments;
    try {
      scannedDocuments = await FlutterDocScanner().getScannedDocumentAsImages(page: 1);
      print("🔍 Raw scannedDocuments = $scannedDocuments");
    } on PlatformException {
      AppUtils.showSnackBar(context, "Failed to get scanned documents.");
      return;
    }

    if (scannedDocuments == null ||
        scannedDocuments is! Map ||
        !scannedDocuments.containsKey("Uri")) {
      AppUtils.showSnackBar(context, "No document scanned.");
      return;
    }

    final pagesString = scannedDocuments["Uri"] as String;
    print("🧾 pagesString: $pagesString");

    final List<File> scannedFiles = [];

    final regex = RegExp(r'imageUri=([^}\s]+)');
    final matches = regex.allMatches(pagesString);

    for (final match in matches) {
      final uri = match.group(1);
      if (uri != null) {
        print("🔗 Extracted URI from string: $uri");
        scannedFiles.add(File(_normalizeUri(uri)));
      }
    }

    if (scannedFiles.isEmpty) {
      AppUtils.showSnackBar(context, "Could not extract any image paths.");
      return;
    }

    setState(() {
      isloader = true;
      showButtons = false;
    });

    try {
      final inputImage = InputImage.fromFile(scannedFiles.first);
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final recognizedText = await textRecognizer.processImage(inputImage);
      textRecognizer.close();

      if (recognizedText.text.isEmpty) {
        AppUtils.showSnackBar(context, "No text recognized.");
        return;
      }

      print("📄 Recognized Text: ${recognizedText.text}");
      await scanBatchNumberAIText(recognizedText.text, flag);
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
          if (flag == 1) {
            if (first.batch != null) {
              print("✅ API AI batch number found: ${first.name}");
              await addToCart(first.batch ?? '');
            } else {
              AppUtils.showSnackBar(context, "❌ No Batch no. found");
            }
          }
          if (flag == 2) {
            if (first.name != null) {
              print("✅ API AI name found: ${first.name}");
              await addToCart(first.name ?? '');
            } else {
              AppUtils.showSnackBar(context, "❌ No Medicine name found");
            }
          }
          setState(() {
            isloader = false;
            showButtons = true;
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

  void ReturnCartCall(CustomerModel selectedCustomer) {
    if (widget.cartTypeSelection == CartTypeSelection.StockiestReturn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReturnStockiestCart(selectedCustomer: selectedCustomer),
        ),
      );
    } else if (widget.cartTypeSelection == CartTypeSelection.CustomerReturn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReturnCustomerCart(selectedCustomer: selectedCustomer),
        ),
      );
    }
  }
}
