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
        if (state.registerResponse.status) {
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
                MyTextfield.textStyle_w400('Name of the store', SizeConfig.screenWidth! *0.035, Colors.black54),
                SizedBox(height: 8),
                MyEdittextfield(
                    hintText: 'Enter ${AppString.storeName}', controller: storeNameController),

                SizedBox(height: screenHeight * 0.015),
                MyTextfield.textStyle_w400('Name of Owner/Proprietor', SizeConfig.screenWidth! *0.035, Colors.black54),
                SizedBox(height: 8),
                MyEdittextfield(
                    hintText: 'Enter ${AppString.ownerName}',
                    controller: ownerNameController),

                SizedBox(height: 8),
                MyTextfield.textStyle_w400('Mobile no. of Owner', SizeConfig.screenWidth! *0.035, Colors.black54),
                SizedBox(height: 8),
                MyEdittextfield(
                  controller: phoneController,
                  hintText: AppString.enterNumber,
                  keyboardType: TextInputType.phone),

                SizedBox(height: 8),
                MyTextfield.textStyle_w400('Email Id. of Owner/Store', SizeConfig.screenWidth! *0.035, Colors.black54),
                SizedBox(height: 8),
                MyEdittextfield(hintText: AppString.enterEmail, controller: emailController),

                SizedBox(height: 8),
                MyTextfield.textStyle_w400('GST NO. of Store', SizeConfig.screenWidth! *0.035, Colors.black54),
                SizedBox(height: 8),
                MyEdittextfield(
                    controller: gstController,
                    hintText: AppString.enterGst,
                    keyboardType: TextInputType.text),
                SizedBox(height: 8),
                MyTextfield.textStyle_w400('Licence No. of Store', SizeConfig.screenWidth! *0.035, Colors.black54),
                SizedBox(height: 8),
                MyEdittextfield(
                    controller: regController,
                    hintText: AppString.enterRegNo,
                    keyboardType: TextInputType.text),
                SizedBox(height: screenHeight * 0.015),

                MyTextfield.textStyle_w600('Location Details', 18, Colors.black),
                SizedBox(height: 8),
                MyTextfield.textStyle_w400('Address Of Store', SizeConfig.screenWidth! *0.035, Colors.black54),
                SizedBox(height: 8),
                MyEdittextfield(
                  controller: addressController,
                  hintText: 'Enter ${AppString.storeAddress}',
                  keyboardType: TextInputType.text,maxLines:2 ,),
                SizedBox(height: 8),
                MyTextfield.textStyle_w400('City', SizeConfig.screenWidth! *0.035, Colors.black54),
                SizedBox(height: 8),
                MyEdittextfield(
                  controller: cityController,
                  hintText: 'Enter City',
                  keyboardType: TextInputType.text),
                SizedBox(height: 8),
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
                      flex: 3,
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
                      flex: 4,
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
      child: MyTextfield.textStyle_w400(label,SizeConfig.screenWidth! * 0.038,Colors.black54),
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