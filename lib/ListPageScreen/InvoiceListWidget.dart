import '../constant/all.dart';
import '../customWidget/BottomLoader.dart';
import '../customWidget/GradientInitialsBox.dart';

class InvoiceListWidget extends StatefulWidget {
  final bool isLoading;
  final List<Invoice> invoices;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAddPressed;
  final Function(Invoice) onEditPressed;
  final Function(int) onDeletePressed;
  final ScrollController? scrollController;
  final bool hasMoreData;

  const InvoiceListWidget({
    required this.isLoading,
    required this.invoices,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onAddPressed,
    required this.onDeletePressed,
    required this.onEditPressed,
    this.scrollController,
    required this.hasMoreData,
    Key? key,
  }) : super(key: key);

  @override
  State<InvoiceListWidget> createState() => _InvoiceListWidgetState();
}

class _InvoiceListWidgetState extends State<InvoiceListWidget> {
  String? role;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    role = await SessionManager.getRole();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final filteredInvoices = widget.invoices
        .where((i) => i.sellerName!
        .toLowerCase()
        .contains(widget.searchQuery.toLowerCase()))
        .toList();
    final itemCount = filteredInvoices.length + (widget.hasMoreData  ? 1 : 0);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: AppColors.myGradient,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(screenWidth * 0.07),
            ),
          ),
          child: widget.isLoading
              ? Center(child: CircularProgressIndicator(color: AppColors.kPrimary))
              : widget.invoices.isEmpty
              ? NoItemPage(
            onTap: widget.onAddPressed,
            image: AppImages.no_invoice,
            tittle: 'Add an Invoice record.',
            description: "Please add your invoice details for better tracking.",
            button_tittle: 'Add Invoice',
          )
              : ListView.builder(
            controller: widget.scrollController,
            padding: EdgeInsets.zero,
            itemCount: itemCount,
            itemBuilder: (_, index) {
              if (index >= filteredInvoices.length) {
                return BottomLoader();
              }
              return _buildInvoiceCard(filteredInvoices[index], screenWidth,index);
            },
          ),
        ),
        if (widget.invoices.isNotEmpty)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: widget.onAddPressed,
              backgroundColor: AppColors.kPrimary,
              child: Icon(Icons.add, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildInvoiceCard(Invoice invoice, double screenWidth,int index) {
    return GestureDetector(
      onTap: () => AppRoutes.navigateTo(
          context, InvoiceSummaryPage(details: true, invoice: invoice)),
      child: Card(
        color: AppColors.kWhiteColor,
        margin: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.03, vertical: screenWidth * 0.015),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
        ),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(screenWidth * 0.03)),
                child: Container(
                  width: screenWidth * 0.015,
                  color: AppColors.kPrimary,
                ),
              ),
              GradientInitialsBox(
                size: screenWidth * 0.15,
                name: invoice.sellerName!,
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyTextfield.textStyle_w800(
                        invoice.sellerName!, screenWidth * 0.04, AppColors.kPrimary),
                    SizedBox(height: screenWidth * 0.01),
                    MyTextfield.textStyle_w400(
                        'Invoice No. #${invoice.invoiceId!}',
                        screenWidth * 0.035,
                        Colors.grey.shade700),
                    MyTextfield.textStyle_w400('Dt.${invoice.invoiceDate!}',
                        screenWidth * 0.035, Colors.grey.shade700),
                    SizedBox(height: screenWidth * 0.01),
                    MyTextfield.textStyle_w600(
                        "₹${invoice.netAmount!}", screenWidth * 0.049, Colors.green),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: AppColors.kWhiteColor,
                elevation: 10,
                onSelected: (value) {
                  if (value == 'edit') widget.onEditPressed(invoice);
                  if (value == 'delete') widget.onDeletePressed(invoice.id!);
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        SvgPicture.asset(AppImages.edit,
                            height: 18, color: AppColors.kPrimary),
                        SizedBox(width: 8),
                        MyTextfield.textStyle_w600('Edit', 13, AppColors.kPrimary),
                      ],
                    ),
                  ),
                  if (role == 'owner')
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          SvgPicture.asset(AppImages.delete,
                              height: 18, width: 18, color: AppColors.kRedColor),
                          SizedBox(width: 8),
                          MyTextfield.textStyle_w600(
                              'Delete', 13, AppColors.kRedColor),
                        ],
                      ),
                    ),
                ],
                icon: Icon(Icons.more_vert, size: screenWidth * 0.05),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
