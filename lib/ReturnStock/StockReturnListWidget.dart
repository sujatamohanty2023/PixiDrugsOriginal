import 'package:PixiDrugs/constant/all.dart';
import '../ReturnProduct/ReturnStockiestCart.dart';
import '../ReturnStock/PurchaseReturnModel.dart';
import '../customWidget/BottomLoader.dart';
import '../customWidget/GradientInitialsBox.dart';

class StockReturnListWidget extends StatefulWidget {
  final bool isLoading;
  final List<PurchaseReturnModel> items;
  final ScrollController? scrollController;
  final bool hasMoreData;
  final VoidCallback? onRefreshRequested;
  const StockReturnListWidget({
    required this.isLoading,
    required this.items,
    this.scrollController,
    required this.hasMoreData,
    required this.onRefreshRequested,
  });

  @override
  State<StockReturnListWidget> createState() => _StockReturnListWidgetState();
}

class _StockReturnListWidgetState extends State<StockReturnListWidget> {

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemCount = widget.items.length + (widget.hasMoreData ? 1 : 0);
    return  Container(
      child: widget.isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.kPrimary,))
          : !widget.isLoading && widget.items.isEmpty
          ? NoItemPage(
        onTap: (){},
        image: AppImages.no_sale,
        tittle: 'No Stock Return Found',
        description: 'No stock StockReturn entries available. Upload invoices or create a StockReturn entry to get started.',
        button_tittle: '',
      )
          : ListView.builder(
        controller: widget.scrollController,
        padding: EdgeInsets.zero,
        itemCount: itemCount,
        itemBuilder: (_, index) {
          if (index >= widget.items.length) {
            return BottomLoader();
          }
          return _buildReturnCard(widget.items[index], screenWidth,context);
        },
      ),
    );
  }

  Widget _buildReturnCard(PurchaseReturnModel item, double screenWidth, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ReturnStockiestCart(purchaseReturnModel:item,detail: true,),),
        );
        if (result==true) {
          widget.onRefreshRequested?.call();
        }
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
              GradientInitialsBox(
                size: screenWidth * 0.15,
                name: item.sellerName!,
              ),
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
}
