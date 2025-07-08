import 'package:pixidrugs/Profile/WebviewScreen.dart';
import 'package:pixidrugs/Profile/edit_profile.dart';
import 'package:pixidrugs/constant/all.dart';
import 'package:pixidrugs/login/mobileLoginScreen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
  }

  class _ProfileScreenState extends State<ProfileScreen> {
    String? name = 'Guest';
    String? email = '';
    String? image = '';

    @override
    void initState() {
      super.initState();
      _GetProfileCall();
    }
    void _logoutFun() async {
      await SessionManager.clearSession();
      // await FCMService.clearFCMToken();
      setState(() {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MobileLoginScreen()),
              (route) => false,
        );
      });
    }

    void _GetProfileCall() async {
      String? userId = await SessionManager.getUserId();
      if (userId != null) {
        context.read<ApiCubit>().GetUserData(userId: userId);
      } else {
        setState(() {

        });
      }
      context.read<ApiCubit>().stream.listen((state) {
        if (state is UserProfileLoaded) {
          setState(() {
            name = state.userModel.name;
            email = state.userModel.email;
            image = state.userModel.profilePicture;
          });
        } else if (state is UserProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${state.error}')),
          );
        }
      });
    }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: AppColors.kPrimary,
        width: double.infinity,
        padding: EdgeInsets.only(top: 50),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 16, left: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.kWhiteColor,
                    backgroundImage: image!.isNotEmpty
                        ? image!.contains('https://')
                        ? NetworkImage(image!)
                        : image!.contains('NO')
                        ? AssetImage(AppImages.AppIcon)
                        : NetworkImage('${AppString.baseUrl}${image!}')
                        : AssetImage(AppImages.AppIcon),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyTextfield.textStyle_w800(
                          name!, AppUtils.size_25, Colors.white,
                          maxLines: 1),
                      MyTextfield.textStyle_w600(
                          email!, AppUtils.size_14, Colors.white70),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 15),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                  ),
                ),
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    GestureDetector(
                      onTap: (){
                        AppRoutes.navigateTo(context, EditProfileScreen());
                      },
                      child: _buildMenuItem(Icons.person, "Edit Profile", Colors.blue),
                    ),
                    GestureDetector(
                      onTap: (){

                      },
                      child: _buildMenuItem(Icons.note_add, "Report", Colors.orange),
                    ),
                    GestureDetector(
                      onTap: (){
                        AppRoutes.navigateTo(context, Webviewscreen(tittle: 'About Us'));
                      },
                      child: _buildMenuItem(Icons.info, "About Us", Colors.pink),
                    ),
                    GestureDetector(
                      onTap: (){
                        AppRoutes.navigateTo(context, Webviewscreen(tittle: 'Contact Us'));
                      },
                      child: _buildMenuItem(Icons.call, "Contact Us", Colors.green),
                    ),
                    GestureDetector(
                      onTap: (){
                        AppRoutes.navigateTo(context,  Webviewscreen(tittle: 'Privacy Policy'));
                      },
                      child: _buildMenuItem(Icons.privacy_tip, "Privacy Policy", Colors.blueAccent),
                    ),
                    GestureDetector(
                      onTap: (){
                        AppRoutes.navigateTo(context,Webviewscreen(tittle: 'Terms & Conditions'));
                      },
                      child: _buildMenuItem(Icons.description, "Terms & Conditions", Colors.purple),
                    ),
                    GestureDetector(
                      onTap: (){
                        String message ="Check out this awesome app!";
                        Share.share(message);
                      },
                      child: _buildMenuItem(Icons.share, "Share/Invite Friends", Colors.cyan),
                    ),
                    GestureDetector(
                      onTap: (){
                        RateUs();
                      },
                      child: _buildMenuItem(Icons.star, "Rating our App", Colors.yellow),
                    ),
                    GestureDetector(
                      onTap: (){
                        _showLogoutBottomSheet(context, onPressed: _logoutFun);
                      },
                      child: _buildMenuItem(Icons.logout, "Log Out", Colors.deepOrange),
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
    void RateUs() {
      showDialog(
        context: context,
        barrierDismissible: true, // set to false if you want to force a rating
        builder: (context) => _dialog,
      );
    }

    final _dialog = RatingDialog(
      initialRating: 1.0,
      // your app's name?
      title:
      MyTextfield.textStyle_w800("Rating PixiDrugs", 25, Colors.black),
      // encourage your user to leave a high rating?
      message: MyTextfield.textStyle_w600(
          "Tap a star to set your rating. Add more description here if you want.",
          15,
          AppColors.kBlackColor800),
      // your app's logo?
      image: const FlutterLogo(size: 100),
      submitButtonText: 'Submit',
      submitButtonTextStyle:
      MyTextfield.textStyle(18, AppColors.kPrimary, FontWeight.w800),
      commentHint: 'Set your custom comment hint',
      onCancelled: () => print('cancelled'),
      onSubmitted: (response) {
        print('rating: ${response.rating}, comment: ${response.comment}');

        // TODO: add your own logic
        if (response.rating < 3.0) {
          // send their comments to your email or anywhere you wish
          // ask the user to contact you instead of leaving a bad review
        } else {
          _launchUrl();
        }
      },
    );
  }

Future _launchUrl() async {
  final String url = "http://play.google.com/store/apps/details?id=";
  final String packageName = "com.pixiglam.pixidrugs";
  final Uri _url = Uri.parse(url + packageName);
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}
void _showLogoutBottomSheet(BuildContext context,
        {required VoidCallback onPressed}) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 170,
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                MyTextfield.textStyle_w800(
                    'Are you sure you want to log out?', 20, Colors.black87),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: AppStyles.elevatedButton_style(
                            color: AppColors.kGreyColor800),
                        child: MyTextfield.textStyle_w800(
                            'Cancel', 18, AppColors.kWhiteColor),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                        child: ElevatedButton(
                          onPressed: onPressed,
                          style: AppStyles.elevatedButton_style(color: Colors.red),
                          child: MyTextfield.textStyle_w800(
                              'Logout', 18, AppColors.kWhiteColor),
                        ))
                  ],
                )
              ],
            ),
          );
        },
      );
    }
  Widget _buildMenuItem(IconData icon, String title, Color iconBgColor) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconBgColor, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: MyTextfield.textStyle_w600(title, 16, Colors.black87),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.kPrimaryDark),
          ],
        ),
        SizedBox(height: 6),
        Padding(
          padding: EdgeInsets.only(left: 56), // Align divider after icon
          child: Divider(color: AppColors.kPrimaryLight,thickness:1,),
        ),
      ],
    );
  }