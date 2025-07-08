import 'package:pixidrugs/constant/all.dart';
import 'package:pixidrugs/SaleList/sale_model.dart';

class SaleDetailsPage extends StatelessWidget {
  final SaleModel sale;

  const SaleDetailsPage({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Sale Details'),
      //   backgroundColor: Colors.blue,
      // ),
      body: Container(
        color: AppColors.kPrimary,
        width: double.infinity,
        padding: EdgeInsets.only(top: screenWidth * 0.12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white, size: screenWidth * 0.065),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Text(
                      'Sale Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // IconButton(
                //   icon: Icon(Icons.notifications, color: Colors.white, size: screenWidth * 0.065),
                //   onPressed: () {},
                // )
              ],
            ),
            SizedBox(height: 10,),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(screenWidth * 0.07),
                    topLeft: Radius.circular(screenWidth * 0.07),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Invoice No: ${sale.invoiceNo}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    SizedBox(height: 8),
                    Text("Date: ${sale.date}"),
                    SizedBox(height: 8),
                    Text("Customer: ${sale.customer.name}"),
                    Text("Email: ${sale.customer.email}"),
                    SizedBox(height: 16),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Amount:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("₹${sale.totalAmount.toStringAsFixed(2)}"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Profit:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("₹${sale.profit.toStringAsFixed(2)}"),
                      ],
                    ),
                    Divider(height: 30),
                    Text("Products", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: ListView.builder(
                        itemCount: sale.items.length,
                        itemBuilder: (context, index) {
                          final item = sale.items[index];
                          return Card(
                            color: Colors.white,
                            // margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenWidth * 0.015),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.03)),
                            child: IntrinsicHeight(
                              child: Row(
                                children: [
                                  // ClipRRect(
                                  //   borderRadius: BorderRadius.only(
                                  //     topLeft: Radius.circular(screenWidth * 0.03),
                                  //     bottomLeft: Radius.circular(screenWidth * 0.03),
                                  //   ),
                                  //   child: Container(
                                  //     width: screenWidth * 0.015,
                                  //     color: AppColor.myColor, // You can change color logic if needed
                                  //   ),
                                  // ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.all(screenWidth * 0.02),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: screenWidth * 0.08,
                                            backgroundColor: AppColors.kPrimary.withOpacity(0.1),
                                            child: Text(
                                              getInitials(item.productName),
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
                                                Text(item.productName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04)),
                                                SizedBox(height: screenWidth * 0.01),
                                                Text("Qty: ${item.quantity}", style: TextStyle(color: Colors.grey.shade600, fontSize: screenWidth * 0.03)),
                                                SizedBox(height: screenWidth * 0.01),
                                                Text("Price: ₹${item.price}", style: TextStyle(color: Colors.grey.shade700, fontSize: screenWidth * 0.035)),
                                                SizedBox(height: screenWidth * 0.01),
                                                Row(
                                                  children: [
                                                    Icon(Icons.discount,size: 20,),
                                                    Text("${item.discount}%", style: TextStyle(color: Colors.orange, fontSize: screenWidth * 0.035)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [

                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025, vertical: screenWidth * 0.01),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.shade100,
                                                  borderRadius: BorderRadius.circular(screenWidth * 0.01),
                                                ),
                                                child: Text(
                                                  "Profit: ₹${item.itemProfit}",
                                                  style: TextStyle(
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
                                ],
                              ),
                            ),
                          );

                        },
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
String getInitials(String name) {
  if (name.isEmpty) return "";
  List<String> parts = name.split(" ");
  String initials = "";
  if (parts.isNotEmpty) initials += parts[0][0];
  if (parts.length > 1) initials += parts[1][0];
  return initials.toUpperCase();
}

