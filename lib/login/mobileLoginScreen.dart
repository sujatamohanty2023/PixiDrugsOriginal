import 'package:PixiDrugs/login/OtpVerificationScreen.dart';

import 'package:PixiDrugs/constant/all.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../Profile/WebviewScreen.dart';
import 'FCMService.dart';

class MobileLoginScreen extends StatefulWidget {

  @override
  _MobileLoginScreenState createState() => _MobileLoginScreenState();
}

class _MobileLoginScreenState extends State<MobileLoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  String errorMessage = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? verificationId;
  User? user;

  Future<void> sendOTP() async {
    final phoneNumber = '+91${phoneController.text.trim()}';
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        print("Automatically signed in");
        verificationId = credential.verificationId;
        AppRoutes.navigateTo(
            context, OtpVerificationScreen(phoneNumber:phoneController.text, verificationId:verificationId!));
      },
      verificationFailed: (FirebaseAuthException e) {
        print("Verification failed: ${e.message}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
              MyTextfield.textStyle_w300('Verification failed: ${e.message}', 16, Colors.white)),
        );
      },
      codeSent: (String verId, int? resendToken) {
        setState(() {
          verificationId = verId;
          AppRoutes.navigateTo(
              context, OtpVerificationScreen(phoneNumber:phoneController.text,verificationId: verificationId!));
        });
        print("OTP Sent");
      },
      codeAutoRetrievalTimeout: (String verId) {
        print("Auto retrieval timeout");
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.loginbg,
      body: SingleChildScrollView( // ✅ Handles keyboard scroll
        child: Column(
          children: [
            /// 🔷 Image on Top
            SizedBox(
              height: screenHeight * 0.55,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: Image.asset(
                  AppImages.LoginIcon,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            /// ⚪ Login Card Section
            Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: screenHeight * 0.45),
              decoration: const BoxDecoration(
                gradient: AppColors.myGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(100),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    MyTextfield.textStyle_w800(AppString.loginText, 28, AppColors.kPrimary),
                    const SizedBox(height: 28),
                    MyTextfield.textStyle_w300(AppString.logindesc, 18, Colors.black54),
                    const SizedBox(height: 16),

                    /// 📞 Phone Input Row
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.kPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.kPrimary.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            AppImages.indiaIcon,
                            height: 25,
                            width: 25,
                          ),
                          const SizedBox(width: 6),
                          MyTextfield.textStyle_w600('+91',20,AppColors.kPrimary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              style: MyTextfield.textStyle(20 ,AppColors.kPrimary,FontWeight.w600),
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                hintText:AppString.enterMobileNo,
                                hintStyle: MyTextfield.textStyle(16 ,Colors.grey,FontWeight.w300),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 🔘 Continue Button
                    SizedBox(
                        height: 48,
                        width: double.infinity,
                        child:MyElevatedButton(
                          onPressed: () {
                            sendOTP();
                          },
                          custom_design: false,
                          buttonText: AppString.continueText,
                        )
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap:signInWithGoogle,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius:BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                AppImages.gmail, // add this asset if needed
                                height: 30,
                                width: 30,
                              ),
                              const SizedBox(width: 10),
                              MyTextfield.textStyle_w600("Continue with Gmail", 18, Colors.white),
                            ],
                          ),
                        ),
                      ),
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
  void signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    setState(() {
      user = null;
    });
  }
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (user != null) {
        signOut();
      }

      if (googleUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sign-in cancelled")),
        );
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      setState(() {
        user = userCredential.user;
      });
      await loginApiCall(user);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign-in failed: $e")),
      );
    }
  }
  Future<void> loginApiCall(User? user) async {
    String? fcm_token = await FCMService.getFCMToken();

    if (fcm_token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to get FCM token")),
      );
      return;
    }
    print('API URL: ${user!.email}\n$fcm_token');
    context.read<ApiCubit>().login(text: user.email!, fcm_token: fcm_token);

    context.read<ApiCubit>().stream.listen((state) {
      if (state is LoginLoaded) {
        if(state.loginResponse.success && state.loginResponse.user?.status=='active'){
          _saveRole(state.loginResponse);
        }else{
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login Failed.Please contact our support team')),
          );
          AppRoutes.navigateTo(
              context, Webviewscreen(tittle: 'Contact Us'));
        }
      } else if (state is LoginError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error)),
        );
      }
    });
  }
  Future<void> _saveRole(LoginResponse loginResponse) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loginResponse.message)),
    );
    await SessionManager.saveLoginResponse(loginResponse);
    Navigator.pop(context);
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }
}
