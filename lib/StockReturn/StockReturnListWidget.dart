import 'package:PixiDrugs/constant/all.dart';
import 'package:PixiDrugs/StockReturn/PurchaseReturnModel.dart';

import '../ListPageScreen/ListScreen.dart';
import 'PurchaseReturnScreen.dart';

class StockReturnListWidget extends StatefulWidget {
  final bool isLoading;
  final List<PurchaseReturnModel> items;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  const StockReturnListWidget({
    required this.isLoading,
    required this.items,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  State<StockReturnListWidget> createState() => _StockReturnListWidgetState();
}

class _StockReturnListWidgetState extends State<StockReturnListWidget> {

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final filteredSales = widget.items.where((i) {
      if (i.items.isEmpty) return false;
      return i.items.first.productName!
          .toLowerCase()
          .contains(widget.searchQuery.toLowerCase());
    }).toList();
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
        tittle: 'No Stock Return Found',
        description: 'No stock StockReturn entries available. Upload invoices or create a StockReturn entry to get started.',
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

  Widget _buildReturnCard(PurchaseReturnModel item, double screenWidth, BuildContext context) {
    return GestureDetector(
      onTap: (){
        AppRoutes.navigateTo(context, PurchaseReturnScreen(invoiceNo:item.invoiceNo!,returnModel: item));
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
                  child: MyTextfield.textStyle_w600( getInitials(item.sellerName!),screenWidth * 0.045,AppColors.kPrimary) ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyTextfield.textStyle_w800(item.sellerName!,screenWidth * 0.04,AppColors.kPrimary),
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
