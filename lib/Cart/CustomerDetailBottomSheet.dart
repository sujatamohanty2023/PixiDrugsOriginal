
import 'package:PixiDrugs/constant/all.dart'; // adjust this import path to your project

class CustomerDetailBottomSheet extends StatefulWidget {
  final ScrollController scrollController;
  final Function(String name, String phone, String address,String paymentType,
      String referenceNumber, String referralName, String referralPhone,String referralAmount)? onSubmit;

  const CustomerDetailBottomSheet({Key? key, this.onSubmit, String? name, String? phone, String? address,
    String? paymentType, String? referenceNumber, String? referralName, String? referralPhone,String? referralAmount,
    required this.scrollController,}) : super(key: key);

  @override
  _CustomerDetailBottomSheetState createState() => _CustomerDetailBottomSheetState();
}

class _CustomerDetailBottomSheetState extends State<CustomerDetailBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String selectedPaymentType = "Cash";
  final TextEditingController referenceNumberController = TextEditingController();
  final TextEditingController _referralNameController = TextEditingController();
  final TextEditingController _referralPhoneController = TextEditingController();
  final TextEditingController _referralAmountController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    referenceNumberController.dispose();
    _referralNameController.dispose();
    _referralPhoneController.dispose();
    _referralAmountController.dispose();
    super.dispose();
  }
  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      widget.onSubmit?.call(
        _nameController.text.trim(),
        _phoneController.text.trim(),
        _addressController.text.trim(),
        selectedPaymentType,
        referenceNumberController.text.trim(),
        _referralNameController.text.trim(),
        _referralPhoneController.text.trim(),
        _referralAmountController.text.trim(),
      );

      if (mounted) Navigator.of(context).pop();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyles.bg_radius_50_decoration(),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 10,
          right: 10,
          top: 30,
        ),
        child: SingleChildScrollView(
          child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Customer Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  _buildTextField(_nameController, 'Customer Name', TextInputType.name),
                  const SizedBox(height: 15),
                  _buildTextField(_phoneController, 'Phone Number', TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter phone number';
                        if (!RegExp(r'^\d{10,}$').hasMatch(value)) return 'Enter valid phone number';
                        return null;
                      }),
                  const SizedBox(height: 15),
                  _buildTextField(_addressController, 'Address', TextInputType.streetAddress,
                      maxLines: 3),
                  const SizedBox(height: 15),
                  _buildPaymentTypeDropdown(),
                  if (selectedPaymentType != "Cash") ...[
                    const SizedBox(height: 16),
                    _buildTextField(
                      referenceNumberController,
                      "Reference Number",
                      TextInputType.text,
                    ),
                  ],
                  const SizedBox(height: 15),
                  _buildTextField(_referralNameController, 'Referral Doctor/Partner Name', TextInputType.name,manadatory:false,validator: null),
                  const SizedBox(height: 15),
                  _buildTextField(_referralPhoneController, 'Referral Contact Number', TextInputType.phone,manadatory:false,validator: null),
                  const SizedBox(height: 15),
                  _buildTextField(_referralAmountController, 'Referral Amount', TextInputType.number,manadatory:false,validator: null),
                  const SizedBox(height: 30),
                  MyElevatedButton(
                    buttonText: 'Submit',
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ],
          ),
          ),
        ),
      ),
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
  Widget _buildTextField(TextEditingController controller, String hint, TextInputType type,
      {bool manadatory=true,int maxLines = 1, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MyTextfield.textStyle_w600(
                hint.replaceAll('Enter', ''), AppUtils.size_16, Colors.black),
            manadatory?MyTextfield.textStyle_w600(" *", AppUtils.size_16, Colors.red):SizedBox(),
          ],
        ),
        const SizedBox(height: 8),
        MyEdittextfield(
          controller: controller,
          hintText: hint,
          validator: validator,
          maxLines: maxLines,
          mandatory: manadatory,
        ),
      ],
    );
  }

}
