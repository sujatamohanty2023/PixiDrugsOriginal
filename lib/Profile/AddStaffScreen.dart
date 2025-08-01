

import 'package:intl/intl.dart';

import '../constant/all.dart';

class AddStaffScreen extends StatefulWidget {
  Staff? staff;
  AddStaffScreen({Key? key,this.staff }) : super(key: key);

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

  String? selectedGender;
  bool isAddingStaff = false;
  bool edit = false;

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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // TODO: Add API or database call here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Staff Added Successfully!")),
      );
    }
  }
  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    dobController.dispose();
    addressController.dispose();
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
      addressController.text='';
      selectedGender=widget.staff?.gander??'';
      isAddingStaff = true;
    }else{
      isAddingStaff = false;
    }
  }
  void _AddStaff() {
    setState(() {
      isAddingStaff = true;
      edit=true;// Switch to show form for manual adding
    });
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
      return Scaffold(
        body: Container(
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
                        icon: const Icon(Icons.edit, color: AppColors.kWhiteColor, size: 30),
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
                    child: isAddingStaff?SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                              nameController, 'Staff Name', TextInputType.name),
                          const SizedBox(height: 15),
                          _buildTextField(
                              mobileController, 'Phone Number', TextInputType
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
                            emailController, 'Email', TextInputType
                              .emailAddress,),
                          const SizedBox(height: 15),
                          MyTextfield.textStyle_w400("Gender", 14, Colors
                              .black),
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
                                onTap: () =>
                                    setState(() => selectedGender = "Female"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          MyTextfield.textStyle_w400("DOB", 14, Colors.black),
                          SizedBox(height: 8),
                          MyEdittextfield(
                            controller: dobController,
                            hintText: "Date of Birth",
                            validator: (value) =>
                            value!.isEmpty
                                ? "Select DOB"
                                : null,
                            readOnly: true,
                            onTap: () => edit?_selectDate(context):null,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                              addressController, 'Address', TextInputType.text,
                              maxLines: 3),
                          const SizedBox(height: 30),
                          isAddingStaff && edit? MyElevatedButton(
                            buttonText: 'Submit',
                            onPressed: () {},
                          ):SizedBox(),
                        ],
                      ),
                    ): NoItemPage(
                      onTap: _AddStaff,
                      image: AppImages.empty_cart,
                      tittle: "No Staff Members",
                      description: "Add staff to manage inventory, sales,\nand keep your business running smoothly.",
                      button_tittle: "Add Staff",
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
  Widget ChooseGender({required String label, required IconData icon, required bool selected, required Function() onTap,})
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
            Icon(icon, color: selected ? Colors.white : AppColors.kPrimary),
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
      {int maxLines = 1, String? Function(String?)? validator}) {
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
        ),
      ],
    );
  }
}