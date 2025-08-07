import 'package:PixiDrugs/constant/all.dart';
import 'package:PixiDrugs/login/FCMService.dart';

import '../Profile/WebviewScreen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final LoginResponse loginResponse;

  const OtpVerificationScreen({super.key, required this.phoneNumber,required this.loginResponse});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>{
  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());
  final FocusNode _focusNode = FocusNode();
  int _resendSeconds = 30;
  late final Timer _timer;
  String? verificationId='';
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
        print("Automatically signed in");
        setState(() {
          verificationId = credential.verificationId;
        });
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
        });
        print("OTP Sent");
      },
      codeAutoRetrievalTimeout: (String verId) {
        print("Auto retrieval timeout");
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
    setState(() {
      _isLoading = true;
    });
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId??'',
        smsCode: otp!,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      print("User signed in: ${userCredential.user?.uid}");
      await _saveRole();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("OTP Verification Failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP Verification Failed $otp")),
      );
    }
  }

  void _verifyOTP() {
    otp = _enteredOtp;
    if (otp?.length == 6) {
      firebaseCheck();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
    }
  }
  Future<void> _saveRole() async {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.loginResponse.message)),
    );
    await SessionManager.saveLoginResponse(widget.loginResponse);
    Navigator.pop(context);
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }
  void _resendOtp() {
    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        print('Verification failed: ${e.message}');
      },
      codeSent: (String verificationId1, int? resendToken) {
        setState(() {
          verificationId = verificationId1; // ✅ update it here
          _resendSeconds = 30;
          _startResendTimer();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP Resent")),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    _focusNode.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).nextFocus();
    }
    if (value.isEmpty && index > 0) {
      FocusScope.of(context).previousFocus();
    }
  }

  String get _enteredOtp =>
      _otpControllers.map((c) => c.text).join().trim();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.loginbg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 🔷 Image on Top
            const SizedBox(height: 50),
            Image.asset(
              AppImages.otpIcon,
              height: MediaQuery.of(context).size.height * 0.5,
              fit: BoxFit.contain,
            ),

            /// ⚪ OTP Container
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.myGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(100),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  MyTextfield.textStyle_w800(AppString.verifyOtp, 28, AppColors.kPrimary),
                  const SizedBox(height: 16),
                  MyTextfield.textStyle_w300(AppString.otpdesc, 16, Colors.black54),
                  const SizedBox(height: 20),

                  /// 🔢 OTP Boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 50,
                        child: TextField(
                          controller: _otpControllers[index],
                          focusNode: index == 0 ? _focusNode : null,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          style:MyTextfield.textStyle(25 ,AppColors.kPrimary,FontWeight.w600),
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
                                width: 1,
                              ),
                            ),
                          ),

                          onChanged: (value) => _onOtpChanged(index, value),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 20),

                  /// ⏱ Resend text

                  GestureDetector(
                      onTap: _resendSeconds == 0 ? _resendOtp : null,
                      child: MyTextfield.textStyle_w600( _resendSeconds == 0
                          ? "Resend OTP"
                          : "Resend in $_resendSeconds s", 16, _resendSeconds == 0 ? Colors.red : Colors.grey)
                  ),

                  const SizedBox(height: 20),

                  /// ✅ Submit Button
                  SizedBox(
                      height: 48,
                      width: double.infinity,
                      child:MyElevatedButton(
                        onPressed:_verifyOTP,
                        custom_design: false,
                        buttonText: AppString.verify_continue,
                        isLoading: _isLoading,
                      )
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
