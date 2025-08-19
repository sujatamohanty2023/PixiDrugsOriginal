import 'package:PixiDrugs/constant/all.dart';
import 'package:PixiDrugs/StockReturn/ReturnProductTile.dart';

import 'PurchaseReturnModel.dart';

class PurchaseReturnScreen extends StatefulWidget {
  final String invoiceNo;
  PurchaseReturnModel? returnModel;
  bool? addReturn;
  PurchaseReturnScreen({Key? key,required this.invoiceNo,this.returnModel, this.addReturn=false}) : super(key: key);

  @override
  State<PurchaseReturnScreen> createState() => _PurchaseReturnScreenState();
}

class _PurchaseReturnScreenState extends State<PurchaseReturnScreen> {
  String? invoice_No;
  Invoice? return_invoice;
  bool editClick=false;
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();
  List<String> returnReasons = [
    'Select return reason',
    'Expired Product',
    'Damaged Product',
    'Wrong Item Delivered',
    'Excess Quantity',
    'Other',
  ];

  String? selectedReason;

  @override
  void initState() {
    super.initState();
    invoice_No=widget.invoiceNo;
    print("invoiceId:$invoice_No");
    _fetchStockList();
  }

  Future<void> _fetchStockList() async {
    setState(() {
      isLoading = true;
    });
    final userId = await SessionManager.getParentingId() ??'';
    context.read<ApiCubit>().GetInvoiceDetail(invoice_id: widget.invoiceNo,store_id: userId);
  }
  Future<void> ReturnApiCall() async {
    setState(() {
      isLoading = true;
    });
    final userId = await SessionManager.getParentingId() ?? '';
    final selectedItems = return_invoice!.items
        .where((item) => item.isSelected == true && item.returnQty > 0)
        .map((item) => ReturnItemModel(
      productId: item.id??0,
      quantity: item.returnQty,
      rate: item.rate,
      batchNo: item.batch,
      expiry:item.expiry,
      gstPercent:item.gst,
      discountPercent: item.discount,
      totalAmount: (item.returnQty * (double.tryParse(item.rate) ?? 0.0)).toString(),
    ))
        .toList();

    final totalAmount = selectedItems.fold<double>(
      0.0,
          (sum, item) => sum + (item.quantity * double.parse(item.rate)),
    );
    var returnModel = PurchaseReturnModel(
      id: editClick && widget.returnModel !=null?widget.returnModel?.id:0,
      storeId:int.parse(userId),
      invoicePurchaseId:return_invoice!.items.first.invoice_purchase_id,
      sellerId:int.parse(return_invoice!.sellerId!),
      invoiceNo: return_invoice!.invoiceId!,
      returnDate:DateTime.now().toString(),
      totalAmount:totalAmount.toString(),
      reason: selectedReason ?? '',
      items:selectedItems,
    );
    print('returnModel=${returnModel.toString()}');
    if(editClick && widget.returnModel !=null){
      context.read<ApiCubit>().StockReturnEdit(returnModel: returnModel);
    }else {
      context.read<ApiCubit>().StockReturnAdd(returnModel: returnModel);
    }
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: BlocListener<ApiCubit, ApiState>(
        listener: (context, state) {
          if (state is GetInvoiceDetailLoaded) {
            setState(() {
              isLoading = false;
              return_invoice = state.invoiceModel;
              print("returnModel=${return_invoice.toString()}");

              if (widget.returnModel != null) {
                if(widget.returnModel!.reason.isEmpty){
                  selectedReason =returnReasons.first;
                }else {
                  selectedReason = widget.returnModel!.reason;
                }
                final returnItems = widget.returnModel!.items;

                for (var item in returnItems) {
                  final matchingItem = return_invoice?.items.firstWhere(
                        (invItem) =>
                    invItem.id == item.productId &&
                        invItem.batch == item.batchNo &&
                        invItem.expiry == item.expiry,
                  );

                  if (matchingItem != null) {
                    matchingItem.isSelected = true;
                    matchingItem.returnQty = item.quantity;
                  }
                }

              }
            });
          } else if (state is GetInvoiceDetailError) {
            setState(() {
              isLoading = false;
            });
            Navigator.pop(context); // Use caution here
            AppUtils.showSnackBar(context,'Failed to load data: ${state.error}');
          }else if (state is StockReturnAddLoaded) {
            setState(() {
              isLoading = false;
              if(state.success) {
                Navigator.pop(context); // Use caution here
                AppUtils.showSnackBar(context,'Successfully retrun to stock');
              }else{
          AppUtils.showSnackBar(context,'Failed to add StockReturn stock');
              }
            });
          } else if (state is StockReturnAddError) {
            setState(() {
              isLoading = false;
            });
            Navigator.pop(context); // Use caution here
            AppUtils.showSnackBar(context,'Failed to load data: ${state.error}');
          }else if (state is StockReturnEditLoaded) {
            setState(() {
              isLoading = false;
              if(state.success) {
                Navigator.pop(context); // Use caution here
                AppUtils.showSnackBar(context,'Successfully Updated');
              }else{
            AppUtils.showSnackBar(context,'Failed to Update');
              }
            });
          } else if (state is StockReturnEditError) {
            setState(() {
              isLoading = false;
            });
            Navigator.pop(context); // Use caution here
            AppUtils.showSnackBar(context,'Failed to update api : ${state.error}');
          }
        },
        child: Container(
          color: AppColors.kPrimary,
          width: double.infinity,
          padding: EdgeInsets.only(top: screenWidth * 0.01),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                          SizedBox(width: 10),
                          MyTextfield.textStyle_w600(
                            'Purchase Return',
                            screenWidth * 0.055,
                            Colors.white,
                          ),
                        ],
                      ),
                      widget.addReturn==false?Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.kWhiteColor, size: 30),
                          onPressed: ()=>setState(() {
                            editClick = true;
                          }),
                          tooltip: 'Edit',
                        ),
                      ):SizedBox()
                    ],
                  ),
                ),
                SizedBox(height: 8),

                // Expanded Scrollable Area
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                      vertical: screenWidth * 0.02,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.myGradient,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(screenWidth * 0.07),
                        topLeft: Radius.circular(screenWidth * 0.07),
                      ),
                    ),
                    child: return_invoice == null
                        ? Center(child: CircularProgressIndicator(color: AppColors.kPrimary))
                        :  SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                screenWidth * 0.03,
                              ),
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  return_invoice!.sellerName!.isNotEmpty?CircleAvatar(
                                    radius: screenWidth * 0.08,
                                    backgroundColor: AppColors.kPrimaryDark,
                                    child: MyTextfield.textStyle_w400(
                                      getInitials(return_invoice!.sellerName!),
                                      screenWidth * 0.045,
                                      AppColors.kPrimary,
                                    ),
                                  ):SizedBox(),
                                  SizedBox(width: screenWidth * 0.03),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        MyTextfield.textStyle_w800(
                                          return_invoice!.sellerName!,
                                          screenWidth * 0.04,
                                          AppColors.kPrimary,
                                        ),
                                        MyTextfield.textStyle_w400(
                                          "Invoice No. #$invoice_No",
                                          screenWidth * 0.04,
                                          Colors.green,
                                        ),
                                        SizedBox(height: screenWidth * 0.01),
                                        MyTextfield.textStyle_w400(
                                          'Mob: ${return_invoice!.sellerPhone!}',
                                          screenWidth * 0.035,
                                          Colors.grey.shade700,
                                        ),
                                        SizedBox(height: screenWidth * 0.01),
                                        MyTextfield.textStyle_w400(
                                          'Dt. ${return_invoice!.invoiceDate!}',
                                          screenWidth * 0.035,
                                          Colors.grey.shade700,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),
                            SizedBox(height: 12),
                            MyTextfield.textStyle_w600(
                              'Reason for Return',
                              screenWidth * 0.045,
                              Colors.black,
                            ),
                            const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: selectedReason,
                          items: returnReasons.map((reason) {
                            return DropdownMenuItem<String>(
                              value: reason,
                              child: MyTextfield.textStyle_w400(reason,16,Colors.grey),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: AppColors.kPrimaryDark, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: AppColors.kPrimary, width: 1.5),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                            ),
                          ),

                          onChanged: ( editClick|| widget.addReturn!)
                              ? (value) {
                            setState(() {
                              selectedReason = value;
                            });
                          }
                              : null, // ❌ disables the dropdown when not editable
                          hint: const Text("Select a reason"),
                        ),
                          const SizedBox(height: 16),
                          // Product List Title
                          MyTextfield.textStyle_w600(
                            'Product Detail',
                            screenWidth * 0.05,
                            Colors.black,
                          ),
                          const SizedBox(height: 10),

                          // Product List
                          return_invoice!.items.isNotEmpty ? ListView.builder(
                            itemCount: return_invoice!.items.length,
                            padding: EdgeInsets.zero,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final item = return_invoice!.items[index];
                              return ReturnProductTile(
                                product: item,
                                editable: editClick || widget.addReturn!,
                                onChecked: (checked) {
                                  setState(() {
                                    item.isSelected = checked;
                                  });
                                },
                                onQtyChanged: (qtyStr) {
                                  item.returnQty = int.tryParse(qtyStr) ?? 0;
                              },
                              );
                            },
                          )
                              : Center(
                            child: MyTextfield.textStyle_w600(
                              "No products found.",
                              screenWidth * 0.045,
                              Colors.red,
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: !editClick && widget.returnModel !=null?SizedBox():Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left:8,right: 8),
              child: ElevatedButton.icon(
                onPressed: () {
                  ReturnApiCall();
                },
                label: MyTextfield.textStyle_w600(editClick?"Update":"Confirm", AppUtils.size_18, AppColors.kWhiteColor),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.kPrimary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Utility to get initials from name
  String getInitials(String name) {
    List<String> parts = name.trim().split(" ");
    return parts.length >= 2
        ? "${parts[0][0]}${parts[1][0]}"
        : name.substring(0, 2);
  }
}

