import 'package:PixiDrugs/AWS/S3Service.dart';
import 'package:PixiDrugs/constant/all.dart';
import '../Dialog/AddPurchaseBottomSheet.dart';

class EditProfileScreen extends StatefulWidget {
  UserProfile? user;
  EditProfileScreen({required this.user});
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController storeNameController = TextEditingController();
  TextEditingController ownerNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController gstController = TextEditingController();
  TextEditingController regController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  bool image_changed = false;
  String _imageFile = '';
  String _UploadUrl = '';
  UserProfile? user;
  void _setSelectedImage(List<File> file) {
    setState(() {
      image_changed = true;
      _imageFile = file[0].path;
    });
  }

  @override
  void initState() {
    super.initState();
    user=widget.user;
    setState(() {
      _imageFile = user!.profilePicture;
      storeNameController.text = user!.name;
      ownerNameController.text = user!.ownerName;
      emailController.text = user!.email;
      phoneController.text = user!.phoneNumber;
      gstController.text = user!.gstin;
      regController.text = user!.license;
      addressController.text = user!.address;
      String imageUrl = user!.profilePicture;
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
      AppUtils.showSnackBar(context,"✅ Upload successful!");
      _saveProfileData(_UploadUrl);
    }
  }

  // Save profile data to SharedPreferences
  void _saveProfileData(String profile_url) async {
    String? userId = await SessionManager.getParentingId();
    context.read<ApiCubit>().updateUserData(
        user_id: userId!,
        name: storeNameController.text.isEmpty ? '' : storeNameController.text,
        ownerName: ownerNameController.text.isEmpty ? '' : ownerNameController.text,
        gander:'',
        dob: '',
        profile_picture: profile_url);
    context.read<ApiCubit>().stream.listen((state) {
      if (state is EditProfileLoaded) {
       AppUtils.showSnackBar(context,state.message);
        Navigator.pop(context);
      } else if (state is EditProfileError) {
       AppUtils.showSnackBar(context,'Failed: ${state.error}');
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
                              AddPurchaseBottomSheet(context, _setSelectedImage,
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
                MyTextfield.textStyle_w600('Name of the store', 18, Colors.black),
                SizedBox(height: 8),
                MyEdittextfield(
                    hintText: 'Enter ${AppString.storeName}', controller: storeNameController),
                SizedBox(height: screenHeight * 0.015),
                MyTextfield.textStyle_w600('Name of Owner/Proprietor', 18, Colors.black),
                SizedBox(height: 8),
                MyEdittextfield(
                    hintText: 'Enter ${AppString.ownerName}',
                    controller: ownerNameController),
                SizedBox(height: 8),
                MyTextfield.textStyle_w600('Address Of Store', 18, Colors.black),
                SizedBox(height: 8),
                MyEdittextfield(
                  controller: addressController,
                  hintText: 'Enter ${AppString.storeAddress}',
                  keyboardType: TextInputType.text,maxLines: 3 ,),
                SizedBox(height: 8),
                MyTextfield.textStyle_w600('Mobile no. of Owner', 18, Colors.black),
                SizedBox(height: 8),
                MyEdittextfield(
                  controller: phoneController,
                  hintText: AppString.enterNumber,
                  keyboardType: TextInputType.phone,readOnly: true,),
                SizedBox(height: 8),
                MyTextfield.textStyle_w600('Email Id. of Owner/Store', 18, Colors.black),
                SizedBox(height: 8),
                MyEdittextfield(
                    hintText: AppString.enterEmail,
                    controller: emailController,readOnly: true),
                SizedBox(height: 8),
                MyTextfield.textStyle_w600('GST NO. of Store', 18, Colors.black),
                SizedBox(height: 8),
                MyEdittextfield(
                    controller: gstController,
                    hintText: AppString.enterGst,
                    keyboardType: TextInputType.text),
                SizedBox(height: 8),
                MyTextfield.textStyle_w600('Licence No. of Store', 18, Colors.black),
                SizedBox(height: 8),
                MyEdittextfield(
                    controller: regController,
                    hintText: AppString.enterRegNo,
                    keyboardType: TextInputType.text),
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
