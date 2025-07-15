import 'package:pixidrugs/Ledger/LedgerModel.dart';
import 'package:pixidrugs/constant/all.dart';
import 'package:intl/intl.dart';

class PaymentOutEntryPage extends StatefulWidget {
  LedgerModel? ledger;
  final Function()? onSubmit;
  PaymentOutEntryPage({super.key,required this.ledger,required this.onSubmit});

  @override
  State<PaymentOutEntryPage> createState() => _PaymentOutEntryPageState();
}

class _PaymentOutEntryPageState extends State<PaymentOutEntryPage> {
  final TextEditingController partyNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController paidController = TextEditingController(
    text: '0.00',
  );
  final TextEditingController referenceNumberController =
      TextEditingController();

  String selectedReceiptNo = "1";
  DateTime selectedDate = DateTime.now();
  String selectedPaymentType = "Cash";

  bool isPaid = false;
  double totalAmount = 20000.00;
  double paidAmount = 0.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyles.bg_radius_50_decoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildReceiptAndDate(),
                  const SizedBox(height: 20),
                  _buildAmountCard(),
                  const SizedBox(height: 20),
                  _buildPaymentTypeDropdown(),
                  if (selectedPaymentType != "Cash") ...[
                    const SizedBox(height: 16),
                    _buildTextField(
                      referenceNumberController,
                      "Reference Number",
                      "Enter reference or cheque number",
                    ),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom ,
              left: 16,
              right: 16,
              top: 10,
            ),
            child:  _buildBottomButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptAndDate() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final selected = await showDialog<String>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text("Select Receipt No."),
                      content: SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: 10,
                          itemBuilder:
                              (_, index) => ListTile(
                                title: Text('Receipt ${index + 1}'),
                                onTap:
                                    () =>
                                        Navigator.pop(context, '${index + 1}'),
                              ),
                        ),
                      ),
                    ),
              );
              if (selected != null)
                setState(() => selectedReceiptNo = selected);
            },
            child: AbsorbPointer(
              child: TextFormField(
                controller: TextEditingController(text: selectedReceiptNo),
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Invoice No.',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) setState(() => selectedDate = picked);
            },
            child: AbsorbPointer(
              child: TextFormField(
                controller: TextEditingController(
                  text: DateFormat('dd/MM/yyyy').format(selectedDate),
                ),
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    double balanceDue = totalAmount - paidAmount;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
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
          _buildAmountRow(
            "Total Amount",
            totalAmount,
            bold: true,
            color: Colors.black,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: isPaid,
                onChanged: (value) {
                  setState(() {
                    isPaid = value ?? false;
                    if (isPaid) {
                      paidAmount = totalAmount;
                      paidController.text = paidAmount.toStringAsFixed(2);
                    } else {
                      paidAmount = 0.0;
                      paidController.text = '0.00';
                    }
                  });
                },
              ),
              const Text(
                "Paid",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Divider(),
              SizedBox(
                width: 100,
                child: TextFormField(
                  controller: paidController,
                  enabled: isPaid,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                    decorationStyle: TextDecorationStyle.dashed,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                  ),
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
          _buildAmountRow(
            "Balance Due",
            balanceDue,
            bold: true,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(
    String label,
    double amount, {
    bool bold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            color: color ?? Colors.black87,
          ),
        ),
        Text(
          "₹ ${amount.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: 16,
            color: color ?? Colors.black87,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.dashed,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedPaymentType,
      decoration: const InputDecoration(
        labelText: 'Payment Type',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(
          value: "Cash",
          child: Row(
            children: [Icon(Icons.money), SizedBox(width: 8), Text("Cash")],
          ),
        ),
        DropdownMenuItem(
          value: "Bank",
          child: Row(
            children: [
              Icon(Icons.account_balance),
              SizedBox(width: 8),
              Text("Bank"),
            ],
          ),
        ),
        DropdownMenuItem(
          value: "UPI",
          child: Row(
            children: [Icon(Icons.qr_code), SizedBox(width: 8), Text("UPI")],
          ),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            selectedPaymentType = value;
            if (selectedPaymentType == "Cash") {
              referenceNumberController.clear();
            }
          });
        }
      },
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // TODO: Save & New logic
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.kWhiteColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.kPrimaryLight),
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: AppColors.kPrimaryLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // TODO: Save logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kPrimaryLight,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                "Save",
                style: TextStyle(
                  color: AppColors.kWhiteColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
