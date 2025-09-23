import '../constant/all.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final LoginResponse loginResponse;

  const OtpVerificationScreen({super.key, required this.phoneNumber, required this.loginResponse});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  int _resendSeconds = 30;
  late final Timer _timer;
  String? verificationId;
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? otp;

  @override
  void initState() {
    super.initState();
    sendOTP();
    _startResendTimer();
  }

  Future<void> sendOTP() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        setState(() => verificationId = credential.verificationId);
      },
      verificationFailed: (FirebaseAuthException e) {
        AppUtils.showSnackBar(context, 'Verification failed: ${e.message}');
      },
      codeSent: (String verId, int? resendToken) {
        setState(() => verificationId = verId);
      },
      codeAutoRetrievalTimeout: (String verId) {
        // Optional
      },
    );
  }

  void _startResendTimer() {
    _resendSeconds = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds == 0) {
        timer.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  Future<void> firebaseCheck() async {
    setState(() => _isLoading = true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId ?? '',
        smsCode: otp!,
      );

      await _auth.signInWithCredential(credential);
      await _saveRole();
    } catch (e) {
      setState(() => _isLoading = false);
      AppUtils.showSnackBar(context, "Invalid or expired OTP");
    }
  }

  void _verifyOTP() {
    otp = _enteredOtp;
    if (otp?.length == 6) {
      firebaseCheck();
    } else {
      AppUtils.showSnackBar(context, 'Please enter a valid 6-digit OTP');
    }
  }

  Future<void> _saveRole() async {
    AppUtils.showSnackBar(context, widget.loginResponse.message);
    await SessionManager.saveLoginResponse(widget.loginResponse);
    Navigator.pop(context);
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  void _resendOtp() {
    _auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (_) {},
      verificationFailed: (FirebaseAuthException e) {
        print('Resend failed: ${e.message}');
      },
      codeSent: (String verificationId1, int? resendToken) {
        setState(() {
          verificationId = verificationId1;
          _resendSeconds = 30;
          _startResendTimer();
        });
        AppUtils.showSnackBar(context, "OTP Resent");
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).nextFocus();
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).previousFocus();
    }
  }

  String get _enteredOtp => _otpControllers.map((c) => c.text).join().trim();

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.login_new,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // 🔝 Image Section: Flexible space
            Expanded(
              flex: 5,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: screenHeight * 0.04),
                child: Image.asset(
                  AppImages.otpIcon,
                  fit: BoxFit.contain,
                  width: screenWidth * 0.8,
                  // No fixed height → let BoxFit.contain handle scaling
                ),
              ),
            ),

            // ⚪ OTP Card: Remaining space
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: AppColors.myGradient,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(100),
                  ),
                ),
                child: SingleChildScrollView(
                  // ✅ Scroll only if content overflows (e.g., small screen + keyboard)
                  physics: const ClampingScrollPhysics(), // Normal scroll
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.07,
                    vertical: screenHeight * 0.02,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Responsive Text Sizes using SizeConfig
                      MyTextfield.textStyle_w800(
                        AppString.verifyOtp,
                        SizeConfig.screenWidth! * 0.06,
                        AppColors.kPrimary,
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      MyTextfield.textStyle_w300(
                        AppString.otpdesc,
                        SizeConfig.screenWidth! * 0.035,
                        Colors.black54,
                      ),
                      SizedBox(height: screenHeight * 0.03),

                      // 🔢 OTP Input Fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: screenWidth * 0.12,
                            child: TextField(
                              controller: _otpControllers[index],
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConfig.screenWidth! * 0.06,
                                fontWeight: FontWeight.w600,
                                color: AppColors.kPrimary,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: AppColors.kPrimary.withOpacity(0.08),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: _otpControllers[index].text.isNotEmpty
                                        ? AppColors.kPrimary
                                        : Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: AppColors.kPrimary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (value) => _onOtpChanged(index, value),
                            ),
                          );
                        }),
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      // ⏱ Resend Timer
                      GestureDetector(
                        onTap: _resendSeconds == 0 ? _resendOtp : null,
                        child: Text(
                          _resendSeconds == 0
                              ? "Resend OTP"
                              : "Resend in $_resendSeconds s",
                          style: TextStyle(
                            color: _resendSeconds == 0 ? Colors.red : Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      // ✅ Verify Button
                      SizedBox(
                        height: screenHeight * 0.07,
                        width: double.infinity,
                        child: MyElevatedButton(
                          onPressed: _verifyOTP,
                          custom_design: false,
                          buttonText: AppString.verify_continue,
                          isLoading: _isLoading,
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.02),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}