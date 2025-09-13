import 'package:PixiDrugs/Ledger/LedgerDetailsPage.dart';
import 'package:PixiDrugs/Ledger/LedgerModel.dart';
import 'package:PixiDrugs/constant/all.dart';

import '../customWidget/BottomLoader.dart';
import '../customWidget/GradientInitialsBox.dart';

class LedgerListWidget extends StatefulWidget {
  final bool isLoading;
  final List<LedgerModel> items;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final ScrollController? scrollController;
  final bool hasMoreData;
  final VoidCallback? onRefreshRequested;

  const LedgerListWidget({
    required this.isLoading,
    required this.items,
    required this.searchQuery,
    required this.onSearchChanged,
    this.scrollController,
    required this.hasMoreData,
    required this.onRefreshRequested,
  });

@override
State<LedgerListWidget> createState() => _LedgerListWidgetState();
}

class _LedgerListWidgetState extends State<LedgerListWidget> {

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final filteredLedger = widget.items
        .where((i) =>
        i.sellerName.toLowerCase().contains(widget.searchQuery.toLowerCase()))
        .toList();
    final itemCount = filteredLedger.length + (widget.hasMoreData  ? 1 : 0);
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
        tittle: 'No Ledger Record Found',
        description:
        "Please add important details about the new party such as name, address, GSTIN, total due amount",
        button_tittle: /*'Add New Party'*/'',
      )
          : ListView.builder(
        controller: widget.scrollController,
        padding: EdgeInsets.zero,
        itemCount: itemCount,
        itemBuilder: (_, index) {
          if (index >= filteredLedger.length) {
            return BottomLoader();
          }
          return _buildLedgerCard(filteredLedger[index], screenWidth,context);
        },
      ),
    );
  }

  Widget _buildLedgerCard(LedgerModel item, double screenWidth, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LedgerDetailsPage(ledger: item),),
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
                name: item.sellerName,
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyTextfield.textStyle_w800(item.sellerName,screenWidth * 0.04,AppColors.kPrimary),
                    SizedBox(height: screenWidth * 0.01),
                    MyTextfield.textStyle_w400('GSTIN: ${item.gstNo}',screenWidth * 0.035,Colors.grey.shade700,maxLines: true),
                    MyTextfield.textStyle_w600("Credit: ₹${item.totalCredit}", screenWidth * 0.035, Colors.green),
                    MyTextfield.textStyle_w600("Debit: ₹${item.totalDebit}", screenWidth * 0.035, Colors.orange),
                    SizedBox(height: screenWidth * 0.01)
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                   /*GestureDetector(
                    onTap: () {
                      launchUrl(Uri.parse("tel:+91${item.phone}"));
                    },
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.call, color: Colors.green, size: 25),
                    ),
                  ),*/
                  SizedBox(height: screenWidth * 0.015),
                  Builder(
                    builder: (context) {
                      Color amountColor = item.dueAmount.contains('-')
                          ? Colors.red
                          : Colors.green;

                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025, vertical: screenWidth * 0.01),
                        decoration: BoxDecoration(
                          color: amountColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(screenWidth * 0.02),
                        ),
                        child: MyTextfield.textStyle_w600(
                          "₹${item.dueAmount}",
                          screenWidth * 0.04,
                          amountColor,
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
