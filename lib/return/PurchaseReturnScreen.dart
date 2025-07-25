import 'package:PixiDrugs/constant/all.dart';
import 'package:PixiDrugs/return/ReturnProductTile.dart';

import 'PurchaseReturn.dart';

class PurchaseReturnScreen extends StatefulWidget {
  final String invoiceNo;
  final bool? edit;
  final int? edit_id;
  const PurchaseReturnScreen({Key? key,required this.invoiceNo,
  this.edit=false,this.edit_id=0}) : super(key: key);

  @override
  State<PurchaseReturnScreen> createState() => _PurchaseReturnScreenState();
}

class _PurchaseReturnScreenState extends State<PurchaseReturnScreen> {
  String? invoice_No;
  int currentIndex = 0;
  List<Invoice> returnList = [];
  Invoice? return_invoice;

  bool isLoading = true;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    invoice_No=widget.invoiceNo;
    _fetchStockList();
  }

  Future<void> _fetchStockList() async {
    setState(() {
      isLoading = true;
    });
    context.read<ApiCubit>().GetInvoiceDetail(invoice_id: widget.invoiceNo);
  }
  Future<void> ReturnApiCall() async {
    setState(() {
      isLoading = true;
    });
    final userId = await SessionManager.getUserId() ?? '';
    final selectedItems = return_invoice!.items
        .where((item) => item.isSelected == true && item.returnQty > 0)
        .map((item) => ReturnItem(
      productId: item.id,
      quantity: item.returnQty,
      rate: double.parse(item.rate),
      batchNo: item.batch,
      expiry:item.expiry,
      gstPercent:double.parse(item.gst),
      discountPercent: double.parse(item.discount), totalAmount: (item.returnQty) * (double.tryParse(item.rate) ?? 0.0),
    ))
        .toList();

    final totalAmount = selectedItems.fold<double>(
      0.0,
          (sum, item) => sum + (item.quantity * item.rate),
    );
    var returnModel = PurchaseReturn(
      id: widget.edit!?widget.edit_id:null,
      storeId:int.parse(userId),
      invoicePurchaseId:return_invoice!.items.first.invoice_purchase_id,
      sellerId:int.parse(return_invoice!.userId!),
      returnDate:DateTime.now().toString(),
      totalAmount:totalAmount,
      reason:'',
      items:selectedItems,
    );
    print(returnModel.toString());
    if(!widget.edit!) {
      context.read<ApiCubit>().StockReturnAdd(returnModel: returnModel);
    }else{
      context.read<ApiCubit>().StockReturnEdit(returnModel: returnModel);
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
              returnList.add(return_invoice!);
              currentIndex = returnList.length - 1;
            });
          } else if (state is GetInvoiceDetailError) {
            setState(() {
              isLoading = false;
            });
            Navigator.pop(context); // Use caution here
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load data: ${state.error}')),
            );
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
                     /* Container(
                        height: 40,
                        width: 140,
                        child: MyElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => EditValueDialog(
                                title: 'Invoice No.',
                                initialValue: '',
                                addMore: (value) {
                                  setState(() {
                                      invoice_No=value;
                                      _fetchStockList();
                                  });
                                },
                              ),
                            );
                          },
                          backgroundColor: AppColors.kPrimaryDark,
                          titleColor: AppColors.kPrimary,
                          custom_design: true,
                          buttonText: "Add More",
                        ),
                      ),*/
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
                        ? Center(child: CircularProgressIndicator())
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
                                          "Invoice No. #${returnList.isEmpty?invoice_No:returnList[currentIndex].invoiceId}",
                                          screenWidth * 0.04,
                                          Colors.green,
                                        ),
                                        SizedBox(height: screenWidth * 0.01),
                                        MyTextfield.textStyle_w400(
                                          'GSTIN: ${return_invoice!.sellerGstin!}',
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

                          const SizedBox(height: 16),

                          // Product List Title
                          MyTextfield.textStyle_w600(
                            'Product Detail',
                            screenWidth * 0.05,
                            Colors.black,
                          ),
                          const SizedBox(height: 10),

                          // Product List
                          returnList.isNotEmpty && currentIndex < returnList.length
                              ? ListView.builder(
                            itemCount: returnList[currentIndex].items.length,
                            padding: EdgeInsets.zero,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final item = returnList[currentIndex].items[index];
                              return ReturnProductTile(
                                product: item,
                                onChecked: (checked) {
                                  setState(() {
                                    item.isSelected = checked;
                                  });
                                },
                                onQtyChanged: (qtyStr) {
                                setState(() {
                                  item.returnQty = int.tryParse(qtyStr) ?? 0;
                                });
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
      floatingActionButton: Row(
        children: [
          if (currentIndex > 0)
            Expanded(
              child:
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      currentIndex--;
                      return_invoice = returnList[currentIndex];
                    });
                  },
                  label:  MyTextfield.textStyle_w600("Previous", AppUtils.size_18, AppColors.kPrimary),
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.kPrimaryLight,side: BorderSide(color: AppColors.kPrimary,width: 1.2)
                  ),
                ),
              ),
            ),
          if (currentIndex > 0) const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left:8,right: 8),
              child: ElevatedButton.icon(
                onPressed: () {


                  setState(() {
                    if (currentIndex == returnList.length - 1) {
                      ReturnApiCall();
                    } else {
                      currentIndex++;
                      return_invoice = returnList[currentIndex];
                    }
                  });

                },
                label: MyTextfield.textStyle_w600(currentIndex == returnList.length - 1 ? "Confirm" : "Next", AppUtils.size_18, AppColors.kWhiteColor),
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

