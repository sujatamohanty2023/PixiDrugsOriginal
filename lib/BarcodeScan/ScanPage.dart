import 'package:PixiDrugs/BarcodeScan/utilScanner/CornerPainter.dart';
import 'package:PixiDrugs/BarcodeScan/utilScanner/ScanLinePainter.dart';
import 'package:PixiDrugs/BarcodeScan/utilScanner/ScannerOverlayPainter.dart';
import 'package:PixiDrugs/constant/all.dart';
import 'package:http_parser/http_parser.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';

import '../AIResponse/BatchInfoResponse.dart';
import '../ReturnProduct/ReturnProductList.dart';
import '../ReturnProduct/ReturnStockiestCart.dart';
import '../Stock/ProductList.dart';
import '../search/customerModel.dart';
import '../search/sellerModel.dart';
import 'barcode_screen_page.dart';
import 'batch_scanner_page.dart';

class QuikScanPageOld extends StatefulWidget {
  CartTypeSelection? cartTypeSelection;
  CustomerModel? selectedCustomer;
  final Function(CustomerModel)? onCustomerSelected;

  QuikScanPageOld({super.key, this.cartTypeSelection, this.selectedCustomer,this.onCustomerSelected});

  @override
  State<QuikScanPageOld> createState() => _QuikScanPageOldState();
}

class _QuikScanPageOldState extends State<QuikScanPageOld>
    with SingleTickerProviderStateMixin {
  int selectedTab = 0; // 0 =Barcode, 1 =  Batch Info
  final player = AudioPlayer();

  bool isLoading = false;
  bool isProcessing = false;
  String? lastScanned; // remember last scanned value

  Map<String, dynamic> scanedResult={};
  late AnimationController _animationController;
  late Animation<double> _animation;
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    returnImage: true, // Enable image capture
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
    return WillPopScope(
        onWillPop: () async {
          // Trigger same behavior as AppBar back arrow
          Navigator.pop(context, scanedResult);
          return false; // Prevent default back navigation
        },
        child: Scaffold(
      backgroundColor: Colors.black.withOpacity(0.6),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: AppColors.kPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context,scanedResult),
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
              color:AppColors.kPrimary,
              child: Row(
                children: [
                  _buildTabButton("Scan Barcode", 0),
                  _buildTabButton("Scan Batch No.", 1),
                ],
              ),
            ),

            // === Scanner ===
            Expanded(
              child:
                  selectedTab == 0 ? BarcodeScannerPage() : BatchScannerPage(flag: 1,),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: GestureDetector(
          onTap: () async {
            if (widget.cartTypeSelection != null) {
              AddManualClickReturn();
            } else {
              AddManualClick();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.kPrimary,
                    AppColors.secondaryColor,
                  ],
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(width: 0.5, color: AppColors.secondaryColor),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search, color: Colors.white),
                const SizedBox(width: 8),
                MyTextfield.textStyle_w600(
                  "Search Product",
                  SizeConfig.screenWidth! * 0.040,
                  Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),

    )
    );
  }
  Future<void> AddManualClickReturn() async {
    final scannedCode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReturnProductListPage(
          cartTypeSelection: widget.cartTypeSelection,
          selectedCustomer: widget.selectedCustomer
      ),),
    );

    if (scannedCode != null) {
      scanedResult=scannedCode;
      Navigator.pop(context,scanedResult);
    }
  }
  Future<void> AddManualClick() async {
    final scannedCode = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductListPage(flag: 4)),
    );

    if (scannedCode != null) {
      Navigator.pop(context, {'code':'manualAdd'});
    }
  }
  Widget _buildTabButton(String title, int index) {
    final isSelected = selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap:
            () => setState(() {
              selectedTab = index;
              lastScanned = null;
            }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color:
                    isSelected ? AppColors.secondaryColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: MyTextfield.textStyle_w600(
            title.toUpperCase(),
            SizeConfig.screenWidth! * 0.045,
            isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }
}
