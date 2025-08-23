import 'package:PixiDrugs/constant/all.dart';

class ContactUsPage extends StatelessWidget {
  final String whatsappNumber = "9124004386";
  final String whatsappMessage = "Hello, I would like to discuss a project.";
  final String email = "Support@pixidrugs.com";
  final String website = "http://pixidrugs.com/";
  final String phone = "+91 9124004386";

  const ContactUsPage({super.key});

  Future<void> _launchWhatsApp() async {
    final url = Uri.parse(
        "https://wa.me/${whatsappNumber.replaceAll('+', '')}?text=${Uri.encodeFull(whatsappMessage)}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchEmail() async {
    final url = Uri.parse("mailto:$email");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchPhone() async {
    final url = Uri.parse("tel:$phone");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchWebsite() async {
    final url = Uri.parse(website);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // ✅ screen size
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: AppColors.kPrimary,
      body: Column(
        children: [
          // 🔵 Custom Header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              left: width * 0.04,
              right: width * 0.04,
              bottom: height * 0.01,
            ),
            color: AppColors.kPrimary,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: Colors.white, size: width * 0.07),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(width: width * 0.04),
                Text(
                  'Contact Us',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: width * 0.055,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 🔲 White Body
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: width * 0.04, vertical: width * 0.02),
              decoration: const BoxDecoration(
                color: AppColors.kWhiteColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 👉 Image and Text in a Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child:  MyTextfield.textStyle_w800(
                            "Get in touch if you need help with a project",width * 0.07, Colors.black,
                          ),
                        ),
                        Image.asset(AppImages.contact_us,
                          height: height * 0.30,
                          width: width * 0.50,
                          fit: BoxFit.cover,)
                      ],
                    ),

                    MyTextfield.textStyle_w800(
                      "For any custom requirement or any issues related to the app, please contact us.",
                      width * 0.035,
                      Colors.grey,
                    ),
                    SizedBox(height: height * 0.025),

                    // 👉 WhatsApp Button
                    ElevatedButton.icon(
                      onPressed: _launchWhatsApp,
                      icon: Image.asset(
                        AppImages.whatsapp,
                        height: 24,
                        width: 24,
                      ),
                      label: MyTextfield.textStyle_w800(
                          "Let's Chat", 14, Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.kPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.030),
                    MyTextfield.textStyle_w800(
                        "PixiDrugs", width * 0.045, Colors.black),
                    SizedBox(height: height * 0.015),

                    // 👉 Contact Info
                    ListTile(
                      visualDensity: const VisualDensity(horizontal: 0.0, vertical: -4.0),
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.phone_android, size: 20, color: AppColors.kPrimary),
                      title: MyTextfield.textStyle_w400(phone, width * 0.04, Colors.black,maxLines: true),
                      onTap: _launchPhone,
                    ),
                    ListTile(
                      visualDensity: const VisualDensity(horizontal: 0.0, vertical: -4.0),
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.email, size: 20, color: AppColors.kPrimary),
                      title: MyTextfield.textStyle_w400(email, 14, Colors.black, maxLines: true),
                      onTap: _launchEmail,
                    ),
                    ListTile(
                      visualDensity: const VisualDensity(horizontal: 0.0, vertical: -4.0),
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.language,
                          size: 20, color: AppColors.kPrimary),
                      title: MyTextfield.textStyle_w400(website, 14, Colors.black,maxLines: true),
                      onTap: _launchWebsite,
                    ),
                    SizedBox(height: height * 0.03),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
