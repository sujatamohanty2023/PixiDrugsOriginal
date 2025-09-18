import 'package:PixiDrugs/constant/all.dart';
import '../ReturnProduct/ReturnCustomerCart.dart';
import '../customWidget/BottomLoader.dart';
import '../customWidget/GradientInitialsBox.dart';
import 'CustomerReturnsResponse.dart';

class SaleReturnListWidget extends StatefulWidget {
  final bool isLoading;
  final List<CustomerReturnsResponse> items;
  final ScrollController? scrollController;
  final bool hasMoreData;
  final VoidCallback? onRefreshRequested;

  const SaleReturnListWidget({
    required this.isLoading,
    required this.items,
    this.scrollController,
    required this.hasMoreData,
    required this.onRefreshRequested,
  });

  @override
  State<SaleReturnListWidget> createState() => _SaleReturnListWidgetState();
}

class _SaleReturnListWidgetState extends State<SaleReturnListWidget> {

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
        tittle: 'No Customer Return Found',
        description: 'No Customer Return entries available.',
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

  Widget _buildReturnCard(CustomerReturnsResponse item, double screenWidth, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ReturnCustomerCart(customerReturnModel:item,detail: true,),),
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
                name: item.customer.name,
              ),
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
}
