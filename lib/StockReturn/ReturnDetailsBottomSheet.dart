import 'package:PixiDrugs/StockReturn/PurchaseReturnModel.dart';

import '../constant/all.dart';

class ReturnDetailsBottomSheet extends StatefulWidget {
  final PurchaseReturnModel returnData;

  const ReturnDetailsBottomSheet({super.key, required this.returnData});

  @override
  State<ReturnDetailsBottomSheet> createState() => _ReturnDetailsBottomSheetState();
}

class _ReturnDetailsBottomSheetState extends State<ReturnDetailsBottomSheet> {
  late TextEditingController _reasonController;
  late List<TextEditingController> _quantityControllers;
  late List<TextEditingController> _rateControllers;

  bool _isEditable = false;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController(text: widget.returnData.reason ?? '');
    _quantityControllers = widget.returnData.items
        .map((item) => TextEditingController(text: item.quantity.toString()))
        .toList();
    _rateControllers = widget.returnData.items
        .map((item) => TextEditingController(text: item.rate))
        .toList();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _quantityControllers.forEach((c) => c.dispose());
    _rateControllers.forEach((c) => c.dispose());
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.myGradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 5,
                width: 40,
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.kPrimary,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            MyTextfield.textStyle_w600(widget.returnData.sellerName!, AppUtils.size_18, AppColors.kPrimary),
            SizedBox(height: 12),

            // Date
            MyTextfield.textStyle_w400("Dt.${widget.returnData.returnDate}",  AppUtils.size_16, Colors.black),
            SizedBox(height: 10),
            // Reason
            MyTextfield.textStyle_w400("Reason",  AppUtils.size_16, Colors.black),
            MyEdittextfield(
              controller: _reasonController,
              hintText: "Enter Return Reason",
              readOnly: !_isEditable,
              maxLines: 3,
            ),
            SizedBox(height: 10),

            MyTextfield.textStyle_w600("Returned Items",  AppUtils.size_16, Colors.black),
            SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.returnData.items.length,
              separatorBuilder: (_, __) => Divider(),
              itemBuilder: (_, index) {
                final item = widget.returnData.items[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyTextfield.textStyle_w600("Product: ${item.productName}", AppUtils.size_18,AppColors.kPrimary),
                    MyTextfield.textStyle_w300("Batch: ${item.batchNo} | Exp: ${item.expiry}",AppUtils.size_14,AppColors.kBlackColor800),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyTextfield.textStyle_w400("Qty",  AppUtils.size_16, Colors.black),
                              SizedBox(height: 5),
                              MyEdittextfield(
                                controller: _quantityControllers[index],
                                hintText: "Qty",
                                readOnly: !_isEditable,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyTextfield.textStyle_w400("Rate",  AppUtils.size_16, Colors.black),
                              SizedBox(height: 5),
                              MyEdittextfield(
                                controller: _rateControllers[index],
                                hintText: "Rate",
                                readOnly: !_isEditable,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                );
              },
            ),
            SizedBox(height: 20),

            MyElevatedButton(
              onPressed: () {
                if (_isEditable) {
                  ReturnApiCall();
                  Navigator.pop(context); // Close on Save
                } else {
                  setState(() => _isEditable = true);
                }
              },
              buttonText: _isEditable ? "Update" : "Edit" ,
            )

          ],
        ),
      ),
    );
  }
  Future<void> ReturnApiCall() async {
    final userId = await SessionManager.getUserId() ?? '0';

    final selectedItems = <ReturnItemModel>[];

    for (int i = 0; i < widget.returnData.items.length; i++) {
      final item = widget.returnData.items[i];

      final quantity = int.tryParse(_quantityControllers[i].text.trim()) ?? 0;
      final rate = double.tryParse(_rateControllers[i].text.trim()) ?? 0.0;

      final total = quantity * rate;

      selectedItems.add(ReturnItemModel(
        id: item.id,
        productId: item.productId,
        productName: item.productName,
        batchNo: item.batchNo,
        expiry: item.expiry,
        quantity: quantity,
        rate: rate.toString(),
        gstPercent: item.gstPercent,
        discountPercent: item.discountPercent,
        totalAmount: total.toString(),
      ));
    }

    final totalAmount = selectedItems.fold<double>(
      0.0,
          (sum, item) => sum + (double.tryParse(item.totalAmount) ?? 0.0),
    );

    final returnModel = PurchaseReturnModel(
      id: widget.returnData.id,
      storeId: int.parse(userId),
      invoicePurchaseId: widget.returnData.invoicePurchaseId ?? 0,
      sellerId: widget.returnData.sellerId ?? 0,
      returnDate: DateTime.now().toIso8601String(),
      totalAmount: totalAmount.toStringAsFixed(2),
      reason: _reasonController.text.trim(),
      items: selectedItems,
    );

    print("Return Payload: ${returnModel.toJson()}");
    context.read<ApiCubit>().StockReturnEdit(returnModel: returnModel);
  }

}

