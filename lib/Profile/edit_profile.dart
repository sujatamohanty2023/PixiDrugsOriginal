import 'package:pixidrugs/AWS/S3Service.dart';
import 'package:pixidrugs/Dialog/show_image_picker.dart';
import 'package:pixidrugs/constant/all.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  bool image_changed = false;
  String _imageFile = '';
  String _UploadUrl = '';
  void _setSelectedImage(List<File> file) {
    setState(() {
      image_changed = true;
      _imageFile = file[0].path;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Load the saved profile data from SharedPreferences
  void _loadProfileData() async {
    String? userId = await SessionManager.getUserId();
    context.read<ApiCubit>().GetUserData(userId: userId!);
    context.read<ApiCubit>().stream.listen((state) {
      if (state is UserProfileLoaded) {
        nameController.text = state.userModel.name;
        emailController.text = state.userModel.email;
        phoneController.text = state.userModel.phoneNumber;
        String imageUrl = state.userModel.profilePicture;
        setState(() {
          _imageFile = imageUrl;
        });
      } else if (state is UserProfileError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${state.error}')),
        );
      }
    });
  }

  void _UpdateButtonClick() {
    if (image_changed) {
      _uploadFilestoS3();
    } else {
      _saveProfileData(_imageFile);
    }
  }

  // Upload files to S3
  Future<void> _uploadFilestoS3() async {
    List<String> list = [];
    list.add(_imageFile);
    S3UploadService s3Service = S3UploadService();
    List<String> _urlList = await s3Service.uploadImagesToS3(
      images: list,
      bucketUrl: "https://medirobo.s3.amazonaws.com",
      onProgress: (double totalProgress) {
        setState(() {});
      },
    );
    setState(() {
      _UploadUrl = _urlList[0];
    });
    if (_urlList.isNotEmpty) {
      print(_UploadUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Upload successful!")),
      );
      _saveProfileData(_UploadUrl);
    }
  }

  // Save profile data to SharedPreferences
  void _saveProfileData(String profile_url) async {
    String? userId = await SessionManager.getUserId();
    context.read<ApiCubit>().updateUserData(
        user_id: userId!,
        name: nameController.text.isEmpty ? '' : nameController.text,
        email: emailController.text.isEmpty ? '' : emailController.text,
        phone_number: phoneController.text.isEmpty ? '' : phoneController.text,
        gander:'',
        dob: '',
        profile_picture: profile_url);
    context.read<ApiCubit>().stream.listen((state) {
      if (state is EditProfileLoaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message)),
        );
        Navigator.pop(context);
      } else if (state is EditProfileError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${state.error}')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppUtils.BaseAppBar(context: context, title: 'Edit Profile'),
      body: Container(
        height: screenHeight,
        decoration: BoxDecoration(
          gradient: AppColors.myGradient,
        ),
        padding: const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 60),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.015),
                Center(
                  child: Stack(
                    children: [
                      SizedBox(height: screenHeight * 0.04),
                      CircleAvatar(
                        backgroundColor: AppColors.kPrimary.withOpacity(0.3),
                        radius: 60,
                        backgroundImage: _imageFile.isNotEmpty
                            ? _imageFile.contains('https://')
                                ? NetworkImage(_imageFile)
                                : image_changed
                                    ? FileImage(File(_imageFile))
                                    : NetworkImage(
                                        '${AppString.baseUrl}$_imageFile')
                            : AssetImage(AppImages.AppIcon) as ImageProvider,
                        child: _imageFile.isEmpty
                            ? Icon(Icons.person,
                                size: 60, color: AppColors.kPrimary)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.kWhiteColor,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(Icons.edit, color: AppColors.kPrimary),
                            onPressed: () {
                              showImageBottomSheet(context, _setSelectedImage,
                                  pick_Size: 1);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                // Name input field
                MyTextfield.textStyle_w600(AppString.name, 18, Colors.black),
                SizedBox(height: 8),
                MyEdittextfield(
                    hintText: AppString.enterName, controller: nameController),
                SizedBox(height: screenHeight * 0.015),
                // Email input field
                MyTextfield.textStyle_w600(AppString.email, 18, Colors.black),
                SizedBox(height: 8),
                MyEdittextfield(
                    hintText: AppString.enterEmail,
                    controller: emailController),
                SizedBox(height: 8),
                // Phone number input field
                MyTextfield.textStyle_w600(AppString.phone, 18, Colors.black),
                SizedBox(height: 8),
                MyEdittextfield(
                    controller: phoneController,
                    hintText: AppString.enterNumber,
                    keyboardType: TextInputType.phone),
                SizedBox(height: screenHeight * 0.015),
                // Update button
                /// **Bottom-Aligned Update Button**
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: double.infinity,
        padding: EdgeInsets.only(left: 8, right: 8),
        color: Colors.white, // To make it look separate from the form
        child: MyElevatedButton(
          buttonText: AppString.upDate,
          onPressed: _UpdateButtonClick,
        ),
      ),
    );
  }
}
