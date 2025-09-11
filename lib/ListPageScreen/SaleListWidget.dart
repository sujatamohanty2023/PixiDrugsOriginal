import 'package:PixiDrugs/SaleList/sale_details.dart';
import 'package:PixiDrugs/SaleList/sale_model.dart';
import 'package:PixiDrugs/constant/all.dart';

import '../customWidget/BottomLoader.dart';
import '../customWidget/CustomPopupMenuItemData.dart';
import '../customWidget/GradientInitialsBox.dart';

class SaleListWidget extends StatefulWidget {
  final bool isLoading;
  final List<SaleModel> sales;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAddPressed;
  final Function(SaleModel sale) onEditPressed;
  final Function(int id) onDeletePressed;
  final Function(SaleModel sale) onPrintPressed;
  final Function(SaleModel sale) onSharePressed;
  final Function(SaleModel sale) onDownloadPressed;
  final ScrollController? scrollController;
  final bool hasMoreData;

  const SaleListWidget({
    required this.isLoading,
    required this.sales,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onAddPressed,
    required this.onDeletePressed,
    required this.onEditPressed,
    required this.onPrintPressed,
    required this.onSharePressed,
    required this.onDownloadPressed,
    this.scrollController,
    required this.hasMoreData,
    Key? key,
  }) : super(key: key);

  @override
  State<SaleListWidget> createState() => _SaleListWidgetState();
}

class _SaleListWidgetState extends State<SaleListWidget> {
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
    final filteredSales = widget.sales
        .where((i) =>
        i.customer.name.toLowerCase().contains(widget.searchQuery.toLowerCase()))
        .toList();
    final itemCount = filteredSales.length + (widget.hasMoreData  ? 1 : 0);

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
          : widget.sales.isEmpty
          ? NoItemPage(
        onTap: widget.onAddPressed,
        image: AppImages.no_sale,
        tittle: 'No Sale Record Found',
        description:
        "Please add important details about the sale such as cusomer name, products, quantity, total amount, and payment status.",
        button_tittle: 'Add Sale Record',
      )
          : ListView.builder(
        controller: widget.scrollController,
        padding: EdgeInsets.zero,
        itemCount: itemCount,
        itemBuilder: (_, index) {
          if (index >= filteredSales.length) {
            return BottomLoader();
          }
          return _buildSaleCard(filteredSales[index], screenWidth,context);
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
              GradientInitialsBox(
                size: screenWidth * 0.15,
                name: sale.customer.name,
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyTextfield.textStyle_w800(sale.customer.name,screenWidth * 0.04,AppColors.kPrimary),
                    SizedBox(height: screenWidth * 0.01),
                    sale.customer.phone.isNotEmpty && sale.customer.phone!='no number'?
                    MyTextfield.textStyle_w400('Mob: ${sale.customer.phone}',screenWidth * 0.035,Colors.green.shade700):
                    MyTextfield.textStyle_w400('Email: ${sale.customer.email}',screenWidth * 0.035,Colors.deepOrange.shade700),
                    MyTextfield.textStyle_w400('Bill No. #${sale.invoiceNo!}',screenWidth * 0.035,Colors.grey.shade700),
                    MyTextfield.textStyle_w400('Dt.${sale.date!}',screenWidth * 0.035,Colors.grey.shade700),
                    SizedBox(height: screenWidth * 0.01),
                    MyTextfield.textStyle_w600("₹${sale.totalAmount}",screenWidth * 0.049,Colors.green),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomPopupMenu(
                    iconSize: screenWidth * 0.05,
                    backgroundColor: AppColors.kWhiteColor,
                    onSelected: (value) {
                      switch (value) {
                        case 'print':
                          widget.onPrintPressed(sale);
                          break;
                        case 'share':
                          widget.onSharePressed(sale);
                          break;
                        case 'edit':
                          widget.onEditPressed(sale);
                          break;
                        case 'delete':
                          widget.onDeletePressed(sale.invoiceNo!);
                          break;
                        case 'download':
                          widget.onDownloadPressed(sale.invoiceNo!);
                          break;
                      }
                    },
                    items: [
                      CustomPopupMenuItemData(
                        value: 'print',
                        label: 'Print Bill',
                        iconAsset: AppImages.printer,
                      ),
                      if (sale.customer.phone.isNotEmpty && sale.customer.phone != 'no number')
                        CustomPopupMenuItemData(
                          value: 'share',
                          label: 'Share',
                          iconAsset: AppImages.share,
                        ),
                      CustomPopupMenuItemData(
                        value: 'download',
                        label: 'Download',
                        iconAsset: AppImages.download,
                      ),
                      CustomPopupMenuItemData(
                        value: 'edit',
                        label: 'Edit',
                        iconAsset: AppImages.edit,
                      ),
                      if (role == 'owner')
                        CustomPopupMenuItemData(
                          value: 'delete',
                          label: 'Delete',
                          iconAsset: AppImages.delete,
                          textColor: AppColors.kRedColor,
                        ),
                    ],
                  ),
                  SizedBox(height: screenWidth * 0.015),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025, vertical: screenWidth * 0.01),
                    decoration: BoxDecoration(
                      color: sale.paymentType != "Due" ? Colors.green.shade100 : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(screenWidth * 0.01),
                    ),
                    child: MyTextfield.textStyle_w400( sale.paymentType,screenWidth * 0.03,sale.paymentType != "Due" ? Colors.green : Colors.red),
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
