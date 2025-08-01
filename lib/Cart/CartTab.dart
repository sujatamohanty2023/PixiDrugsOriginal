
import 'package:PixiDrugs/constant/all.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../BarcodeScan/barcode_screen_page.dart';
import '../Stock/ProductList.dart';

class CartTab extends StatefulWidget {
  final void Function() onPressedProduct;
  final bool barcodeScan;

  const CartTab({
    Key? key,
    required this.onPressedProduct,
    this.barcodeScan = false,
  }) : super(key: key);

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
    final id = await SessionManager.getUserId();
    setState(() {
      userId = id ?? '';
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: cartAppBar(context),

      body: BlocListener<ApiCubit, ApiState>(
        listener: (context, state) {
          if (state is BarcodeScanLoaded && state.source=='scan') {
            searchResults = state.list;
            if (searchResults.isNotEmpty) {
              final cartCubit = context.read<CartCubit>();
              cartCubit.addToCart(searchResults.first, 1, type: CartType.barcode);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No products found.')),
              );
            }
          } else if (state is BarcodeScanError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        child: _buildCartContent(context),
      ),
    );
  }

  Widget buildActionButton(IconData icon, String label,int flag) {
    return GestureDetector(
      onTap: (){
        if(flag==1) {
          AppRoutes.navigateTo(context,ProductListPage(flag: 4));
        }else if(flag==2) {
          _scanBarcode();
        }else if(flag==3){
          scanBatchNumber();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: AppColors.myGradient,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.kPrimary,size: 14,),
            const SizedBox(width: 1),
            MyTextfield.textStyle_w600(label, 16, AppColors.kPrimary),
          ],
        ),
      ),
    );
  }

  /// Builds either cart or barcode cart content based on `widget.barcodeScan`
  Widget _buildCartContent(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return _buildCartOrEmpty(state.barcodeCartItems);
      },
    );
  }

  /// Shows empty page or the main CartPage
  Widget _buildCartOrEmpty(List<InvoiceItem> items) {
    return items.isEmpty ? _buildEmptyPage() : CartPage(
        barcodeScan: widget.barcodeScan);
  }

  /// Shows a customizable empty cart page
  Widget _buildEmptyPage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.myGradient,
      ),
      child: NoItemPage(
        onTap: _scanBarcode,
        image: AppImages.empty_cart,
        tittle: "Your Cart is Empty",
        description: "Looks like you haven't added anything \nto your cart yet.",
        button_tittle: widget.barcodeScan ? 'Scan Now' : "Shop Now",
      ),
    );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to scan barcode')),
      );
    }
  }
  Future<void> scanBatchNumber() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    final inputImage = InputImage.fromFile(File(pickedFile.path));
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    String? batchNumber;

    for (TextBlock block in recognizedText.blocks) {
      for (var line in block.lines) {
        print('Recognized line: ${line.text}');

        final pattern = RegExp(
          r'\b(?:b[\.\s]*no[\.\s]*)[:\s]*([A-Z0-9\-]+)',
          caseSensitive: false,
        );

        final match = pattern.firstMatch(line.text);
        if (match != null) {
          batchNumber = match.group(1);
          print("Matched batch number: $batchNumber");
          break;
        }
      }
      if (batchNumber != null) break;
    }

    await textRecognizer.close();

    if (batchNumber != null && batchNumber.isNotEmpty) {
      setState(() {
        extractedBatchNumber = batchNumber!;
      });

      print("Calling API with batch: $extractedBatchNumber");

      context.read<ApiCubit>().BarcodeScan(
        code: extractedBatchNumber,
        storeId: userId,
        source: 'scan',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Batch number not found')),
      );
    }
  }

  PreferredSizeWidget cartAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(85),
      child: Container(
        color: AppColors.kPrimary,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: MyTextfield.textStyle_w600(
                    'Sale Cart', SizeConfig.screenWidth! * 0.055, Colors.white),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 8,),
                    buildActionButton(Icons.edit, 'Add Manually',1),
                    SizedBox(width: 8,),
                    buildActionButton(Icons.qr_code_scanner, 'Scan Barcode', 2),
                    SizedBox(width: 8,),
                    buildActionButton(Icons.browse_gallery, 'Pick Image',3),
                  ],
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}
