import 'package:PixiDrugs/constant/all.dart';
import 'package:PixiDrugs/StockReturn/ReturnProductTile.dart';

import '../SaleList/sale_details.dart';
import 'BillingModel.dart';
import 'CustomerReturnsResponse.dart';
import 'SaleReturnProductTile.dart';
import 'SaleReturnRequest.dart';

class SaleReturnScreen extends StatefulWidget {
  final int billNo;
  CustomerReturnsResponse? returnModel;
  bool? addReturn;

   SaleReturnScreen({Key? key,required this.billNo,this.returnModel,this.addReturn=false}) : super(key: key);
  @override
  State<SaleReturnScreen> createState() => _SaleReturnScreenState();
}

class _SaleReturnScreenState extends State<SaleReturnScreen> {
  bool editClick=false;
  Billing? returnBill;
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
    _fetchBillDetail();
  }

  Future<void> _fetchBillDetail() async {
    setState(() {
      isLoading = true;
    });
    final userId = await SessionManager.getParentingId() ??'';
    context.read<ApiCubit>().GetSaleBillDetail(bill_id: widget.billNo.toString(),store_id: userId);
  }
  Future<void> ReturnApiCall() async {
    setState(() {
      isLoading = true;
    });
    final userId = await SessionManager.getParentingId() ?? '';
    final selectedItems = returnBill!.items
        .where((item) => item.isSelected == true && item.returnQty > 0)
        .map((item) => ReturnedItem(
      productId: item.productId,
      quantity: item.returnQty,
      price:double.parse(item.price),
      discount:double.parse(item.discount),
      gst:double.parse(item.gst),
      totalAmount:double.parse(item.subtotal),
    ))
        .toList();

    final totalAmount = selectedItems.fold<double>(
      0.0,
          (sum, item) => sum + (item.quantity * item.price),
    );
    var returnModel = SaleReturnRequest(
      id: editClick && widget.returnModel !=null?widget.returnModel?.id:null,
      storeId:int.parse(userId),
      billingId:returnBill!.billingId,
      customerId:returnBill!.customerId,
      returnDate:DateTime.now().toString(),
      totalAmount:totalAmount,
      reason: selectedReason ?? '',
      items:selectedItems,
    );
    print(returnModel.toString());
    if(editClick && widget.returnModel !=null){
      context.read<ApiCubit>().SaleReturnEdit(returnModel: returnModel);
    }else {
      context.read<ApiCubit>().SaleReturnAdd(returnModel: returnModel);
    }
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: BlocListener<ApiCubit, ApiState>(
        listener: (context, state) {
          if (state is GetSaleBillDetailLoaded) {
            setState(() {
              isLoading = false;
              returnBill = state.billingModel;
              if (widget.returnModel != null) {
                if(widget.returnModel!.reason.isEmpty){
                  selectedReason =returnReasons.first;
                }else {
                  selectedReason = widget.returnModel!.reason;
                }
                final returnItems = widget.returnModel!.items;

                for (var item in returnItems) {
                  final matchingItem = returnBill?.items.firstWhere(
                        (invItem) =>
                    invItem.productId == item.productId
                  );

                  if (matchingItem != null) {
                    matchingItem.isSelected = true;
                    matchingItem.returnQty = item.quantity;
                  }
                }

              }
            });
          } else if (state is GetSaleBillDetailError) {
            setState(() {
              isLoading = false;
            });
            Navigator.pop(context); // Use caution here
            AppUtils.showSnackBar(context,'Failed to load data: ${state.error}');
          }else if (state is SaleReturnAddLoaded) {
            setState(() {
              isLoading = false;
              if(state.success) {
                Navigator.pop(context); // Use caution here
                AppUtils.showSnackBar(context,'Successfully retrun');
              }
            });
          } else if (state is SaleReturnAddError) {
            setState(() {
              isLoading = false;
            });
            Navigator.pop(context); // Use caution here
            AppUtils.showSnackBar(context,state.error);
          }else if (state is SaleReturnEditLoaded) {
            setState(() {
              isLoading = false;
              if(state.success) {
                Navigator.pop(context); // Use caution here
                AppUtils.showSnackBar(context,'Successfully Updated');
              }
            });
          } else if (state is SaleReturnEditError) {
            setState(() {
              isLoading = false;
            });
            Navigator.pop(context); // Use caution here
            AppUtils.showSnackBar(context,state.error);
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
                            'Customer Return',
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
                    child: returnBill == null
                        ? Center(child: CircularProgressIndicator(color: AppColors.kPrimary))
                        :  SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
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
                                  CircleAvatar(
                                    radius: screenWidth * 0.08,
                                    backgroundColor: AppColors.kPrimaryDark,
                                    child: MyTextfield.textStyle_w400(
                                      getInitials(returnBill!.customerName),
                                      screenWidth * 0.045,
                                      AppColors.kPrimary,
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.03),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        MyTextfield.textStyle_w800(
                                          returnBill!.customerName,
                                          screenWidth * 0.04,
                                          AppColors.kPrimary,
                                        ),
                                        MyTextfield.textStyle_w400(
                                          "Bill No. #${widget.billNo}",
                                          screenWidth * 0.04,
                                          Colors.green,
                                        ),
                                        SizedBox(height: screenWidth * 0.01),
                                        MyTextfield.textStyle_w400(
                                          'Mob: ${returnBill!.customerMobile!}',
                                          screenWidth * 0.035,
                                          Colors.grey.shade700,
                                        ),
                                        SizedBox(height: screenWidth * 0.01),
                                        MyTextfield.textStyle_w400(
                                          'Dt. ${returnBill!.billingDate}',
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

                            onChanged: (editClick || widget.addReturn!)
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
                          returnBill!.items.isNotEmpty
                              ? ListView.builder(
                            itemCount: returnBill!.items.length,
                            padding: EdgeInsets.zero,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final item = returnBill!.items[index];
                              return SaleReturnProductTile(
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
                label: MyTextfield.textStyle_w600("Confirm", AppUtils.size_18, AppColors.kWhiteColor),
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
}

