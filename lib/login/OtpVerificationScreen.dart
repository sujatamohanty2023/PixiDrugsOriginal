import 'package:pixidrugs/constant/all.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());
  final FocusNode _focusNode = FocusNode();
  int _resendSeconds = 30;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
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

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
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
      backgroundColor: AppColors.kPrimaryLight,
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 🔷 Image on Top
            const SizedBox(height: 50),
            Image.asset(
              'assets/images/otp.png',
              height: MediaQuery.of(context).size.height * 0.5,
              fit: BoxFit.contain,
            ),

            /// ⚪ OTP Container
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(100),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  const Text(
                    "Verify OTP",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                      'Enter the 6-digit code we sent to verify your number and continue with secure access to your PixiDrugs account.',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

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
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
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
                                width: 1,
                              ),
                            ),
                          ),

                          onChanged: (value) => _onOtpChanged(index, value),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 15),

                  /// ⏱ Resend text
                  TextButton(
                    onPressed: _resendSeconds == 0 ? () {
                      _startResendTimer();
                      // Trigger resend logic
                    } : null,
                    child: Text(
                      _resendSeconds == 0
                          ? "Resend OTP"
                          : "Resend in $_resendSeconds s",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _resendSeconds == 0
                            ? Colors.red
                            : Colors.grey,
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  /// ✅ Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: MaterialButton(
                      color: AppColors.kPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onPressed: () {
                        final otp = _enteredOtp;
                        if (otp.length == 6) {
                          AppRoutes.navigateToHome(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter 6-digit OTP"),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Verify",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
