import 'package:PixiDrugs/constant/all.dart';

class InvoiceListWidget extends StatelessWidget {
  final bool isLoading;
  final List<Invoice> invoices;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAddPressed;
  final Function(Invoice invoice) onEditPressed;
  final Function(String id) onDeletePressed;

  const InvoiceListWidget({
    required this.isLoading,
    required this.invoices,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onAddPressed,
    required this.onDeletePressed,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final filteredInvoices = invoices
        .where((i) =>
        i.sellerName!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: AppColors.myGradient,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(screenWidth * 0.07),
              topRight: Radius.circular(screenWidth * 0.07),
            ),
          ),
          child: isLoading
              ? Center(child: CircularProgressIndicator(color: AppColors.kPrimary,))
              : invoices.isEmpty
              ? NoItemPage(
            onTap: onAddPressed,
            image: AppImages.no_invoice,
            tittle: 'Add an Invoice record.',
            description:
            "Please add your invoice details for better tracking.",
            button_tittle: 'Add Invoice',
          )
              : ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: filteredInvoices.length,
            itemBuilder: (_, index) {
              final invoice = filteredInvoices[index];
              return buildInvoiceCard(context,invoice, screenWidth);
            },
          ),
        ),
        // FAB Positioned at bottom right
        invoices.isNotEmpty?Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: onAddPressed,
            backgroundColor: AppColors.kPrimary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ):SizedBox(),
        ]
    );
  }

  Widget buildInvoiceCard(BuildContext context,Invoice invoice, double screenWidth) {
    return GestureDetector(
      onTap: (){
        AppRoutes.navigateTo(context, InvoiceSummaryPage(details: true,invoice: invoice));
      },
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenWidth * 0.015),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.03)),
        child: IntrinsicHeight(
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screenWidth * 0.03),
                  bottomLeft: Radius.circular(screenWidth * 0.03),
                ),
                child: Container(
                  width: screenWidth * 0.015,
                  color: AppColors.kPrimary,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: screenWidth * 0.08,
                        backgroundColor: AppColors.kPrimaryDark,
                        child:MyTextfield.textStyle_w600( getInitials(invoice.sellerName!),screenWidth * 0.045,AppColors.kPrimary) ),
                      SizedBox(width: screenWidth * 0.03),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyTextfield.textStyle_w800(invoice.sellerName!,screenWidth * 0.04,AppColors.kPrimary),
                            SizedBox(height: screenWidth * 0.01),
                            MyTextfield.textStyle_w400('Invoice No. #${invoice.invoiceId!}',screenWidth * 0.035,Colors.grey.shade700),
                            MyTextfield.textStyle_w400('Dt.${invoice.invoiceDate!}',screenWidth * 0.035,Colors.grey.shade700),
                            SizedBox(height: screenWidth * 0.01),
                            MyTextfield.textStyle_w600("₹${invoice.netAmount!}",screenWidth * 0.049,Colors.green),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                onEditPressed(invoice);
                              } else if (value == 'delete') {
                                onDeletePressed(invoice.invoiceId!);
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
