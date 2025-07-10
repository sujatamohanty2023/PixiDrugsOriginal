import 'package:intl/intl.dart';
import 'package:pixidrugs/ListPageScreen/ListScreen.dart';
import 'package:pixidrugs/constant/all.dart';

class InvoiceSummaryPage extends StatefulWidget {
  final Invoice invoice;
  final bool? edit;
  final bool? details;

  InvoiceSummaryPage({super.key, required this.invoice, this.edit = false,this.details = false});

  @override
  State<InvoiceSummaryPage> createState() => _InvoiceSummaryPageState();
}

class _InvoiceSummaryPageState extends State<InvoiceSummaryPage> {
  late Invoice invoice;

  @override
  void initState() {
    super.initState();
    invoice = widget.invoice;

    context.read<ApiCubit>().stream.listen((state) {
      handleApiState(context, state);
    });
  }
  void handleApiState(BuildContext context, ApiState state) {
    if (state is InvoiceAddLoaded || state is InvoiceEditLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state is InvoiceAddLoaded ? state.message : (state as InvoiceEditLoaded).message)),
      );

      // Navigate to the listing page after a short delay
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => ListScreen(type:state is InvoiceAddLoaded || state is InvoiceEditLoaded ?'invoice':'sale')),
              (route) => false,
        );
      });
    } else if (state is InvoiceAddError || state is InvoiceEditError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
          state is InvoiceAddError ? state.error : (state as InvoiceEditError).error,
        )),
      );
    }
  }


  @override
  void dispose() {
    super.dispose();
  }

  void _navigateToEditPage() async {
    final updatedInvoice = await Navigator.push<Invoice>(
      context,
      MaterialPageRoute(
        builder: (_) => AddPurchaseBill(invoice: invoice),
      ),
    );

    if (updatedInvoice != null) {
      setState(() {
        invoice = updatedInvoice;
      });
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: MyTextfield.textStyle_w800(
        title,
        AppUtils.size_18,
        AppColors.kPrimary,
      ),
    );
  }

  Widget _buildKeyValueTile(String key, dynamic value, {VoidCallback? onEdit}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.kPrimary.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyTextfield.textStyle_w600(key, AppUtils.size_14, AppColors.kBlackColor800),
          widget.details==true?MyTextfield.textStyle_w600('*', AppUtils.size_14, Colors.red):SizedBox(),
          const SizedBox(width: 20),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: MyTextfield.textStyle_w300(
                    value,
                    AppUtils.size_14,
                    AppColors.kGreyColor700,
                  ),
                ),
                widget.details==true?SizedBox():
                  GestureDetector(
                    onTap: onEdit,
                    child: Icon(Icons.edit, size: 18, color: AppColors.kPrimary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(InvoiceItem product, int index) {
    final productName = product.product?.isNotEmpty == true ? product.product! : 'Product ${index + 1}';

    final fields = {
      'HSN ': product.hsn,
      'Pack': product.packing,
      'Batch No': product.batch,
      'MRP': product.mrp,
      'Rate': product.rate,
      'Disc': product.discount,
      'Ex.Dt.': product.expiry,
      'Qty': product.qty,
      'Free': product.qty_free,
      'GST': product.gst,
      'Total': product.total,
    };

    final filteredFields = fields.entries
        .where((e) => e.value != null && e.value.toString().trim().isNotEmpty)
        .toList();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: AppColors.myGradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyTextfield.textStyle_w600("🧴 $productName", AppUtils.size_18, AppColors.kPrimary),
          const SizedBox(height: 5),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: filteredFields.map((e) {
              return SizedBox(
                width: SizeConfig.screenWidth! / 5,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.kWhiteColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.kPrimary.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyTextfield.textStyle_w300(e.key, 13, AppColors.kGreyColor700),
                      const SizedBox(height: 4),
                      Text(
                        e.value.toString(),
                        style: MyTextfield.textStyle(14, AppColors.kBlackColor900, FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = invoice.items;

    return Scaffold(
      appBar: AppUtils.BaseAppBar(
        context: context,
        title: 'Invoice Summary',
        leading: true,
        actions: [
          if (widget.edit == true)
            IconButton(
              icon: Icon(Icons.edit, color: AppColors.kWhiteColor),
              onPressed: _navigateToEditPage,
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.myGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 18, right: 18, bottom: 60, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("📋 Invoice Details"),
              _buildKeyValueTile("Invoice ID", invoice.invoiceId ?? '', onEdit: () => showEditDialog("Invoice Id", invoice.invoiceId!, (val) {
                setState(() {
                  invoice = invoice.copyWith(invoiceId: val);
                });
              })),
              _buildKeyValueTile("Invoice Date", invoice.invoiceDate ?? '', onEdit: () => showEditDialog("Invoice Date", invoice.invoiceDate!, (val) {
                setState(() {
                  invoice = invoice.copyWith(invoiceDate: val);
                });
              })),
              _buildKeyValueTile("Seller Name", invoice.sellerName ?? '', onEdit: () => showEditDialog("Seller Name", invoice.sellerName!, (val) {
                setState(() {
                  invoice = invoice.copyWith(sellerName: val);
                });
              })),
              _buildKeyValueTile("Seller GSTIN", invoice.sellerGstin ?? '', onEdit: () => showEditDialog("Seller GSTIN", invoice.sellerGstin!, (val) {
                setState(() {
                  invoice = invoice.copyWith(sellerGstin: val);
                });
              })),
              _buildKeyValueTile("Seller Address", invoice.sellerAddress ?? '', onEdit: () => showEditDialog("Seller Address", invoice.sellerAddress!, (val) {
                setState(() {
                  invoice = invoice.copyWith(sellerAddress: val);
                });
              })),
              if (items.isNotEmpty) _buildSectionTitle("📦 Product Details (${items.length})"),
              ...items.asMap().entries.map((entry) => _buildProductCard(entry.value, entry.key)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.kPrimaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyTextfield.textStyle_w600("Amount: ", AppUtils.size_18, AppColors.kBlackColor800),
                    MyTextfield.textStyle_w800(calculateNetAmount(invoice.items), AppUtils.size_18, AppColors.kPrimary),
                  ],
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: widget.details!?SizedBox():Container(
        height: 50,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: MyElevatedButton(
          onPressed: () {
            if (isInvoiceValid(invoice)) {
              AddInvoiceApiCall();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please enter all required fields.')),
              );
            }
          },
          buttonText: widget.edit! ? "Update Invoice" : "Add Invoice",
        ),
      ),
    );
  }

  /// Helper Methods

  bool isInvoiceValid(Invoice invoice) {
    return [
      invoice.invoiceId,
      invoice.invoiceDate,
      invoice.sellerName,
      invoice.sellerAddress,
      invoice.sellerGstin,
    ].every((field) => field != null && field.toString().trim().isNotEmpty);
  }

  String? formatDate(String? rawDate) {
    try {
      final parsed = DateFormat('dd-MM-yyyy').parseStrict(rawDate!);
      return DateFormat('yyyy-MM-dd').format(parsed);
    } catch (_) {
      return null;
    }
  }

  InvoiceItem applyDiscountPercent(InvoiceItem item) {
    final mrp = double.tryParse(item.mrp ?? '') ?? 0.0;
    final rate = double.tryParse(item.rate ?? '') ?? 0.0;
    if (mrp == 0 || rate == 0) return item;
    final discountPercent = ((mrp - rate) / mrp) * 100;
    return item.copyWith(discount: discountPercent.toStringAsFixed(2));
  }

  String calculateNetAmount(List<InvoiceItem> items) {
    double sum = 0.0;
    for (var item in items) {
      final total = double.tryParse(item.total) ?? 0.0;
      sum += total;
    }
    return sum.toStringAsFixed(2);
  }

  Future<void> AddInvoiceApiCall() async {
    String? userId = await SessionManager.getUserId();
    final updatedItems = invoice.items.map(applyDiscountPercent).toList();
    final netAmount = calculateNetAmount(updatedItems);
    final formattedDate = formatDate(invoice.invoiceDate);

    final newInvoice = invoice.copyWith(
      items: updatedItems,
      netAmount: netAmount,
      userId: userId,
      invoiceDate: formattedDate,
    );

    print("📄 Invoice: ${newInvoice.toJson()}");

    if (widget.edit == true) {
      context.read<ApiCubit>().InvoiceEdit(invoice: newInvoice);
    } else {
      context.read<ApiCubit>().InvoiceAdd(invoice: newInvoice);
    }
  }

  void showEditDialog(String title, String initialValue, void Function(String) onSave) {
    showDialog(
      context: context,
      builder: (_) => EditValueDialog(
        title: title,
        initialValue: initialValue,
        onSave: onSave,
      ),
    );
  }
}
