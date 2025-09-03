
import 'package:PixiDrugs/constant/all.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../BarcodeScan/ScanPage.dart';
import '../BarcodeScan/barcode_screen_page.dart';
import '../BarcodeScan/batch_scanner_page.dart';
import '../Stock/ProductList.dart';

class CartTab extends StatefulWidget {

  const CartTab({Key? key}) : super(key: key);

  @override
  _CartTabState createState() => _CartTabState();
}

class _CartTabState extends State<CartTab> {
  List<InvoiceItem> searchResults = [];
  String userId='';
  final ImagePicker _picker = ImagePicker();
  String extractedBatchNumber = '';
  @override
  void initState() {
    super.initState();
    _loadUserId();
  }
  Future<void> _loadUserId() async {
    final id = await SessionManager.getParentingId();
    setState(() {
      userId = id ?? '';
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ApiCubit, ApiState>(
        listener: (context, state) {
          if (state is BarcodeScanLoaded && state.source=='scan') {
            searchResults = state.list;
            if (searchResults.isNotEmpty) {
              final cartCubit = context.read<CartCubit>();
              cartCubit.addToCart(searchResults.first, 1, type: CartType.barcode);
            } else {
              AppUtils.showSnackBar(context,'No products found.');
            }
          } else if (state is BarcodeScanError) {
            AppUtils.showSnackBar(context,state.error);
          }
        },
        child: Column(
          children: [
            cartAppBar(context),
            Expanded(
              child: Builder(
                builder: (_) {
                  return _buildCartContent(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  /// Builds either cart or barcode cart content based on `widget.barcodeScan`
  Widget _buildCartContent(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return Container(
          color: AppColors.kPrimary,
            child: _buildCartOrEmpty(state.barcodeCartItems));
      },
    );
  }

  /// Shows empty page or the main CartPage
  Widget _buildCartOrEmpty(List<InvoiceItem> items) {
    return items.isEmpty ? _buildEmptyPage() : CartPage();
  }

  /// Shows a customizable empty cart page
  Widget _buildEmptyPage() {
    return Container(
        decoration: BoxDecoration(
          gradient: AppColors.myGradient,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(SizeConfig.screenWidth! * 0.07),
            topRight: Radius.circular(SizeConfig.screenWidth! * 0.07),
          ),
        ),
      child: NoItemPage(
        onTap: _scanBarcode,
        image: AppImages.empty_cart,
        tittle: "Your Cart is Empty",
        description: "Looks like you haven't added anything \nto your cart yet.",
        button_tittle:  'Scan Now',
      ),
    );
  }
  // dispose
  @override
  void dispose() {
    super.dispose();
  }
  Future<void> _QuickscanBarcode() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QuikScanPage()),
      );
      if (result.isNotEmpty) {
        context.read<ApiCubit>().BarcodeScan(code: result,storeId: userId);
      }
    } catch (e) {
      AppUtils.showSnackBar(context,'Failed to scan barcode');
    }
  }
  /// Initiates barcode scan
  Future<void> _scanBarcode() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BarcodeScannerPage()),
      );
      if (result.isNotEmpty) {
        context.read<ApiCubit>().BarcodeScan(code: result,storeId: userId);
      }
    } catch (e) {
      AppUtils.showSnackBar(context,'Failed to scan barcode');
    }
  }
  Future<void> scanBatchNumber() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BatchScannerPage()),
      );
      if (result.isNotEmpty) {
        _showManualEntryBottomSheet(result);
      }
    } catch (e) {
      //AppUtils.showSnackBar(context,'Failed to scan');
    }
  }
  Future<void> scanBatchNumberOld() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    final inputImage = InputImage.fromFile(File(pickedFile.path));
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    final List<String> allLines = [];

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        final lineText = line.text.trim();
        allLines.add(lineText);
        print('Recognized line: $lineText');
      }
    }

    String? batchNumber;

    final labelPattern = RegExp(
      r'\b(?:b[\.\s]*no[\.\s]*|batch(?:\s+no[\.\s]*)?)[:\s]*([A-Za-z0-9\-\/]{4,})?',
      caseSensitive: false,
    );
    final valuePattern = RegExp(r'^[A-Za-z0-9\-\/]{4,}$');

    for (int i = 0; i < allLines.length; i++) {
      final line = allLines[i];

      final labelMatch = labelPattern.firstMatch(line);
      if (labelMatch != null) {
        // Case 1: Value is on the same line
        final sameLineValue = labelMatch.group(1);
        if (sameLineValue != null && sameLineValue.trim().isNotEmpty) {
          batchNumber = sameLineValue.trim();
          print("Batch number found on same line: $batchNumber");
          break;
        }

        // Case 2: Look ahead in the next 1–3 lines
        for (int j = 1; j <= 10 && (i + j) < allLines.length; j++) {
          final nextLine = allLines[i + j].trim();
          if (valuePattern.hasMatch(nextLine)) {
            batchNumber = nextLine;
            print("Batch number found in next lines: $batchNumber");
            break;
          }
        }
      }

      if (batchNumber != null) break;
    }

    await textRecognizer.close();

    if (batchNumber != null && batchNumber.isNotEmpty) {
      _showManualEntryBottomSheet(batchNumber);
    } else {
      AppUtils.showSnackBar(context,'Batch number not found');
      _showManualEntryBottomSheet('');
    }
  }

  void _showManualEntryBottomSheet(String batchNumber) {
    showDialog(
      context: context,
      builder: (_) => EditValueDialog(
          title: 'Batch No.',
          initialValue:batchNumber,
          onSave: (value) {
            setState(() {
              extractedBatchNumber = value;
            });
            context.read<ApiCubit>().BarcodeScan(
              code: extractedBatchNumber,
              storeId: userId,
              source: 'scan'
            );
          },
      ),
    );
  }

  Widget cartAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(85),
      child: Container(
        width: double.infinity,
        color: AppColors.kPrimary,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0,bottom: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyTextfield.textStyle_w600('Sale Cart', SizeConfig.screenWidth! * 0.055, Colors.white),
                    IconButton(
                      icon: const Icon(
                        Icons.qr_code_scanner,
                        color: AppColors.kWhiteColor,
                        size: 30,
                      ),
                      onPressed: _QuickscanBarcode,
                    ),
                  ],
                ),
              ),

             /* Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: MyChipWithIconWidget(
                        color: AppColors.kPrimaryLight,
                        icon: Icons.browse_gallery,
                        text: 'Pick Image',
                        textColor: AppColors.kPrimary,
                        onPressed: () {
                          scanBatchNumber();
                        },
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: MyChipWithIconWidget(
                        color: AppColors.kPrimaryLight,
                        icon: Icons.qr_code_scanner,
                        text: 'Scan Barcode',
                        textColor: AppColors.kPrimary,
                        onPressed: () {
                          _scanBarcode();
                        },
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: MyChipWithIconWidget(
                        color: AppColors.kPrimaryLight,
                        icon: Icons.edit,
                        text: 'Add Manually',
                        textColor: AppColors.kPrimary,
                        onPressed: () {
                          AppRoutes.navigateTo(context, ProductListPage(flag: 4));
                        },
                      ),
                    ),
                  ],
                ),
              ),*/


              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}
