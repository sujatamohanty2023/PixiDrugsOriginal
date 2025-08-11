import 'package:intl/intl.dart';
import 'package:PixiDrugs/Ledger/LedgerModel.dart';
import 'package:PixiDrugs/Ledger/Payment.dart';
import 'package:PixiDrugs/constant/all.dart';

class PaymentOutEntryPage extends StatefulWidget {
  final LedgerModel? ledger;
  final bool? edit;
  final int? index;
  final ScrollController scrollController; // <-- Added scroll controller

  const PaymentOutEntryPage({
    super.key,
    this.edit=false,
    this.index=0,
    required this.ledger,
    required this.scrollController,
  });

  @override
  State<PaymentOutEntryPage> createState() => _PaymentOutEntryPageState();
}

class _PaymentOutEntryPageState extends State<PaymentOutEntryPage> with TickerProviderStateMixin {
  final TextEditingController _invoice_noController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController paidController = TextEditingController(text: '0.00');
  final TextEditingController referenceNumberController = TextEditingController();

  String selectedReceiptNo = "1";
  DateTime selectedDate = DateTime.now();
  String selectedPaymentType = "Cash";

  bool isPaid = false;
  double totalAmount = 0.00;
  double paidAmount = 0.0;

  @override
  void initState() {
    super.initState();
    if(widget.edit!) {
      setState(() {
        _invoice_noController.text =widget.ledger!.history[widget.index!].invoiceNo;
        _dateController.text =AppUtils().formatDate(widget.ledger!.history[widget.index!].paymentDate);
        paidController.text =widget.ledger!.history[widget.index!].amount;
        selectedPaymentType=widget.ledger!.history[widget.index!].paymentType;
        referenceNumberController.text =widget.ledger!.history[widget.index!].paymentReference;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
   return BlocListener<ApiCubit, ApiState>(
      listener: (context, state) {
        if (state is StorePaymentLoaded) {
          AppUtils.showSnackBar(context,state.message);
          Navigator.pop(context); // Close bottom sheet or current page
          if (Navigator.canPop(context)) {
            Navigator.pop(context); // Close underlying page only if possible
          }
        } else if (state is StorePaymentError) {
          AppUtils.showSnackBar(context,state.error);
        }else if (state is UpdatePaymentLoaded) {
          AppUtils.showSnackBar(context,state.message);
          Navigator.pop(context); // Close bottom sheet or current page
          if (Navigator.canPop(context)) {
            Navigator.pop(context); // Close underlying page only if possible
          }
        }else if (state is UpdatePaymentError) {
          AppUtils.showSnackBar(context,state.error);
        }
      },
      child:Container(
        decoration: AppStyles.bg_radius_50_decoration(),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildReceiptAndDate(),
                    const SizedBox(height: 10),
                    _buildAmountCard(),
                    const SizedBox(height: 20),
                    _buildPaymentTypeDropdown(),
                    if (selectedPaymentType != "Cash") ...[
                      const SizedBox(height: 16),
                      _buildEditTextField(
                        referenceNumberController,
                        "Reference Number",
                        TextInputType.text,
                      ),
                    ],
                    const SizedBox(height: 20),
                    _buildBottomButtons(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptAndDate() {
    return Row(
      children: [
        Expanded(
          child: _buildEditTextField(
            _invoice_noController,
            'Invoice No.',
            TextInputType.text,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  MyTextfield.textStyle_w600('Date', AppUtils.size_16, Colors.black),
                  MyTextfield.textStyle_w600(" *", AppUtils.size_16, Colors.red),
                ],
              ),
              const SizedBox(height: 8),
              MyEdittextfield(
                controller: _dateController,
                hintText: "DD/MM/YYYY",
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return AppUtils.CalenderTheme(child: child);
      },
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        _dateController.text = DateFormat('dd MMM, yyyy').format(selectedDate);
      });
    }
  }

  Widget _buildEditTextField(
      TextEditingController controller,
      String hint,
      TextInputType type, {
        int maxLines = 1,
        String? Function(String?)? validator,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MyTextfield.textStyle_w600(hint, AppUtils.size_16, Colors.black),
            MyTextfield.textStyle_w600(" *", AppUtils.size_16, Colors.red),
          ],
        ),
        const SizedBox(height: 8),
        MyEdittextfield(
          controller: controller,
          hintText: hint,
          validator: validator,
          maxLines: maxLines,
        ),
      ],
    );
  }

  Widget _buildAmountCard() {
    totalAmount=double.parse(widget.ledger!.totalCredit.toString().replaceAll(',', ''));
    double balanceDue = totalAmount - paidAmount;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.kPrimaryDark, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAmountRow("Total Amount", totalAmount, bold: true, color: Colors.black),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: isPaid,
                onChanged: (value) {
                  setState(() {
                    isPaid = value ?? false;
                    paidAmount = isPaid ? totalAmount : 0.0;
                    paidController.text = paidAmount.toStringAsFixed(2);
                  });
                },
              ),
              MyTextfield.textStyle_w600("Paid", AppUtils.size_16, Colors.green),
              const Spacer(),
              SizedBox(
                width: 100,
                child: TextFormField(
                  controller: paidController,
                  enabled: isPaid,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.end,
                  style: MyTextfield.textStyle(
                    AppUtils.size_16, Colors.green,
                    FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.dashed,
                  ),
                  decoration: const InputDecoration(isDense: true, border: InputBorder.none),
                  onChanged: (value) {
                    setState(() {
                      paidAmount = double.tryParse(value) ?? 0.0;
                      if (paidAmount > totalAmount) {
                        paidAmount = totalAmount;
                        paidController.text = totalAmount.toStringAsFixed(2);
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          Divider(),
          const SizedBox(height: 12),
          _buildAmountRow("Balance Due", balanceDue, bold: true, color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount, {bool bold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: MyTextfield.textStyle(AppUtils.size_16, color ?? Colors.black87, bold ? FontWeight.w600 : FontWeight.w400)),
        Text(
          "₹ ${amount.toStringAsFixed(2)}",
          style: MyTextfield.textStyle(
            AppUtils.size_16, color ?? Colors.black87,
            bold ? FontWeight.w600 : FontWeight.w400,
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.dashed,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentTypeDropdown() {
    final paymentTypes = [
      {'label': 'Cash', 'icon': Icons.money},
      {'label': 'Bank', 'icon': Icons.account_balance},
      {'label': 'UPI', 'icon': Icons.qr_code},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MyTextfield.textStyle_w600("Payment Method ", AppUtils.size_16, Colors.black),
            MyTextfield.textStyle_w600(" *", AppUtils.size_16, Colors.red),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.kPrimaryDark, width: 1),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedPaymentType,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.kPrimaryDark),
              items: paymentTypes.map((item) {
                return DropdownMenuItem<String>(
                  value: item['label'].toString(),
                  child: Row(
                    children: [
                      Icon(item['icon'] as IconData, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        item['label'].toString(),
                        style: MyTextfield.textStyle(14, Colors.black, FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedPaymentType = value;
                    if (value == "Cash") {
                      referenceNumberController.clear();
                    }

                    // Auto-scroll to bottom when reference appears
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      widget.scrollController.animateTo(
                        widget.scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    });
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: AppStyles.elevatedButton_style(color: AppColors.kPrimaryDark),
            child: MyTextfield.textStyle_w800('Cancel', 18, AppColors.kPrimary),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: ElevatedButton(
            onPressed: SubmitCall,
            style: AppStyles.elevatedButton_style(color: AppColors.kPrimary),
            child: MyTextfield.textStyle_w800('Save', 18, AppColors.kWhiteColor),
          ),
        ),
      ],
    );
  }
  void SubmitCall() async {
    if (_invoice_noController.text.isEmpty || _dateController.text.isEmpty || double.tryParse(paidController.text) == null) {
      AppUtils.showSnackBar(context,"Please fill all required fields.");
      return;
    }

    final userId = await SessionManager.getParentingId() ?? '';
    var payment1 = Payment(
      id: widget.edit!?widget.ledger!.history[widget.index!].id:null,
      userId: int.parse(userId),
      sellerId: widget.ledger!.partyId,
      invoiceNo: _invoice_noController.text.toString(),
      amount: double.parse(paidController.text.toString().replaceAll(',', '')),
      paymentDate: AppUtils().formatDateForServerInput(_dateController.text.toString()),
      paymentType: selectedPaymentType,
      paymentReference: referenceNumberController.text.toString(),
      paymentReason: "debit",
    );
    print(payment1.toString());
    if(!widget.edit!) {
      context.read<ApiCubit>().StorePayment(payment: payment1);
    }else{
      context.read<ApiCubit>().UpdatePayment(payment: payment1);
    }
  }
}
