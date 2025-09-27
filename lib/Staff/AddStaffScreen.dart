
import 'package:intl/intl.dart';

import '../../constant/all.dart';
import '../widgets/app_loader.dart';
import 'StaffModel.dart';

class AddStaffScreen extends StatefulWidget {
  StaffModel? staff;
  bool add= false;
  AddStaffScreen({Key? key,this.staff,this.add = false }) : super(key: key);

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String? selectedGender;
  String? status;
  bool edit = false;
  List<String> postofStaff = [
    'Select Post',
    'Manager',
    'Pharmacist',
    'Sales person',
  ];
  String? selectedPost='Select Post';
  String? _selectedPermission;

  final List<String> permissions = [
    'Stock uploading',
    'Sell medicines',
    'Manage and edit expenses',
  ];

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (passwordController.text != confirmPasswordController.text) {
        AppUtils.showSnackBar(context,"Passwords do not match!");
        return;
      }
      String name = nameController.text.trim();
      String email = emailController.text.trim();
      String mobile = mobileController.text.trim();
      String dob1 = dobController.text.trim();
      String address = addressController.text.trim();
      String password = passwordController.text.trim();
      String password_confirm = confirmPasswordController.text.trim();

      if (name.isEmpty || email.isEmpty || mobile.isEmpty || dob1.isEmpty ||
          address.isEmpty||password.isEmpty||password_confirm.isEmpty || selectedGender==null ||status==null) {
        AppUtils.showSnackBar(context,"Please fill required field");
        return;
      }
      print('API $name,\n$email,\n$mobile,\n$dob1,\n$address,\n$password,\n$password_confirm,\n$selectedGender,\n$status');
      
      final userId = await SessionManager.getParentingId() ?? '';
      
      // Show loader
      AppLoader.show(context, message: edit ? "Updating staff member..." : "Adding staff member...");
      
