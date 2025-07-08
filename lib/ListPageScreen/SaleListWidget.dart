import 'package:pixidrugs/SaleList/sale_model.dart';
import 'package:pixidrugs/constant/all.dart';
import '../SaleList/sale_details.dart';

class SaleListWidget extends StatelessWidget {
  final bool isLoading;
  final List<SaleModel> sales;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAddPressed;

  const SaleListWidget({
    required this.isLoading,
    required this.sales,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onAddPressed,
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
            ? Center(child: CircularProgressIndicator())
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
    return Card(
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
                  Text("Invoice No: ${sale.invoiceNo}", style: TextStyle(color: Colors.grey.shade700, fontSize: screenWidth * 0.035)),
                  SizedBox(height: screenWidth * 0.01),
                  Text(sale.date, style: TextStyle(color: Colors.grey.shade600, fontSize: screenWidth * 0.03)),
                  Text(
                    "₹${sale.totalAmount.toStringAsFixed(2)}",
                    style: TextStyle(color: AppColors.kPrimary, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.045),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios, size: screenWidth * 0.05),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SaleDetailsPage(sale: sale),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String getInitials(String name) {
    final parts = name.trim().split(' ');
    return parts.take(2).map((e) => e[0].toUpperCase()).join();
  }
}
