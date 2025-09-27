import '../../constant/all.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../ReturnProduct/ReturnProductList.dart';
import '../Stock/ProductList.dart';
import '../search/customerModel.dart';
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
  // final player = AudioPlayer(); // Temporarily disabled

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

    // player.setAsset('assets/sound/scanner.mpeg'); // Temporarily disabled
  }

  @override
  void dispose() {
    _animationController.dispose();
    // player.dispose(); // Temporarily disabled
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isLoading = false;
  }

  /// ✅ Play beep
  Future<void> playBeep() async {
    // Temporarily disabled audio
    // try {
    //   await player.play();
    // } catch (e) {
    //   debugPrint("Error playing sound: $e");
    // }
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Left corner - 2 buttons vertically stacked
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 120,
                      child: _buildBottomButton(
                        icon: Icons.search,
                        label: "Search Product",
                        color: AppColors.kPrimary,
                        onTap: () async {
                          if (widget.cartTypeSelection != null) {
                            AddManualClickReturn();
                          } else {
                            AddManualClick();
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 120,
                      child: _buildBottomButton(
                        icon: Icons.camera_alt,
                        label: "Camera Scan",
                        color: AppColors.secondaryColor,
                        onTap: () {
                          // Camera scan functionality
                        },
                      ),
                    ),
                  ],
                ),
                // Center spacer
                const Expanded(child: SizedBox()),
                // Right corner - 2 buttons vertically stacked
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 120,
                      child: _buildBottomButton(
                        icon: Icons.qr_code,
                        label: "QR Code",
                        color: const Color(0xFF4CAF50),
                        onTap: () {
                          setState(() {
                            selectedTab = 0;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 120,
                      child: _buildBottomButton(
                        icon: Icons.inventory,
                        label: "Batch Info",
                        color: const Color(0xFFFF9800),
                        onTap: () {
                          setState(() {
                            selectedTab = 1;
                          });
                        },
                      ),
                    ),
                  ],
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

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color,
              color.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(height: 8),
            MyTextfield.textStyle_w600(
              label,
              SizeConfig.screenWidth! * 0.032,
              Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
