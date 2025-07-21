import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pixidrugs/Profile/StaffAddBottomSheet.dart';
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
      context
          .read<ApiCubit>()
          .stream
          .listen((state) {
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
      final screenHeight = MediaQuery
          .of(context)
          .size
          .height;

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
                        onTap: () {
                          AppRoutes.navigateTo(context, EditProfileScreen());
                        },
                        child: _buildMenuItem(
                            Icons.edit, "Edit Profile", Colors.blue),
                      ),
                      GestureDetector(
                        onTap: () {
                          ShowStaffDialog();
                        },
                        child: _buildMenuItem(Icons.person, "Add/Edit Staff",
                            Colors.purpleAccent),
                      ),
                      GestureDetector(
                        onTap: () {

                        },
                        child: _buildMenuItem(
                            Icons.note_add, "Report", Colors.orange),
                      ),
                      GestureDetector(
                        onTap: () {
                          AppRoutes.navigateTo(
                              context, Webviewscreen(tittle: 'About Us'));
                        },
                        child: _buildMenuItem(
                            Icons.info, "About Us", Colors.pink),
                      ),
                      GestureDetector(
                        onTap: () {
                          AppRoutes.navigateTo(
                              context, Webviewscreen(tittle: 'Contact Us'));
                        },
                        child: _buildMenuItem(
                            Icons.call, "Contact Us", Colors.green),
                      ),
                      GestureDetector(
                        onTap: () {
                          AppRoutes.navigateTo(
                              context, Webviewscreen(tittle: 'Privacy Policy'));
                        },
                        child: _buildMenuItem(
                            Icons.privacy_tip, "Privacy Policy",
                            Colors.blueAccent),
                      ),
                      GestureDetector(
                        onTap: () {
                          AppRoutes.navigateTo(context,
                              Webviewscreen(tittle: 'Terms & Conditions'));
                        },
                        child: _buildMenuItem(
                            Icons.description, "Terms & Conditions",
                            Colors.purple),
                      ),
                      GestureDetector(
                        onTap: () {
                          String message = "Check out this awesome app!";
                          Share.share(message);
                        },
                        child: _buildMenuItem(
                            Icons.share, "Share/Invite Friends", Colors.cyan),
                      ),
                      GestureDetector(
                        onTap: () {
                          RateUs();
                        },
                        child: _buildMenuItem(
                            Icons.star, "Rating our App", Colors.yellow),
                      ),
                      GestureDetector(
                        onTap: () {
                          _showLogoutBottomSheet(
                              context, onPressed: _logoutFun);
                        },
                        child: _buildMenuItem(
                            Icons.logout, "Log Out", Colors.deepOrange),
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

    void ShowStaffDialog() {
      String? staffName = '';
      String? staffPhone = '';
      String? staffEmail = '';

      showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.kWhiteColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
        ),
        constraints: BoxConstraints.loose(Size(
          SizeConfig.screenWidth!,
          SizeConfig.screenHeight! * 0.60,
        )),
        isScrollControlled: false,
        builder: (_) =>
            StaffAddBottomSheet(
              name: staffName,
              phone: staffPhone,
              email: staffEmail,
              onSubmit: (name1, phone1, email1) {
                setState(() {
                  staffName = name1;
                  staffPhone = phone1;
                  staffEmail = email1;
                });
                /* context.read<CartCubit>().setBarcodeCustomerDetails(
              name: name1,
              phone: phone1,
              address: submittedAddress1,
            );*/
              },
            ),
      );
    }

    void RateUs() {
      double _userRating = 1.0;
      final TextEditingController _commentController = TextEditingController();
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) =>
            Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.myGradient,
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.kWhiteColor,
                      child: Image.asset(AppImages.AppIcon),
                    ),
                    const SizedBox(height: 10),
                    MyTextfield.textStyle_w800(
                        "Rating PixiDrugs", 25, Colors.black),
                    const SizedBox(height: 10),
                    MyTextfield.textStyle_w600(
                      "Tap a star to set your rating. Add more description here if you want.",
                      15,
                      AppColors.kBlackColor800,
                    ),
                    const SizedBox(height: 20),

                    // ⭐ Add your Rating widget here
                    RatingBar.builder(
                      initialRating: 1.0,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) =>
                          Icon(Icons.star, color:Color(0xFFF57F17)),
                      onRatingUpdate: (rating) {
                        _userRating = rating;
                      },
                    ),

                    const SizedBox(height: 15),
                    MyEdittextfield(
                      controller: _commentController,
                      hintText: 'Enter your comment'
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.kPrimary,
                      ),
                      onPressed: () {
                        final comment = _commentController.text;
                        print("rating: $_userRating, comment: $comment");

                        Navigator.of(context).pop();

                        if (_userRating < 3.0) {
                          // Handle low rating
                        } else {
                          _launchUrl();
                        }
                      },
                      child: Text(
                        'Submit',
                        style: MyTextfield.textStyle(
                            18, Colors.white, FontWeight.w800),
                      ),
                    )
                  ],
                ),
              ),
            ),
      );
    }
  }

  Future _launchUrl() async {
    final String url = "https://play.google.com/store/apps/details?id=com.pixiglam.pixidrugs";
    final Uri _url = Uri.parse(url);
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