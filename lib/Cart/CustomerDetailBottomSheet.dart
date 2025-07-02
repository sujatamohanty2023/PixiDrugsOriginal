
import 'package:pixidrugs/constant/all.dart'; // adjust this import path to your project

class CustomerDetailBottomSheet extends StatefulWidget {
  final Function(String name, String phone, String address)? onSubmit;

  const CustomerDetailBottomSheet({Key? key, this.onSubmit}) : super(key: key);

  @override
  _CustomerDetailBottomSheetState createState() => _CustomerDetailBottomSheetState();
}

class _CustomerDetailBottomSheetState extends State<CustomerDetailBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus(); // Dismiss keyboard
      widget.onSubmit?.call(
        _nameController.text.trim(),
        _phoneController.text.trim(),
        _addressController.text.trim(),
      );
      Navigator.of(context).pop(); // Close the modal
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
          left: 20,
          right: 20,
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
  Widget _buildTextField(TextEditingController controller, String hint, TextInputType type,
      {int maxLines = 1, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MyTextfield.textStyle_w600(
                hint.replaceAll('Enter', ''), AppUtils.size_16, Colors.black),
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

}
