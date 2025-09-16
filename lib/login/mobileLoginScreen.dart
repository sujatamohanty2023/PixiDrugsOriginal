import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Profile/contact_us.dart';
import 'OtpVerificationScreen.dart';
import '../constant/all.dart';
import '../Profile/WebviewScreen.dart';
import 'FCMService.dart';
import 'RegistationPage.dart';

class MobileLoginScreen extends StatefulWidget {
  @override
  _MobileLoginScreenState createState() => _MobileLoginScreenState();
}

class _MobileLoginScreenState extends State<MobileLoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  bool _isLoading = false;
  User? user;
  StreamSubscription? _loginSubscription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.loginbg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double screenHeight = constraints.maxHeight;
            final double screenWidth = constraints.maxWidth;

            return Column(
              children: [
                // 🔝 Image Section: 60% of screen height
                Container(
                  height: screenHeight * 0.50, // Fixed 60% of screen
                  width: screenWidth,
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: screenHeight * 0.05),
                  child: Stack(
                    children: [
                      // 📷 Add your registration icon image here
                      Image.asset(
                        AppImages.LoginIcon,
                        fit: BoxFit.contain,
                        width: screenWidth * 0.9,
                      ),
                      const SizedBox(height: 8),
                      Positioned(
                        right: 0,
                        bottom: 10,
                        child: GestureDetector(
                        onTap: () {
                          AppRoutes.navigateTo(
                            context,
                            SignUpScreen(),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.secondaryColor,
                              borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0,bottom: 8,right: 20,left: 20),
                            child: MyTextfield.textStyle_w600(
                              "New Registration", // (Consider fixing the spelling here)
                              SizeConfig.screenWidth! * 0.055,
                              AppColors.kWhiteColor,
                            ),
                          ),
                        ),
                      )
                      )

                    ],
                  ),
                ),

                // 🔝 Bottom Card: 40% of screen
                Container(
                  height: screenHeight * 0.50, // Fixed 40%
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: AppColors.myGradient,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(80),
                    ),
                  ),
                  child: SingleChildScrollView( // ✅ Only this part scrolls if needed (safe fallback)
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                      vertical: screenHeight * 0.02,
                    ),
                    child: _buildLoginForm(screenWidth, screenHeight),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
  Widget _buildLoginForm(double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: screenHeight * 0.03),
        MyTextfield.textStyle_w800(AppString.loginText, SizeConfig.screenWidth! * 0.06, AppColors.kPrimary),
        SizedBox(height: screenHeight * 0.015),
        MyTextfield.textStyle_w300(AppString.logindesc, SizeConfig.screenWidth! * 0.035, Colors.black54),
        SizedBox(height: screenHeight * 0.02),

        // 📞 Phone Input
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.kPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.kPrimary.withOpacity(0.5),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Image.asset(AppImages.indiaIcon, height: 24, width: 24),
              const SizedBox(width: 6),
              MyTextfield.textStyle_w600('+91', SizeConfig.screenWidth! * 0.045, AppColors.kPrimary),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: MyTextfield.textStyle(SizeConfig.screenWidth! * 0.045, AppColors.kPrimary, FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: AppString.enterMobileNo,
                    hintStyle: MyTextfield.textStyle(SizeConfig.screenWidth! * 0.045, Colors.grey, FontWeight.w300),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: screenHeight * 0.03),

        // 🔘 Continue Button
        SizedBox(
          height: screenHeight * 0.07,
          width: double.infinity,
          child: MyElevatedButton(
            onPressed: () {
              if (phoneController.text.trim().isNotEmpty) {
                loginApiCall(phoneController.text.trim());
              } else {
                AppUtils.showSnackBar(context, 'Please enter mobile number');
              }
            },
            custom_design: false,
            buttonText: AppString.continueText,
            isLoading: _isLoading,
          ),
        ),

        SizedBox(height: screenHeight * 0.02),

        // 🔘 Google Sign-In
        GestureDetector(
          onTap: signInWithGoogle,
          child: Container(
            width: double.infinity,
            height: screenHeight * 0.07,
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(AppImages.gmail, height: SizeConfig.screenWidth! * 0.045, width: SizeConfig.screenWidth! * 0.045),
                const SizedBox(width: 5),
                MyTextfield.textStyle_w600("Continue with Gmail", SizeConfig.screenWidth! * 0.045, Colors.white),
              ],
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
      ],
    );
  }
  // Google Sign-In
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        AppUtils.showSnackBar(context, "Sign-in cancelled");
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      await loginApiCall(userCredential.user!.email!);
    } catch (e) {
      AppUtils.showSnackBar(context, "Sign-in failed: $e");
    }
  }

  // API Call
  Future<void> loginApiCall(String text) async {
    setState(() {
      _isLoading = true;
    });

    String? fcmToken = await FCMService.getFCMToken();
    if (fcmToken == null) {
      AppUtils.showSnackBar(context, "Failed to get FCM token");
      setState(() => _isLoading = false);
      return;
    }

    context.read<ApiCubit>().login(text: text, fcm_token: fcmToken);

    await _loginSubscription?.cancel();
    _loginSubscription = context.read<ApiCubit>().stream.listen((state) {
      if (state is LoginLoaded) {
        setState(() => _isLoading = false);

        final res = state.loginResponse;
        if (res.success && res.user?.status == 'active') {
          if (text.contains('@')) {
            _saveRole(res);
          } else {
            AppRoutes.navigateTo(
              context,
              OtpVerificationScreen(
                phoneNumber: '+91${phoneController.text.trim()}',
                loginResponse: res,
              ),
            );
          }
        } else {
          showLoginFailedDialog(context);
        }
      } else if (state is LoginError) {
        setState(() => _isLoading = false);
        AppUtils.showSnackBar(context, state.error);
      }
    });
  }

  Future<void> showLoginFailedDialog(BuildContext context) async {
    bool _navigatedToContact = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: MyTextfield.textStyle_w600("Login Failed", 20, AppColors.kPrimary),
        content: MyTextfield.textStyle_w300(
          "Please contact our support team for assistance.",
          14,
          AppColors.kBlackColor800,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: MyTextfield.textStyle_w800('Cancel', 16, AppColors.kRedColor),
          ),
          TextButton(
            onPressed: () {
              if (_navigatedToContact) return;
              _navigatedToContact = true;
              Navigator.of(ctx).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ContactUsPage()/*Webviewscreen(tittle: 'Contact Us')*/,
                ),
              );
            },
            child: MyTextfield.textStyle_w800('Contact', 16, AppColors.kPrimary),
          ),
        ],
      ),
    );
  }

  Future<void> _saveRole(LoginResponse loginResponse) async {
    AppUtils.showSnackBar(context, loginResponse.message);
    await SessionManager.saveLoginResponse(loginResponse);
    Navigator.pop(context);
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  @override
  void dispose() {
    _loginSubscription?.cancel();
    phoneController.dispose();
    super.dispose();
  }
}