import 'package:PixiDrugs/Expense/AddExpenseScreen.dart';
import 'package:PixiDrugs/ListPageScreen/ListScreen.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:PixiDrugs/Staff/AddStaffScreen.dart';
import 'package:PixiDrugs/Profile/WebviewScreen.dart';
import 'package:PixiDrugs/Profile/edit_profile.dart';
import 'package:PixiDrugs/constant/all.dart';
import 'package:PixiDrugs/login/mobileLoginScreen.dart';

import 'contact_us.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
  }

  class _ProfileScreenState extends State<ProfileScreen> {
    String? name = 'Guest';
    String? email = '';
    String? image = '';
    String? role = '';
    UserProfile? user;

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
      String? userId = await SessionManager.getParentingId();
      role=await SessionManager.getRole();
      if (userId != null) {
        context.read<ApiCubit>().GetUserData(userId: userId,useCache: false);
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
            user=state.userModel.user;
            name = state.userModel.user.name;
            email = state.userModel.user.email;
            image = state.userModel.user.profilePicture;
          });
        } else if (state is UserProfileError) {
          AppUtils.showSnackBar(context,'Failed: ${state.error}');
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
                            name!, SizeConfig.screenWidth! * 0.055, Colors.white,
                            maxLines: 1),
                        MyTextfield.textStyle_w600(
                            email!, SizeConfig.screenWidth! * 0.045, Colors.white70),
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
                      if(role=='owner')
                        GestureDetector(
                        onTap: () {
                          AppRoutes.navigateTo(context, EditProfileScreen(user:user));
                        },
                        child: _buildMenuItem(
                            Icons.edit, "Edit Profile", Colors.blue),
                      ),
                      if(role=='owner')
                      GestureDetector(
                        onTap: () {
                          AppRoutes.navigateTo(context, ListScreen(type:ListType.staff));
                        },
                        child: _buildMenuItem(Icons.person, "Staff Management",
                            Colors.purpleAccent),
                      ),
                      if(role=='owner')
                      GestureDetector(
                        onTap: () {
                          AppRoutes.navigateTo(context, ListScreen(type:ListType.expense));
                        },
                        child: _buildMenuItem(Icons.add_chart, "Store Expenses",
                            Colors.cyan),
                      ),
                      if(role=='owner')
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
                              context, ContactUsPage()/*Webviewscreen(tittle: 'Contact Us')*/);
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
    final String url = "https://play.google.com/store/apps/details?id=com.medico.pixidrugs";
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
              child: MyTextfield.textStyle_w600(title, SizeConfig.screenWidth! * 0.045, Colors.black87),
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