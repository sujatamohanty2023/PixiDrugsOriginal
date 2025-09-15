import 'package:PixiDrugs/constant/all.dart';
import 'package:PixiDrugs/login/RegisterResponse.dart';
import 'package:flutter/material.dart';

import '../Api/api_cubit.dart';
import '../Profile/contact_us.dart';
import '../constant/color.dart';
import '../constant/utils.dart';
import '../customWidget/MyEditTextField.dart';
import '../customWidget/MyTextField.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final storeNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final gstController = TextEditingController();
  final regController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final pincodeController = TextEditingController();
  bool _isLoading = false;
  StreamSubscription? _registerSubscription;

  String selectedState = "Odisha";

  final List<String> indianStates = [
    "Andhra Pradesh",
    "Arunachal Pradesh",
    "Assam",
    "Bihar",
    "Chhattisgarh",
    "Goa",
    "Gujarat",
    "Haryana",
    "Himachal Pradesh",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Madhya Pradesh",
    "Maharashtra",
    "Manipur",
    "Meghalaya",
    "Mizoram",
    "Nagaland",
    "Odisha",
    "Punjab",
    "Rajasthan",
    "Sikkim",
    "Tamil Nadu",
    "Telangana",
    "Tripura",
    "Uttar Pradesh",
    "Uttarakhand",
    "West Bengal",
    "Delhi",
    "Jammu and Kashmir",
    "Ladakh",
    "Puducherry",
    "Chandigarh",
    "Andaman and Nicobar Islands",
    "Lakshadweep",
    "Dadra and Nagar Haveli and Daman and Diu"
  ];

  void _showStateDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select State'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: indianStates.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(indianStates[index]),
                  onTap: () {
                    setState(() {
                      selectedState = indianStates[index];
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
  Future<void> _onSignUpPressed() async {
    setState(() {
      _isLoading = true;
    });
    RegisterModel model = RegisterModel(
      name: storeNameController.text,
      ownerName: ownerNameController.text,
      email: emailController.text,
      phoneNumber: phoneController.text,
      gstin: gstController.text,
      license: regController.text,
      address: addressController.text,
      pincode: pincodeController.text,
      state: selectedState,
      country: 'India',
      gander: 'NA',
      dob: '',
      password: '',
      city: cityController.text,
    );
    context.read<ApiCubit>().register( model: model);

    await _registerSubscription?.cancel();
    _registerSubscription = context.read<ApiCubit>().stream.listen((state) {
      if (state is RegisterLoaded) {
        setState(() => _isLoading = false);

        final res = state.registerResponse;
        if (res.status) {
          setState(() => _isLoading = false);
          AppUtils.showSnackBar(context, res.message);
          Navigator.pop(context);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ContactUsPage()/*Webviewscreen(tittle: 'Contact Us')*/,
            ),
          );
        }
      } else if (state is RegisterError) {
        setState(() => _isLoading = false);
        AppUtils.showSnackBar(context, state.error);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.kPrimary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: AppColors.myGradient,
        ),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 60),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _buildLabel('Store Name'),
                _buildTextField('Enter store name', storeNameController),

                _buildLabel('Owner Name'),
                _buildTextField('Enter owner name', ownerNameController),

                _buildLabel('Phone'),
                _buildTextField('Enter phone number', phoneController, inputType: TextInputType.phone),

                _buildLabel('Email'),
                _buildTextField('Enter email', emailController, inputType: TextInputType.emailAddress),

                _buildLabel('GST Number'),
                _buildTextField('Enter GST number', gstController),

                _buildLabel('License Number'),
                _buildTextField('Enter license number', regController),

                MyTextfield.textStyle_w600('Location Details', 18, Colors.black),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Country (Fixed - India)
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyTextfield.textStyle_w600('Country', 14, Colors.black),
                          const SizedBox(height: 6),
                          MyEdittextfield(
                            hintText: 'India',
                            readOnly: true,
                            controller: TextEditingController(text: 'India'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    /// State (with fixed overflow handling)
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyTextfield.textStyle_w600('State', 14, Colors.black),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: _showStateDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      selectedState.isEmpty ? 'Select State' : selectedState,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: selectedState.isEmpty ? Colors.grey : Colors.black,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    /// Pin Code
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyTextfield.textStyle_w600('Pin Code', 14, Colors.black),
                          const SizedBox(height: 6),
                          MyEdittextfield(
                            hintText: 'Enter Pin',
                            controller: pincodeController,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                _buildLabel('Address'),
                _buildTextField('Enter address', addressController, maxLines: 3),

                _buildLabel('City'),
                _buildTextField('Enter City', cityController),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child:  MyElevatedButton(
          onPressed: (){
            _onSignUpPressed();
          },
          custom_design: false,
          buttonText: 'Signup',
          isLoading: _isLoading,
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 6),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      {int maxLines = 1, TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: AppColors.kPrimaryDark, width: 1),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}