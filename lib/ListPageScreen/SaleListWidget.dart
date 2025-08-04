import 'package:PixiDrugs/SaleList/sale_details.dart';
import 'package:PixiDrugs/SaleList/sale_model.dart';
import 'package:PixiDrugs/constant/all.dart';

class SaleListWidget extends StatelessWidget {
  final bool isLoading;
  final List<SaleModel> sales;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAddPressed;
  final Function(SaleModel sale) onEditPressed;
  final Function(String id) onDeletePressed;
  final Function(SaleModel sale) onPrintPressed;
  final Function(SaleModel sale) onSharePressed;
  String? role;

  SaleListWidget({
    required this.isLoading,
    required this.sales,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onAddPressed,
    required this.onDeletePressed,
    required this.onEditPressed,
    required this.onPrintPressed,
    required this.onSharePressed,
  });

  void loadUserData() async {
    role = await SessionManager.getRole();
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    loadUserData();
    final filteredSales = sales
        .where((i) =>
        i.customer.name.toLowerCase().contains(searchQuery.toLowerCase()))
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
          : sales.isEmpty
          ? NoItemPage(
        onTap: onAddPressed,
        image: AppImages.no_sale,
        tittle: 'No Sale Record Found',
        description:
        "Please add important details about the sale such as cusomer name, products, quantity, total amount, and payment status.",
        button_tittle: 'Add Sale Record',
      )
          : ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: filteredSales.length,
        itemBuilder: (_, index) {
          final sale = filteredSales[index];
          return _buildSaleCard(sale, screenWidth,context);
        },
      ),
    );
  }

  Widget _buildSaleCard(sale, double screenWidth, BuildContext context) {
    return GestureDetector(
      onTap: (){
        AppRoutes.navigateTo(
          context,
          SaleDetailsPage(sale: sale, edit: false),
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
                child: MyTextfield.textStyle_w600( getInitials(sale.customer.name),screenWidth * 0.045,AppColors.kPrimary) ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyTextfield.textStyle_w800(sale.customer.name,screenWidth * 0.04,AppColors.kPrimary),
                    SizedBox(height: screenWidth * 0.01),
                    MyTextfield.textStyle_w400('Bill No. #${sale.invoiceNo!}',screenWidth * 0.035,Colors.grey.shade700),
                    MyTextfield.textStyle_w400('Dt.${sale.date!}',screenWidth * 0.035,Colors.grey.shade700),
                    SizedBox(height: screenWidth * 0.01),
                    MyTextfield.textStyle_w600("₹${sale.totalAmount.toStringAsFixed(2)}",screenWidth * 0.049,Colors.green),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'print') {
                        onPrintPressed(sale);
                      }else if (value == 'share') {
                        onSharePressed(sale);
                      }else if (value == 'edit') {
                        onEditPressed(sale);
                      } else if (value == 'delete') {
                        onDeletePressed(sale.invoiceNo!.toString());
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'print',
                          child:Row(
                            children: [
                              SvgPicture.asset(AppImages.printer, height: 18, color: AppColors.kBlackColor800),
                              SizedBox(width: 8),
                              MyTextfield.textStyle_w600('Print Bill', 13, AppColors.kBlackColor800),
                            ],
                          )),
                      PopupMenuItem(value: 'share',
                          child:Row(
                            children: [
                              SvgPicture.asset(AppImages.share, height: 18, color: AppColors.kBlackColor800),
                              SizedBox(width: 8),
                              MyTextfield.textStyle_w600('Share', 13, AppColors.kBlackColor800),
                            ],
                          )),
                      PopupMenuItem(value: 'edit',
                          child:Row(
                            children: [
                              SvgPicture.asset(AppImages.edit, height: 18, color: AppColors.kBlackColor800),
                              SizedBox(width: 8),
                              MyTextfield.textStyle_w600('Edit', 13, AppColors.kBlackColor800),
                            ],
                          )),
                      if(role=='owner')
                      PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              SvgPicture.asset(AppImages.delete, height: 18,  color: AppColors.kRedColor,),
                              SizedBox(width: 8),
                              MyTextfield.textStyle_w600('Delete', 13, AppColors.kRedColor),
                            ],
                          )
                      ),
                    ],
                    icon: Icon(Icons.more_vert, size: screenWidth * 0.05),
                  ),
                  SizedBox(height: screenWidth * 0.015),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025, vertical: screenWidth * 0.01),
                    decoration: BoxDecoration(
                      //color: invoice.status == "Paid" ? Colors.green.shade100 : Colors.red.shade100,
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(screenWidth * 0.01),
                    ),
                    child: Text(
                      //invoice.status,
                      'Paid',
                      style: TextStyle(
                        //color: invoice.status == "Paid" ? Colors.green : Colors.red,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.03,
                      ),
                    ),
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
