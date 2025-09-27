import 'package:flutter/gestures.dart';
import '../../constant/all.dart';
import '../login/RegisterResponse.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../Address/MapScreen.dart';
import '../Profile/WebviewScreen.dart';
import '../Profile/contact_us.dart';
import 'package:latlong2/latlong.dart';


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
  LatLng? currentLatLng;
  Placemark? place;
  String selectedGender = "Male";
  bool _isLoading = false;
  bool _isChecked = false;
  StreamSubscription? _registerSubscription;

  Future<void> _selectAddress(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapScreen()),
    );
    setState(() async {
      currentLatLng=result;
      await getAddressFromLatLng(currentLatLng!.latitude,currentLatLng!.longitude);
      addressController.text = [
        place?.subLocality,
        place?.locality,
        place?.postalCode,
        place?.country
      ]
          .where((element) => element != null && element.isNotEmpty)
          .join(', ');
    });
  }
  Future<void> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        place = placemarks[0];
      }
    } catch (e) {
      print("Error getting address: $e");
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _ensureLocationPermission();
  }
  Future<bool> _ensureLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission denied")),
      );
      return false;
    }
    return true;
  }



  Future<void> _onSignUpPressed() async {

    String name= storeNameController.text;
    String ownerName= ownerNameController.text;
    String email= emailController.text;
    String phoneNumber= phoneController.text;
    String gstin= gstController.text;
    String license= regController.text;
    String address= addressController.text;

    if (name.isEmpty || ownerName.isEmpty || email.isEmpty || phoneNumber.isEmpty || gstin.isEmpty|| license.isEmpty|| address.isEmpty) {
      // Show a SnackBar error message if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all the fields."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    RegisterModel model = RegisterModel(
      name: name,
      ownerName: ownerName,
      email: email,
      phoneNumber: phoneNumber,
      gstin: gstin,
      license: license,
      address: addressController.text,
      city:place!.locality!,
      state:place!.administrativeArea!,
      pincode:place!.postalCode!,
      country: 'India',
      gander: 'NA',
      dob: '',
      password: '',
    );

    context.read<ApiCubit>().register(model: model);

    await _registerSubscription?.cancel();
    _registerSubscription = context.read<ApiCubit>().stream.listen((state) {
      if (state is RegisterLoaded) {
        setState(() => _isLoading = false);

        final res = state.registerResponse;
        if (res.status) {
          AppUtils.showSnackBar(context, res.message);
          Navigator.pop(context);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ContactUsPage(),
            ),
          );
        }
      } else if (state is RegisterError) {
        setState(() => _isLoading = false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.handleApiError(state.error, () => _onSignUpPressed());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.kPrimary,
      appBar: AppBar(
        title:  MyTextfield.textStyle_w400('Signup',
            SizeConfig.screenWidth! * 0.055, Colors.white),
        backgroundColor: AppColors.kPrimary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            gradient: AppColors.myGradient,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(screenWidth * 0.07),
              topLeft: Radius.circular(screenWidth * 0.07),
            ),
          ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                MyTextfield.textStyle_w400('Name of the store',
                    SizeConfig.screenWidth! * 0.035, Colors.black54),
                SizedBox(height:SizeConfig.screenHeight! * 0.015),
                MyEdittextfield(
                    hintText: 'Enter ${AppString.storeName}',
                    controller: storeNameController),

                SizedBox(height: SizeConfig.screenHeight! * 0.015),
                MyTextfield.textStyle_w400('Name of Owner/Proprietor',
                    SizeConfig.screenWidth! * 0.035, Colors.black54),

                MyEdittextfield(
                    hintText: 'Enter ${AppString.ownerName}',
                    controller: ownerNameController),

                SizedBox(height:SizeConfig.screenHeight! * 0.010),

                MyTextfield.textStyle_w400(
                    "Choose Gender", SizeConfig.screenWidth! * 0.035, Colors.black54),
                SizedBox(height:SizeConfig.screenHeight! * 0.010),
                Row(
                  children: [
                    SizedBox(height: 16),
                    ChooseGender(
                      label: "Male",
                      icon: Icons.male_outlined,
                      selected: selectedGender == "Male",
                      onTap: () {
                        setState(() {
                          selectedGender = "Male";
                        });
                      },
                    ),
                    ChooseGender(
                      label: "Female",
                      icon: Icons.female_outlined,
                      selected: selectedGender == "Female",
                      onTap: () {
                        setState(() {
                          selectedGender = "Female";
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: SizeConfig.screenHeight! * 0.010),

                MyTextfield.textStyle_w400('Mobile no. of Owner',
                    SizeConfig.screenWidth! * 0.035, Colors.black54),
                SizedBox(height:SizeConfig.screenHeight! * 0.015),
                MyEdittextfield(
                    controller: phoneController,
                    hintText: AppString.enterNumber,
                    keyboardType: TextInputType.phone),

                 SizedBox(height:SizeConfig.screenHeight! * 0.015),
                MyTextfield.textStyle_w400('Email Id. of Owner/Store',
                    SizeConfig.screenWidth! * 0.035, Colors.black54),
                 SizedBox(height:SizeConfig.screenHeight! * 0.015),
                MyEdittextfield(
                    hintText: AppString.enterEmail, controller: emailController),

                 SizedBox(height:SizeConfig.screenHeight! * 0.015),
                MyTextfield.textStyle_w400('GST NO. of Store',
                    SizeConfig.screenWidth! * 0.035, Colors.black54),
                 SizedBox(height:SizeConfig.screenHeight! * 0.015),
                MyEdittextfield(
                    controller: gstController,
                    hintText: AppString.enterGst,
                    keyboardType: TextInputType.text),
                 SizedBox(height:SizeConfig.screenHeight! * 0.015),
                MyTextfield.textStyle_w400('Licence No. of Store',
                    SizeConfig.screenWidth! * 0.035, Colors.black54),
                SizedBox(height:SizeConfig.screenHeight! * 0.015),
                MyEdittextfield(
                    controller: regController,
                    hintText: AppString.enterRegNo,
                    keyboardType: TextInputType.text),
                SizedBox(height: SizeConfig.screenHeight! * 0.015),
                MyTextfield.textStyle_w400('Address Of Store',
                    SizeConfig.screenWidth! * 0.035, Colors.black54),
                SizedBox(height: SizeConfig.screenHeight! * 0.015),
                MyEdittextfield(
                    controller: addressController,
                    hintText: 'Enter ${AppString.storeAddress}',
                    keyboardType: TextInputType.text,
                    maxLines: 3,
                    readOnly: true, // ✅ prevents keyboard from opening
                    onTap: () async {
                      _selectAddress(context);
                    }
                ),
                 SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar:
      Container(
        decoration: BoxDecoration(
          color: Colors.white, // ✅ change to AppColors.kPrimary, etc.
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2), // shadow on top
            ),
          ],
        ),

        child: Padding(
          padding:  EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    checkColor: AppColors.kPrimary,
                    fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                      if (states.contains(MaterialState.selected)) {
                        return AppColors.kPrimaryLight;
                      }
                      return Colors.grey.shade300;
                    }),
                    value: _isChecked,
                    onChanged: (value) {
                      setState(() {
                        _isChecked = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: MyTextfield.textStyle(
                          14,
                          Colors.black,
                          FontWeight.w400,
                        ),
                        children: [
                           TextSpan(
                              text: "I confirm that I have read, consent and agree to your "),
                          TextSpan(
                            text: "terms and conditions",
                            style:  TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                AppRoutes.navigateTo(context,
                                    Webviewscreen(tittle: 'Terms & Conditions'));
                              },
                          ),
                           TextSpan(text: " and "),
                          TextSpan(
                            text: "Privacy Policy",
                            style:  TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                AppRoutes.navigateTo(
                                    context, Webviewscreen(tittle: 'Privacy Policy'));
                              },
                          ),
                           TextSpan(
                            text:
                            ", and I am of legal age. I understand that I can change my communication preferences anytime.",
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
               SizedBox(height: 10),
              _isChecked
                  ? MyElevatedButton(
                onPressed: _onSignUpPressed,
                custom_design: false,
                buttonText: 'Signup',
                isLoading: _isLoading,
              )
                  :  SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
  Widget ChooseGender({required String label, required IconData icon, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? AppColors.kPrimary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected
                  ? AppColors.kPrimary
                  : AppColors.kPrimary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? Colors.white : AppColors.kPrimary, size: 15),
            SizedBox(width: 3),
            MyTextfield.textStyle_w600(
                label, 15, selected ? Colors.white : Colors.grey),
          ],
        ),
      ),
    );
  }
}