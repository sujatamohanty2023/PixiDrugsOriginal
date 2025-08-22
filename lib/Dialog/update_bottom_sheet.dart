import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constant/color.dart';
import '../customWidget/MyElevatedButton.dart';
import '../customWidget/MyTextField.dart';

class UpdateBottomSheet extends StatelessWidget {
  const UpdateBottomSheet({super.key});

  //my app play store link
  final String storeUrl = "https://play.google.com/store/apps/details?id=com.example.app";

  Future<void> _launchStore() async {
    final Uri url = Uri.parse(storeUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // ✅ screen size
    final width = size.width;
    final height = size.height;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Top bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyTextfield.textStyle_w400(
                    'New Update Available!',
                    width * 0.05,
                    AppColors.kPrimary
                ),
              ],
            ),
            const SizedBox(height: 16),
            /// Illustration
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/update/update_1.jpg',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            /// Update button
            SizedBox(
              width: double.infinity,
              child: MyElevatedButton(
                  onPressed: _launchStore,
                  buttonText:  'New Update Available!',
              )
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
