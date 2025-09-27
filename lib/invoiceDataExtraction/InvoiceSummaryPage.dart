import 'package:intl/intl.dart';
import '../ListScreenNew/InvoiceReportScreen.dart';
import '../../constant/all.dart';
import 'InvoiceModel.dart';

class InvoiceSummaryPage extends StatefulWidget {
  final Invoice invoice;
  final bool? edit;
  final bool manualAdd;
  final bool? details;

  InvoiceSummaryPage({super.key, required this.invoice, this.edit = false,this.manualAdd = false,this.details = false});

  @override
  State<InvoiceSummaryPage> createState() => _InvoiceSummaryPageState();
}

class _InvoiceSummaryPageState extends State<InvoiceSummaryPage> {
  late Invoice invoice1;
  String? netAmount='';
  StreamSubscription? _subscription;
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    invoice1 = widget.invoice;
    print('netAmount${invoice1.items.toString()}');

    invoice1 = invoice1.copyWith(
      items: calculateTabQtyForAllItems(invoice1.items),
    );

    _subscription = context.read<ApiCubit>().stream.listen((state) {
      if (!mounted) return;
      handleApiState(state);
    });
  }
  void handleApiState(ApiState state) {
    if (state is InvoiceAddLoaded) {
      AppUtils.showSnackBar(context,state.message);

        // Navigate to the listing page after a short delay
        Future.delayed(Duration(milliseconds: 500), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) =>
            Invoicereportscreen()),
                (route) => false,
          );
        });
    }else if (state is InvoiceEditLoaded) {
      AppUtils.showSnackBar(context,state.message);

      // Navigate to the listing page after a short delay
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) =>
              Invoicereportscreen()),
              (route) => false,
        );
      });
    }  else if (state is InvoiceAddError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.handleApiError(state.error, () => AddInvoiceApiCall());
      });
    }else if ( state is InvoiceEditError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
      context.handleApiError(state.error, () => AddInvoiceApiCall());
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
          MyTextfield.textStyle_w400(key, AppUtils.size_14, AppColors.kGreyColor700),
          widget.details==false?MyTextfield.textStyle_w600('*', AppUtils.size_14, Colors.red):SizedBox(),
          const SizedBox(width: 20),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: MyTextfield.textStyle_w600(
                    value,
                    AppUtils.size_14,
                    AppColors.kBlackColor800,
                  ),
                ),
                widget.details==true?SizedBox():
                  GestureDetector(
                    onTap: onEdit,
                    child:  SvgPicture.asset(AppImages.edit, height: 18, color: Colors.teal),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(InvoiceItem product, int index) {

    final productName = product.product.isNotEmpty == true ? product.product : 'Product ${index + 1}';

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
      if (product.tabQty > 0) 'TabQty': product.tabQty
    };

    final filteredFields = fields.entries
        .where((e) => e.value != null && e.value.toString().trim().isNotEmpty)
        .toList();

    print(filteredFields);
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyTextfield.textStyle_w600("🧴 $productName", AppUtils.size_18, AppColors.kPrimary),
              if (widget.details == false)
                GestureDetector(
                  onTap: () async {
                    // 🔥 Navigate to AddPurchaseBill with current invoice and index
                    final updatedInvoice = await Navigator.push<Invoice>(
                        context,
                        MaterialPageRoute(
                        builder: (_) => AddPurchaseBill(
                      invoice: invoice1.copyWith(items: List.from(invoice1.items)), // Pass mutable copy
                    ),
                    settings: RouteSettings(arguments: {'edit_product_index': index}),
                    ),
                    );

                    // ✅ If we get updated invoice back, update state
                    if (updatedInvoice != null) {
                      setState(() {
                        invoice1 = updatedInvoice;
                        netAmount = calculateNetAmount(invoice1.items);
                      });
                      AppUtils.showSnackBar(context,"Product updated successfully");
                    }
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset(AppImages.edit, height: 18, color: Colors.teal),
                      SizedBox(width: 4),
                      MyTextfield.textStyle_w600('Edit', 14, Colors.teal),
                    ],
                  ),
                ),
            ],
          ),
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
    final items = invoice1.items;
    netAmount=calculateNetAmount(items);
    print('netAmount$netAmount');
    print('netAmount${items.toString()}');
    return Scaffold(
      appBar: AppUtils.BaseAppBar(
        context: context,
        title: 'Invoice Summary',
        leading: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.myGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 18, right: 18, bottom: 60, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("📋 Invoice Details"),
              _buildKeyValueTile("Invoice ID", invoice1.invoiceId ?? '', onEdit: () => showEditDialog("Invoice Id", invoice1.invoiceId!, (val) {
                setState(() {
                  invoice1 = invoice1.copyWith(invoiceId: val);
                });
              })),
              _buildKeyValueTile("Invoice Date", invoice1.invoiceDate ?? '', onEdit: () => showEditDialog("Invoice Date", invoice1.invoiceDate!, (val) {
                setState(() {
                  invoice1 = invoice1.copyWith(invoiceDate: val);
                });
              })),
              _buildKeyValueTile("Seller Name", invoice1.sellerName ?? '', onEdit: () => showEditDialog("Seller Name", invoice1.sellerName!, (val) {
                setState(() {
                  invoice1 = invoice1.copyWith(sellerName: val);
                });
              })),
              _buildKeyValueTile("Seller GSTIN", invoice1.sellerGstin ?? '', onEdit: () => showEditDialog("Seller GSTIN", invoice1.sellerGstin!, (val) {
                setState(() {
                  invoice1 = invoice1.copyWith(sellerGstin: val);
                });
              })),
              _buildKeyValueTile("Seller Address", invoice1.sellerAddress ?? '', onEdit: () => showEditDialog("Seller Address", invoice1.sellerAddress!, (val) {
                setState(() {
                  invoice1 = invoice1.copyWith(sellerAddress: val);
                });
              })),
              _buildKeyValueTile(
                "Seller Phone1",
                invoice1.sellerPhone1 ?? '',
                onEdit: () => showEditDialog(
                  "Seller Phone1",invoice1.sellerPhone1 ?? '',
                  (val) {
                    final normalizedPhone = AppUtils().validateAndNormalizePhone(val);

                    if (normalizedPhone.isEmpty && val.isNotEmpty == true) {
                      AppUtils.showSnackBar(context, 'Invalid phone number. Please enter a valid 10-digit Indian mobile number.');
                      return; // Prevent saving invalid data
                    }

                    setState(() {
                      invoice1 = invoice1.copyWith(sellerPhone1: normalizedPhone);
                    });
                  },
                ),
              ),
              _buildKeyValueTile(
                "Seller Phone2",
                invoice1.sellerPhone2 ?? '',
                onEdit: () => showEditDialog(
                  "Seller Phone2",invoice1.sellerPhone2 ?? '',
                      (val) {
                    final normalizedPhone = AppUtils().validateAndNormalizePhone(val);

                    if (normalizedPhone.isEmpty && val.isNotEmpty == true) {
                      AppUtils.showSnackBar(context, 'Invalid phone number. Please enter a valid 10-digit Indian mobile number.');
                      return; // Prevent saving invalid data
                    }

                    setState(() {
                      invoice1 = invoice1.copyWith(sellerPhone2: normalizedPhone);
                    });
                  },
                ),
              ),
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
                    MyTextfield.textStyle_w800(netAmount??'', AppUtils.size_18, AppColors.kPrimary),
                    SizedBox(width: 4,),
                    GestureDetector(
                      onTap: () {
                        showEditDialog(
                          "Total Amount",
                          netAmount ?? '',
                          (value) {
                            setState(() {
                              netAmount = value;
                            });
                          },
                        );
                      },
                      child: SvgPicture.asset(AppImages.edit, height: 20, color: Colors.teal),
                    ),
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
            if (isInvoiceValid(invoice1)) {
              AddInvoiceApiCall();
            } else {
              AppUtils.showSnackBar(context,'Please enter all required fields.');
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
      invoice.sellerPhone1,
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

  String calculateNetAmount(List<InvoiceItem> items) {
    double sum = 0.0;
    for (var item in items) {
      final total = double.tryParse(item.total.replaceAll(',', '')) ?? 0.0;
      sum += total;
    }
    return sum.toStringAsFixed(2);
  }
  List<InvoiceItem> calculateTabQtyForAllItems(List<InvoiceItem> items) {
    return items.map((item) {
      final unitType = AppUtils().detectUnitType(item.packing);
      final packingQty = AppUtils().extractPackingQuantity(item.packing);
      final totalQty = item.qty + item.qty_free;

      int computedTabQty = 0;
      if ((unitType == UnitType.Tablet ||unitType == UnitType.Strip) && packingQty > 0) {
        computedTabQty = totalQty * packingQty;
      }

      return item.copyWith(tabQty: computedTabQty,medType: unitType?.name);
    }).toList();
  }
  List<InvoiceItem> calculateDiscountAllItems(List<InvoiceItem> items) {
    return items.map((item) {
      double discountPercent = 0.0;

      // Parse values
      final discountValue = double.tryParse(item.discount.toString()) ?? 0.0;
      final rate = double.tryParse(item.rate.toString()) ?? 0.0;
      final qty = item.qty;

      if (item.discountType == DiscountType.flat && rate > 0 && qty > 0) {
        final total = rate * qty;
        discountPercent = (discountValue / total) * 100;
      }else if (item.discountType == DiscountType.percent && rate > 0 && qty > 0){
        discountPercent=discountValue;
      }

      return item.copyWith(discount: discountPercent.toStringAsFixed(2));
    }).toList();
  }

  Future<void> AddInvoiceApiCall() async {
    String? userId = await SessionManager.getParentingId();
    //final updatedItems = invoice1.items;
    final updatedItems = calculateDiscountAllItems(invoice1.items);
    final formattedDate = formatDate(invoice1.invoiceDate);

    final newInvoice = invoice1.copyWith(
      items: calculateTabQtyForAllItems(updatedItems),
      netAmount: netAmount,
      invoiceDate: formattedDate,
      userId: userId
    );

    print("📄 Invoice: ${newInvoice.toJson()}");

    if (widget.edit == false || widget.manualAdd) {
      context.read<ApiCubit>().InvoiceAdd(invoice: newInvoice);
    } else {
      context.read<ApiCubit>().InvoiceEdit(invoice: newInvoice);
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
