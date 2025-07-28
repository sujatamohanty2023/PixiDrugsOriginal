import 'package:PixiDrugs/constant/all.dart';
import 'package:PixiDrugs/StockReturn/ReturnProductTile.dart';

import 'BillingModel.dart';
import 'SaleReturnProductTile.dart';
import 'SaleReturnRequest.dart';

class SaleReturnScreen extends StatefulWidget {
  final String billNo;
  const SaleReturnScreen({Key? key,required this.billNo}) : super(key: key);

  @override
  State<SaleReturnScreen> createState() => _SaleReturnScreenState();
}

class _SaleReturnScreenState extends State<SaleReturnScreen> {
  Billing? returnBill;
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchBillDetail();
  }

  Future<void> _fetchBillDetail() async {
    setState(() {
      isLoading = true;
    });
    final userId = await SessionManager.getUserId() ??'';
    context.read<ApiCubit>().GetSaleBillDetail(bill_id: widget.billNo,store_id: userId);
  }
  Future<void> ReturnApiCall() async {
    setState(() {
      isLoading = true;
    });
    final userId = await SessionManager.getUserId() ?? '';
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
      storeId:int.parse(userId),
      billingId:returnBill!.billingId,
      customerId:returnBill!.customerId,
      returnDate:DateTime.now().toString(),
      totalAmount:totalAmount,
      reason:'',
      items:selectedItems,
    );
    print(returnModel.toString());
    context.read<ApiCubit>().SaleReturnAdd(returnModel: returnModel);
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
            });
          } else if (state is GetSaleBillDetailError) {
            setState(() {
              isLoading = false;
            });
            Navigator.pop(context); // Use caution here
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load data: ${state.error}')),
            );
          }else if (state is SaleReturnAddLoaded) {
            setState(() {
              isLoading = false;
              if(state.success) {
                Navigator.pop(context); // Use caution here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Successfully retrun')),
                );
              }else{
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Failed to add SaleReturn')),
                );
              }
            });
          } else if (state is SaleReturnAddError) {
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
                            'Customer Return',
                            screenWidth * 0.055,
                            Colors.white,
                          ),
                        ],
                      ),
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
                        ? Center(child: CircularProgressIndicator())
                        :  SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),

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