      try {
        if (edit && widget.staff != null) {
          await context.read<ApiCubit>().StaffEdit(id: widget.staff!.id.toString(),
            store_id: userId,
            name: name,
            email: email,
            phone_number: mobile,
            gender: selectedGender!,
            dob: dob1,
            address: address,
            password:password,
            password_confirmation:password_confirm,
            status:status!,
          );
        } else {
          await context.read<ApiCubit>().StaffAdd(store_id: userId,
            name: name,
            email: email,
            phone_number: mobile,
            gender: selectedGender!,
            dob: dob1,
            address: address,
            password:password,
            password_confirmation:password_confirm,
          );
        }
      } finally {
        // Hide loader
        AppLoader.hide();
      }
    }
  }
    @override
    void dispose() {
      nameController.dispose();
      mobileController.dispose();
      emailController.dispose();
      dobController.dispose();
      addressController.dispose();
      passwordController.dispose();
      confirmPasswordController.dispose();
      super.dispose();
    }
    @override
    void initState() {
      super.initState();
        if(widget.staff!=null){
          nameController.text=widget.staff?.name??'';
          mobileController.text=widget.staff?.phoneNumber??'';
          emailController.text=widget.staff?.email??'';
          dobController.text=widget.staff?.dob??'';
          addressController.text=widget.staff?.address??'';
          selectedGender=widget.staff?.gander?.toLowerCase()=='male'?selectedGender='Male':'Female';
          status = widget.staff?.status.toLowerCase()=='active'?status='Active':'Inactive';
        }
      if(widget.add){
        edit=true;
      }
    }
    @override
    Widget build(BuildContext context) {
      double screenWidth = MediaQuery.of(context).size.width;
      return Scaffold(
        body: BlocListener<ApiCubit, ApiState>(
          listener: (context, state) {
            if (state is StaffAddLoaded) {
              AppUtils.showSnackBar(context,state.message);
              if(state.status=='success') {
                Navigator.pop(context,true);
              }
            } else if (state is StaffAddError) {
              Navigator.pop(context); // Use caution here
              AppUtils.showSnackBar(context,'Error:${state.error}');
            }else if (state is StaffEditLoaded) {
              AppUtils.showSnackBar(context,state.message);
              if(state.status=='success') {
                Navigator.pop(context,true);
              }
            } else if (state is StaffEditError) {
              Navigator.pop(context); // Use caution here
              AppUtils.showSnackBar(context,'Error:${state.error}');
            }
          },
          child: Container(
            color: AppColors.kPrimary,
            width: double.infinity,
            padding: EdgeInsets.only(top: screenWidth * 0.12),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                          SizedBox(width: 10),
                          MyTextfield.textStyle_w600(
                            'Staff Details',
                            screenWidth * 0.055,
                            Colors.white,
                          ),
                        ],
                      ),
                      widget.staff!=null?Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: IconButton(
                          icon: SvgPicture.asset(AppImages.edit, height: 18, color: Colors.white),
                          onPressed: ()=>setState(() {
                            edit = true;
                          }),
                          tooltip: 'Edit',
                        ),
                      ):SizedBox()
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04,
                        vertical: screenWidth * 0.02),
                    decoration: BoxDecoration(
                      gradient: AppColors.myGradient,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(screenWidth * 0.07),
                        topLeft: Radius.circular(screenWidth * 0.07),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                                nameController, 'Name of Staff', TextInputType.name),
                            const SizedBox(height: 15),
                            _buildTextField(
                                mobileController, 'Mobile No. of Staff', TextInputType
                                .phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Enter phone number';
                                  if (!RegExp(r'^\d{10,}$').hasMatch(value))
                                    return 'Enter valid phone number';
                                  return null;
                                }),
                            const SizedBox(height: 15),
                            _buildTextField(
                              emailController, 'Email Id. of Staff', TextInputType
                                .emailAddress,),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                MyTextfield.textStyle_w600(
                                    'Gender', AppUtils.size_16, Colors.black),
                                MyTextfield.textStyle_w600(" *", AppUtils.size_16, Colors.red),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                ChooseGender(
                                  label: "Male",
                                  icon: Icons.male_outlined,
                                  selected: selectedGender == "Male",
                                  onTap: () =>
                                      setState(() => selectedGender = "Male"),
                                ),
                                SizedBox(width: 10),
                                ChooseGender(
                                  label: "Female",
                                  icon: Icons.female_outlined,
                                  selected: selectedGender == "Female",
                                  onTap: () =>edit || widget.add?
                                  setState(() => selectedGender = "Female"):null,
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                MyTextfield.textStyle_w600(
                                    'DOB', AppUtils.size_16, Colors.black),
                                MyTextfield.textStyle_w600(" *", AppUtils.size_16, Colors.red),
                              ],
                            ),
                            SizedBox(height: 8),
                            MyEdittextfield(
                              controller: dobController,
                              hintText: "Date of Birth",
                              validator: (value) =>
                              value!.isEmpty
                                  ? "Select DOB"
                                  : null,
                              readOnly: true,
                              onTap: () => edit || widget.add?_selectDate(context):null,
                            ),
                            const SizedBox(height: 15),
                            _buildTextField(
                                addressController, 'Address of Staff', TextInputType.text,
                                maxLines: 3),
                           /* const SizedBox(height: 15),
                            MyTextfield.textStyle_w600("Post of Staff", AppUtils.size_16, Colors.black),
                            SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: selectedPost,
                              items: postofStaff.map((reason) {
                                return DropdownMenuItem<String>(
                                  value: reason,
                                  child: MyTextfield.textStyle_w300(reason,16,Colors.grey),
                                );
                              }).toList(),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(color: AppColors.kPrimaryDark, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(color: AppColors.kPrimary, width: 1.5),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
                                ),
                              ),
                              onChanged: (  edit || widget.staff==null)
                                  ? (value) {
                                setState(() {
                                  selectedPost = value;
                                });
                              }: null,
                              hint: const Text("Select Post"),
                            ),
                            const SizedBox(height: 15),
                            MyTextfield.textStyle_w600("Do you want to allow this staff for", AppUtils.size_16, Colors.black),
                            SizedBox(height: 6),
                            ...permissions.map((permission) {
                              return RadioListTile<String>(
                                title: MyTextfield.textStyle_w300(permission,AppUtils.size_16, Colors.black),
                                value: permission,
                                groupValue: _selectedPermission,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPermission = value;
                                  });
                                },
                              );
                            }).toList(),*/
                            const SizedBox(height: 15),
                            MyTextfield.textStyle_w600("Status", 14, Colors
                                .black),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                ChooseGender(
                                  label: "Active",
                                  selected: status == "Active",
                                  onTap: () =>
                                      setState(() => status = "Active"),
                                ),
                                SizedBox(width: 10),
                                ChooseGender(
                                  label: "Inactive",
                                  selected: status == "Inactive",
                                  onTap: () =>edit ||widget.add?
                                  setState(() => status = "Inactive"):null,
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            if(edit || widget.add)
                              _buildTextField(
                                  passwordController, 'Password', TextInputType
                                  .emailAddress, obscureText: true),
                            const SizedBox(height: 15),
                            if(edit || widget.add)
                              _buildTextField(
                                  confirmPasswordController, 'Confirm Password', TextInputType
                                  .emailAddress, obscureText: true),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: widget.add || edit? Padding(
          padding: const EdgeInsets.all(8.0),
          child: MyElevatedButton(
            buttonText: edit?'Update':'Add Staff',
            onPressed:_submitForm,
          ),
        ):SizedBox(),
      );
    }
    Widget ChooseGender({required String label, IconData? icon, required bool selected, required Function() onTap,})
    {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          // margin: EdgeInsets.symmetric(horizontal: 8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? AppColors.kPrimary : Colors.white, // Pink when selected
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.kPrimaryDark),
          ),
          child: Row(
            children: [
              icon==null?SizedBox():Icon(icon, color: selected ? Colors.white : AppColors.kPrimary),
              SizedBox(width: 10),
              Text(
                  label,
                  style: MyTextfield.textStyle(14,selected ? Colors.white : AppColors.kPrimary,FontWeight.bold)
              ),
            ],
          ),
        ),
      );
    }
    Widget _buildTextField(TextEditingController controller, String hint, TextInputType type,
        {int maxLines = 1, String? Function(String?)? validator,bool obscureText=false}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MyTextfield.textStyle_w600(
                  hint.replaceAll('Enter', ''), AppUtils.size_16, Colors.black),
              MyTextfield.textStyle_w600(" *", AppUtils.size_16, Colors.red),
            ],
          ),
          const SizedBox(height: 8),
          MyEdittextfield(
            controller: controller,
            hintText: hint,
            validator: validator,
            maxLines: maxLines,
            readOnly: !edit,
           obscureText:obscureText
          ),
        ],
      );
    }
  }