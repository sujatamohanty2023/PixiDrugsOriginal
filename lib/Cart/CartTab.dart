
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
              context.read<CartCubit>().addToCart(searchResults.first, 1, type: CartType.main);
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
            child: _buildCartOrEmpty(state.cartItems));
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
        onTap: _QuickscanBarcode,
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
      if (result.isNotEmpty && result!='manualAdd') {
       await context.read<ApiCubit>().BarcodeScan(code: result['code'],storeId: userId,);
      }
    } catch (e) {
      AppUtils.showSnackBar(context,'Failed to scan barcode');
    }
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
