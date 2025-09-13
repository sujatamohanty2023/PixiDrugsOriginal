import '../constant/all.dart';
class StockFilterWidget extends StatefulWidget {
  final void Function(
      String? sellerName,
      String? medicineName,
      String? composition,
      String? stockStatus,
      String? expiryStatus,
      ) onApply;
  final void Function() onReset;
  final String? sellerName;
  final String? medicineName;
  final String? composition;
  final String? stockStatus;
  final String? expiryStatus;

  const StockFilterWidget({
    Key? key,
    required this.onApply,
    this.sellerName,
    this.medicineName,
    this.composition,
    this.stockStatus = 'All',
    this.expiryStatus = 'All',
    required this.onReset,
  }) : super(key: key);

  @override
  State<StockFilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<StockFilterWidget> {
  TextEditingController sellerController = TextEditingController();
  TextEditingController medicineController = TextEditingController();
  TextEditingController compositionController = TextEditingController();

  String selectedStockStatus = '';
  String selectedExpiryStatus = "";

  final List<String> stockStatusList = ['In stock', 'Out of stock'];
  final List<String> expiryStatusList = ['Expired', 'Expiring Soon'];

  @override
  void initState() {
    super.initState();
    sellerController.text = widget.sellerName ?? '';
    medicineController.text = widget.medicineName ?? '';
    compositionController.text = widget.composition ?? '';
  }

  void _resetFilters() {
    setState(() {
      selectedStockStatus = '';
      selectedExpiryStatus = '';
      sellerController.clear();
      medicineController.clear();
      compositionController.clear();
    });
    widget.onReset();
  }

  Widget _buildPopupMenuButton({
    required String selectedValue,
    required List<String> options,
    required Function(String) onSelected,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.kPrimaryDark, width: 1),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: PopupMenuButton<String>(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: AppColors.kWhiteColor,
        elevation: 8,
        onSelected: onSelected,
        itemBuilder: (_) {
          return options.map((status) {
            return PopupMenuItem<String>(
              value: status,
              child: MyTextfield.textStyle_w400(status.toUpperCase(), SizeConfig.screenWidth! * 0.035, AppColors.kPrimary),
            );
          }).toList();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: MyTextfield.textStyle_w400(selectedValue, 15, Colors.black),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.myGradient),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 10,
          right: 10,
          top: 10,
        ),
        child: SingleChildScrollView(  // Ensure scrollability in case the content is too big
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: MyTextfield.textStyle_w800("Filter", AppUtils.size_18, Colors.black),
                  ),
                  IconButton(
                    icon: Icon(Icons.clear, color: AppColors.kPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(color: AppColors.kPrimaryLight),

              // Editable Fields for Medicine, Seller, Composition using MyEdittextfield
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyTextfield.textStyle_w400("Seller", SizeConfig.screenWidth! * 0.035, Colors.black54),
                        SizedBox(height: 6),
                        MyEdittextfield(
                          controller: sellerController,
                          hintText: "Enter Seller Name",
                          keyboardType: TextInputType.text,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyTextfield.textStyle_w400("Medicine", SizeConfig.screenWidth! * 0.035, Colors.black54),
                        SizedBox(height: 6),
                        MyEdittextfield(
                          controller: medicineController,
                          hintText: "Enter Medicine Name",
                          keyboardType: TextInputType.text,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyTextfield.textStyle_w400("Composition", SizeConfig.screenWidth! * 0.035, Colors.black54),
                        SizedBox(height: 6),
                        MyEdittextfield(
                          controller: compositionController,
                          hintText: "Enter Composition",
                          keyboardType: TextInputType.text,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Stock Status and Expiry Status Filter
              Row(
                children: [
                  Expanded(
                    child: _buildPopupMenuButton(
                      selectedValue: selectedStockStatus,
                      options: stockStatusList,
                      onSelected: (value) {
                        setState(() {
                          selectedStockStatus = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildPopupMenuButton(
                      selectedValue: selectedExpiryStatus,
                      options: expiryStatusList,
                      onSelected: (value) {
                        setState(() {
                          selectedExpiryStatus = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Apply and Reset Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: MyElevatedButton(
                      onPressed: () {
                        widget.onApply(
                          sellerController.text,
                          medicineController.text,
                          compositionController.text,
                          selectedStockStatus,
                          selectedExpiryStatus,
                        );
                      },
                      buttonText: 'Apply Filters',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: MyElevatedButton(
                      onPressed: _resetFilters,
                      buttonText: 'Reset',
                      backgroundColor: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
