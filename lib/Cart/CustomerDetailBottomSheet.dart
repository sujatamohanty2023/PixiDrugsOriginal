import 'package:flutter/material.dart';
import 'package:PixiDrugs/constant/all.dart';

import '../customWidget/PaymentTypeWidget.dart'; // adjust this import path to your project

class CustomerDetailBottomSheet extends StatefulWidget {
  final ScrollController scrollController;
  final Function(String name, String phone, String address,String paymentType,
      String referenceNumber, String referralName, String referralPhone,String referralAmount,bool isReferralAmountGiven)? onSubmit;

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
  bool isReferralAmountGiven = false;

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
    if (!(_formKey.currentState?.validate() ?? false)) return;

    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();
    String address = _addressController.text.trim();
    String referralName = _referralNameController.text.trim();
    String referralPhone = _referralPhoneController.text.trim();
    String referralAmount = _referralAmountController.text.trim();

    // Normalize empty values
    name = name.isEmpty ? "NA" : name;
    phone = phone.isEmpty ? "NA" : phone;
    address = address.isEmpty ? "NA" : address;

    bool referralExists = referralName.isNotEmpty || referralPhone.isNotEmpty || referralAmount.isNotEmpty|| isReferralAmountGiven;

    if (referralExists) {
      // Must provide customer name & phone
      if (name == "NA" || phone == "NA") {
        AppUtils.showSnackBar(context, "Please enter customer name and phone for referral.");
        return;
      }

      // Referral name and phone mandatory
      if (referralName.isEmpty || referralPhone.isEmpty) {
        AppUtils.showSnackBar(context, "Please enter referral name and phone.");
        return;
      }

      // If marked as 'Referral Amount Given', amount is required
      if (isReferralAmountGiven && referralAmount.isEmpty) {
        AppUtils.showSnackBar(context, "Please enter referral amount.");
        return;
      }
    } else {
      // No referral — clear referral fields
      referralAmount = "";
      referralName = "";
      referralPhone = "";
      _referralAmountController.clear();
      _referralNameController.clear();
      _referralPhoneController.clear();
    }

    FocusScope.of(context).unfocus();
    widget.onSubmit?.call(
      name,
      phone,
      address,
      selectedPaymentType,
      referenceNumberController.text.trim(),
      referralName,
      referralPhone,
      referralAmount,
      isReferralAmountGiven
    );
  }

  Widget build(BuildContext context) {
      return Container(
        decoration: AppStyles.bg_radius_50_decoration(),
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 10,
            right: 10,
            top: 10,
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [ // Give space for the skip button
                      const Text(
                        'Customer Details',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.kPrimary,
                                  AppColors.secondaryColor,
                                ],
                                stops: [0.0, 1.0],
                                tileMode: TileMode.clamp,
                              ),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(width: 0.5, color: AppColors.secondaryColor),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4))
                              ],
                            ),
                            child: GestureDetector(
                              onTap: _submit,
                              child: MyTextfield.textStyle_w600(
                                "Skip",
                                AppUtils.size_16,
                                AppColors.kWhiteColor,
                              ),
                            ),
                          ),
                        ),
                      ),

                      Column(
                        children: [
                          _buildTextField(_nameController, 'Customer Name', TextInputType.name, manadatory: false, validator: null),
                          const SizedBox(height: 5),
                          _buildTextField(_phoneController, 'Phone Number', TextInputType.phone,
                              manadatory: false,
                              validator: (value) {
                                if (value != null && value.isNotEmpty && !RegExp(r'^\d{10,}$').hasMatch(value)) {
                                  return 'Enter valid phone number';
                                }
                                return null;
                              }),
                          const SizedBox(height: 5),
                          _buildTextField(_addressController, 'Address', TextInputType.streetAddress,
                              manadatory: false, maxLines: 1, validator: null),
                          const SizedBox(height: 5),
                          PaymentPopupMenu(
                            label: "Payment Method",
                            selectedValue: selectedPaymentType,
                            onChanged: (val) {
                              setState(() {
                                selectedPaymentType = val;
                              });
                            },
                            items: AppString.paymentTypes,
                          ),
                          if (selectedPaymentType != "Cash") ...[
                            const SizedBox(height: 16),
                            _buildTextField(
                              referenceNumberController,
                              "Reference Number",
                              TextInputType.text,
                              manadatory: false,
                              validator: null,
                            ),
                          ],
                          const SizedBox(height: 5),
                          _buildTextField(_referralNameController, 'Referral Doctor/Partner Name', TextInputType.name, manadatory:false,validator: null),
                          const SizedBox(height: 5),
                          _buildTextField(_referralPhoneController, 'Referral Contact Number', TextInputType.phone, manadatory:false,validator: null),
                          const SizedBox(height: 5),
                          _buildTextField(_referralAmountController, 'Referral Amount', TextInputType.number, manadatory:false,validator: null),
                          const SizedBox(height: 5),
                          _buildReferralAmountRadioButtons(),
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
            ],
          ),
        ),
      );
  }
  Widget _buildReferralAmountRadioButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyTextfield.textStyle_w600("Referral Amount Status", AppUtils.size_16, Colors.black),
        Row(
          children: [
            Radio<bool>(
              activeColor: AppColors.kPrimary,
              value: true,
              groupValue: isReferralAmountGiven,
              onChanged: (value) {
                setState(() {
                  isReferralAmountGiven = value!;
                  if (!isReferralAmountGiven) {
                    _referralAmountController.clear();
                    _referralNameController.clear();
                    _referralPhoneController.clear();
                  }
                });
              },
            ),
            MyTextfield.textStyle_w600('Given', AppUtils.size_16, Colors.black),
            const SizedBox(width: 20),
            Radio<bool>(
              activeColor: AppColors.kPrimary,
              value: false,
              groupValue: isReferralAmountGiven,
              onChanged: (value) {
                setState(() {
                  isReferralAmountGiven = value!;
                  if (!isReferralAmountGiven) {
                    _referralAmountController.clear();
                    _referralNameController.clear();
                    _referralPhoneController.clear();
                  }
                });
              },
            ),
            MyTextfield.textStyle_w600('Not Given', AppUtils.size_16, Colors.black),
          ],
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
            // manadatory?MyTextfield.textStyle_w600(" *", AppUtils.size_16, Colors.red):SizedBox(),
          ],
        ),
        const SizedBox(height: 8),
        MyEdittextfield(
          controller: controller,
          hintText: hint,
          validator: validator,
          maxLines: maxLines,
          mandatory: manadatory,
          keyboardType: type,
        ),
      ],
    );
  }
}
