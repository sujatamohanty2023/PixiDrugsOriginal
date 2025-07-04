import 'package:pixidrugs/login/OtpVerificationScreen.dart';

import 'package:pixidrugs/constant/all.dart';

class MobileLoginScreen extends StatefulWidget {

  @override
  _MobileLoginScreenState createState() => _MobileLoginScreenState();
}

class _MobileLoginScreenState extends State<MobileLoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  String errorMessage = '';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? verificationId;

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
              Text('reCAPTCHA verification failed. Please try again.')),
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
      backgroundColor: AppColors.kPrimary,
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
                  'assets/images/login.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            /// ⚪ Login Card Section
            Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: screenHeight * 0.45),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(100),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    const Text(
                      'Login with Mobile Number',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Enter your mobile number to receive an OTP',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.grey,
                      ),
                    ),
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
                            'assets/images/india.jpg',
                            height: 25,
                            width: 25,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '+91',
                            style: TextStyle(
                              color: AppColors.kPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              style: TextStyle(
                                color: AppColors.kPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlignVertical: TextAlignVertical.center,
                              decoration: const InputDecoration(
                                hintText: "Enter mobile number",
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 60),

                    /// 🔘 Continue Button
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: MaterialButton(
                        color: AppColors.kPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onPressed: () {
                           sendOTP();
                        },
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
