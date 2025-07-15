import 'package:pixidrugs/Ledger/LedgerDetailsPage.dart';
import 'package:pixidrugs/Ledger/LedgerModel.dart';
import 'package:pixidrugs/constant/all.dart';

class LedgerListWidget extends StatelessWidget {
  final bool isLoading;
  final List<LedgerModel> items;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;

  const LedgerListWidget({
    required this.isLoading,
    required this.items,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final filteredSales = items
        .where((i) =>
        i.sellerName.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return  Container(
      decoration: BoxDecoration(
        gradient: AppColors.myGradient,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(screenWidth * 0.07),
          topRight: Radius.circular(screenWidth * 0.07),
        ),
      ),
      child: isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.kPrimary,))
          : items.isEmpty
          ? NoItemPage(
        onTap: (){},
        image: AppImages.no_sale,
        tittle: 'No Ledger Record Found',
        description:
        "Please add important details about the new party such as name, address, GSTIN, total due amount",
        button_tittle: 'Add New Party',
      )
          : ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: filteredSales.length,
        itemBuilder: (_, index) {
          final item = filteredSales[index];
          return _buildLedgerCard(item, screenWidth,context);
        },
      ),
    );
  }

  Widget _buildLedgerCard(LedgerModel item, double screenWidth, BuildContext context) {
    return GestureDetector(
      onTap: (){
        AppRoutes.navigateTo(
          context,
          LedgerDetailsPage(ledger: item),
        );
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
                  child: MyTextfield.textStyle_w600( getInitials(item.sellerName),screenWidth * 0.045,AppColors.kPrimary) ),
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
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025, vertical: screenWidth * 0.01),
                    decoration: BoxDecoration(
                      //color: invoice.status == "Paid" ? Colors.green.shade100 : Colors.red.shade100,
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(screenWidth * 0.01),
                    ),
                    child:MyTextfield.textStyle_w600("₹${item.dueAmount}", screenWidth * 0.04, Colors.red),
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
