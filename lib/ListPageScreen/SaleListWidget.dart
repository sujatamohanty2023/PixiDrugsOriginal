import 'package:pixidrugs/SaleList/sale_details.dart';
import 'package:pixidrugs/SaleList/sale_model.dart';
import 'package:pixidrugs/constant/all.dart';

class SaleListWidget extends StatelessWidget {
  final bool isLoading;
  final List<SaleModel> sales;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAddPressed;
  final Function(SaleModel sale) onEditPressed;
  final Function(String id) onDeletePressed;

  const SaleListWidget({
    required this.isLoading,
    required this.sales,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onAddPressed,
    required this.onDeletePressed,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final filteredSales = sales
        .where((i) =>
        i.customer.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return  Expanded(
      child: Container(
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
          image: AppImages.add_invoice,
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
                child: Text(
                  getInitials(sale.customer.name),
                  style: TextStyle(
                    color: AppColors.kPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.045,
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sale.customer.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04)),
                    SizedBox(height: screenWidth * 0.01),
                    Text("Invoice No: #${sale.invoiceNo}", style: TextStyle(color: Colors.grey.shade700, fontSize: screenWidth * 0.035)),
                    SizedBox(height: screenWidth * 0.01),
                    Text(sale.date, style: TextStyle(color: Colors.grey.shade600, fontSize: screenWidth * 0.03)),
                    SizedBox(height: screenWidth * 0.01),
                    Text(
                      "₹${sale.totalAmount.toStringAsFixed(2)}",
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.045),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEditPressed(sale);
                      } else if (value == 'delete') {
                        onDeletePressed(sale.invoiceNo!.toString());
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'edit',
                          child:Row(
                            children: [
                              Icon(Icons.edit, color: Colors.black),
                              SizedBox(width: 8),
                              MyTextfield.textStyle_w600('Edit', 13, Colors.black),
                            ],
                          )),
                      PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                AppImages.delete,
                                height: 18,
                                width: 18,
                                color: AppColors.kRedColor,
                              ),
                              SizedBox(width: 8),
                              MyTextfield.textStyle_w600('Delete', 13, Colors.black),
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
