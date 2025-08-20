import 'package:PixiDrugs/Cart/CustomerDetailBottomSheet.dart';
import 'package:PixiDrugs/Cart/address_widget.dart';
import 'package:PixiDrugs/constant/all.dart';
import 'package:PixiDrugs/SaleList/sale_model.dart';

import '../Cart/ProductCard.dart';

class SaleDetailsPage extends StatefulWidget {
  final SaleModel? sale;
  final bool? edit;

  const SaleDetailsPage({
    Key? key,
    required this.sale,
    required this.edit,
  }) : super(key: key);

  @override
  State<SaleDetailsPage> createState() => _SaleDetailsPageState();
}

class _SaleDetailsPageState extends State<SaleDetailsPage> {
  List<InvoiceItem> cartItems=[];
  int billingid=0;
  late String name;
  late String phone;
  late String address;
  double totalPrice = 0.0;
  double subtotalPrice = 0.0;
  double discountAmount = 0.0;

  List<InvoiceItem> convertSaleToInvoiceItems(SaleModel sale) {
    return sale.items.map((item) => InvoiceItem(
      id: item.productId,
      product: item.productName,
      unitMrp: item.price.toString(),
      mrp: item.mrp.toString(),
      qty: item.quantity,
      discountSale: item.discount.toString(),
      unitType: parseUnitType(item.unitType)
    )).toList();
  }
  UnitType parseUnitType(String unit) {
    return UnitType.values.firstWhere(
          (e) => e.name == unit,
      orElse: () => UnitType.Other,
    );
  }
  @override
  void initState() {
    super.initState();
    cartItems = widget.sale != null ? convertSaleToInvoiceItems(widget.sale!) : [];
    name = widget.sale?.customer.name ?? "";
    phone = widget.sale?.customer.phone ?? "";
    address = widget.sale?.customer.address ?? "";
    billingid=widget.sale?.invoiceNo??0;

    _recalculateTotals(cartItems);
  }
  void _recalculateTotals(List<InvoiceItem> cartItems) {
    subtotalPrice = cartItems.fold(0.0, (sum, item) {
      final mrp = double.tryParse(item.unitMrp) ?? 0.0;
      final qty = item.qty;
      return sum + (mrp * qty);
    });

    discountAmount = cartItems.fold(0.0, (sum, item) {
      final mrp = double.tryParse(item.unitMrp) ?? 0.0;
      final qty = item.qty;
      final discountSale = double.tryParse(item.discountSale??'') ?? 0.0;
      final itemDiscount = item.discountType == DiscountType.percent
          ? (mrp * qty) * (discountSale / 100)
          : discountSale * qty;
      return sum + itemDiscount;
    });

    totalPrice = subtotalPrice - discountAmount;
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return BlocListener<ApiCubit, ApiState>(
      listener: (context, state) {
        if (state is SaleEditLoaded) {
          Navigator.pop(context); // Dismiss loading
          AppUtils.showSnackBar(context,state.message);
        } else if (state is SaleEditError) {
          Navigator.pop(context); // Dismiss loading
          AppUtils.showSnackBar(context,'Error: ${state.error}');
        }
      },
      child: Scaffold(
        body: Container(
          color: AppColors.kPrimary,
          width: double.infinity,
          padding: EdgeInsets.only(top: screenWidth * 0.12),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: screenWidth * 0.065),
                    onPressed: () => Navigator.pop(context),
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
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.02),
                  decoration: BoxDecoration(
                   gradient: AppColors.myGradient,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(screenWidth * 0.07),
                      topRight: Radius.circular(screenWidth * 0.07),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 50.0,),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Invoice No: ${widget.sale?.invoiceNo ?? ''}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 8),
                        Text("Date: ${widget.sale?.date ?? ''}"),
                        const SizedBox(height: 8),

                        /// Address Widget with Edit Option
                        addressWidget(
                          name: name,
                          phone: phone,
                          address: address,
                          tap: () async {
                            await checkUserData(name, phone, address);
                          },
                        ),

                        const SizedBox(height: 10),

                        /// Cart Items
                        CustomListView<InvoiceItem>(
                          data: cartItems,
                          physics: const NeverScrollableScrollPhysics(),
                          onTap: _onCartItemTap,
                          itemBuilder: (item) => ProductCard(item: item,
                            editable:widget.edit!,
                            mode: ProductCardMode.cart,
                            onRemove: () {
                              setState(() {
                                cartItems.removeWhere((e) => e.id == item.id);
                              });
                            },onUpdate: () {
                              setState(() {
                                _recalculateTotals(cartItems);
                              });
                            },),
                        ),

                        const SizedBox(height: 15),

                        /// Order Summary
                        PaymentRow(title: "Order Summary", value: "", isBold: true),
                        Divider(color: AppColors.kPrimary.withOpacity(0.1)),
                        PaymentRow(title: "Sub-total", value: "${AppString.Rupees}$subtotalPrice"),
                        PaymentRow(title: "Discount", value: "- ${AppString.Rupees}$discountAmount", color: Colors.green),
                        Divider(color: AppColors.kPrimary.withOpacity(0.1)),
                        PaymentRow(
                          title: "Total",
                          value: "${AppString.Rupees}${totalPrice.toStringAsFixed(2)}",
                          isBold: true,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: widget.edit!
            ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                        height: 50,
                        width: double.infinity,
                        child: MyElevatedButton(
              onPressed: () {
                if (address != null && address.isNotEmpty) {
                  _UpdateApiCall();
                } else {
                  checkUserData(name, phone, address);
                }
              },
              custom_design: false,
              buttonText: "Update" ,
                        ),
                      ),
            )
            : const SizedBox(),
      ),
    );
  }
  Future<void> _UpdateApiCall() async {
    String? userId = await SessionManager.getParentingId();


      if (cartItems.isEmpty) {
        AppUtils.showSnackBar(context,'Your cart is empty');
        return;
      }

      final model = OrderPlaceModel(
        cartItems: cartItems,
        seller_id: userId!,
        name: name,
        phone: phone,
        email: '',
        address: address,
      );
      print('API URL: ${model.toString()}');
      _showLoadingDialog(); // Show loading
      context.read<ApiCubit>().SaleEdit(billingid:billingid.toString(),orderPlaceModel: model);

  }
  void _showLoadingDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.kPrimary),
      ),
    );
  }
  void _onCartItemTap(InvoiceItem item) {}
  Future<void> checkUserData(String name, String phone, String address) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.kWhiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
      ),
      constraints: BoxConstraints.loose(Size(
        SizeConfig.screenWidth!,
        SizeConfig.screenHeight! * 0.60,
      )),
      isScrollControlled: true,
      builder: (_) => CustomerDetailBottomSheet(
        name: name,
        phone: phone,
        address: address,
        onSubmit: (name1, phone1, submittedAddress1) {
          setState(() {
            this.name = name1;
            this.phone = phone1;
            this.address = submittedAddress1;
          });

          context.read<CartCubit>().setBarcodeCustomerDetails(
            name: name1,
            phone: phone1,
            address: submittedAddress1,
          );
        },
      ),
    );
  }
}

/// Helper to get initials
String getInitials(String name) {
  if (name.isEmpty) return "";
  List<String> parts = name.trim().split(" ");
  String initials = "";
  if (parts.isNotEmpty) initials += parts[0][0];
  if (parts.length > 1) initials += parts[1][0];
  return initials.toUpperCase();
}
