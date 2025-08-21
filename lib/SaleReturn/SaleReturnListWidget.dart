import 'package:PixiDrugs/constant/all.dart';
import 'package:PixiDrugs/StockReturn/PurchaseReturnModel.dart';

import '../Cart/CartTab.dart';
import '../ListPageScreen/ListScreen.dart';
import 'BillingModel.dart';
import 'CustomerReturnsResponse.dart';
import 'SaleReturnScreen.dart';

class SaleReturnListWidget extends StatefulWidget {
  final bool isLoading;
  final List<CustomerReturnsResponse> items;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;

  const SaleReturnListWidget({
    required this.isLoading,
    required this.items,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  State<SaleReturnListWidget> createState() => _SaleReturnListWidgetState();
}

class _SaleReturnListWidgetState extends State<SaleReturnListWidget> {

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final filteredSales = widget.items
        .where((i) =>
        i.customer.name.toLowerCase().contains(widget.searchQuery.toLowerCase()))
        .toList();
    return  Container(
      decoration: BoxDecoration(
        gradient: AppColors.myGradient,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(screenWidth * 0.07),
          topRight: Radius.circular(screenWidth * 0.07),
        ),
      ),
      child: widget.isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.kPrimary,))
          : widget.items.isEmpty
          ? NoItemPage(
        onTap: (){},
        image: AppImages.no_sale,
        tittle: 'No Customer Return Found',
        description: 'No Customer Return entries available.',
        button_tittle: '',
      )
          : ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: filteredSales.length,
        itemBuilder: (_, index) {
          final item = filteredSales[index];
          return _buildReturnCard(item, screenWidth,context);
        },
      ),
    );
  }

  Widget _buildReturnCard(CustomerReturnsResponse item, double screenWidth, BuildContext context) {
    return GestureDetector(
      onTap: (){
        //AppRoutes.navigateTo(context, SaleReturnScreen(billNo:item.billingId,returnModel: item));
        AppRoutes.navigateTo(context, CartTab(cartTypeSelection:CartTypeSelection.CustomerReturn,returnModel:item,detail: true,));
      },
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenWidth * 0.015),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.03)),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: Row(
            children: [
              CircleAvatar(
                  radius: screenWidth * 0.08,
                  backgroundColor: AppColors.kPrimaryDark,
                  child: MyTextfield.textStyle_w600( getInitials(item.customer.name),screenWidth * 0.045,AppColors.kPrimary) ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyTextfield.textStyle_w800(item.customer.name,screenWidth * 0.04,AppColors.kPrimary),
                    SizedBox(height: screenWidth * 0.01),
                    MyTextfield.textStyle_w400('Dt: ${item.returnDate}',screenWidth * 0.035,Colors.grey.shade700,maxLines: true),
                    MyTextfield.textStyle_w600("Return item: ${item.items.length}", screenWidth * 0.035, Colors.green),
                    MyTextfield.textStyle_w600("Reason: ${item.reason}", screenWidth * 0.035, Colors.redAccent),
                    SizedBox(height: screenWidth * 0.01)
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(height: screenWidth * 0.015),
                  Builder(
                    builder: (context) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025, vertical: screenWidth * 0.01),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(screenWidth * 0.02),
                        ),
                        child: MyTextfield.textStyle_w600(
                          "₹${item.totalAmount}",
                          screenWidth * 0.04,
                          Colors.green,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getInitials(String name) {
    final parts = name.trim().split(' ');
    return parts.take(2).map((e) => e[0].toUpperCase()).join();
  }
}
