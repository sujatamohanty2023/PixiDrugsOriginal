import '../../constant/all.dart';
import 'package:intl/intl.dart';

import 'ExpenseResponse.dart';

class Addexpensescreen extends StatefulWidget {
  ExpenseResponse? expenseResponse;
   Addexpensescreen({Key? key,this.expenseResponse}) : super(key: key);

  @override
  State<Addexpensescreen> createState() => _AddexpensescreenState();
}

class _AddexpensescreenState extends State<Addexpensescreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _referralNameController = TextEditingController();
  final TextEditingController _referralMobileController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool edit=false;
  List<String> category = [
    'Select Expense Category',
    'Staff Salaries',
    'Shop Rent',
    'Electric Bill',
    'Fuel',
    'Food',
    'GST Charges',
    'Referrals/Commissions',
    'Office Expenses',
    'Others'
  ];
  String? selectedCategory='Select Expense Category';
  @override
  void initState() {
    super.initState();
    if(widget.expenseResponse !=null) {
      selectedDate = DateTime.parse(widget.expenseResponse!.expanseDate);
      _amountController.text = widget.expenseResponse!.amount;
      _noteController.text = widget.expenseResponse!.note;
      selectedCategory=widget.expenseResponse?.title??'Select Expense Category';

      if (widget.expenseResponse!.title.toLowerCase().contains('referral')) {
        selectedCategory = 'Referrals/Commissions';
        final extractedData = extractReferralData(widget.expenseResponse!.note);
        _referralNameController.text = extractedData['referralName'] ?? '';
        _referralMobileController.text = extractedData['referralPhone'] ?? '';
        final cleanedNoteLines = widget.expenseResponse!.note
            .split('\n')
            .where((line) =>
        !line.startsWith('Referral Person:') &&
            !line.startsWith('Referral Contact No.:') )
            .toList();

        _noteController.text = cleanedNoteLines.join('\n').trim();
      }
    }
  }

  Map<String, String> extractReferralData(String note) {
    final Map<String, String> data = {};

    final lines = note.split('\n');
    for (final line in lines) {
      if (line.startsWith('Customer Name:')) {
        data['customerName'] = line.replaceFirst('Customer Name:', '').trim();
      } else if (line.startsWith('Customer Contact No.:')) {
        data['customerPhone'] = line.replaceFirst('Customer Contact No.:', '').trim();
      } else if (line.startsWith('Referral Person:')) {
        data['referralName'] = line.replaceFirst('Referral Person:', '').trim();
      } else if (line.startsWith('Referral Contact No.:')) {
        data['referralPhone'] = line.replaceFirst('Referral Contact No.:', '').trim();
      } else if (line.startsWith('Referral Amount:')) {
        final amountInfo = line.replaceFirst('Referral Amount:', '').trim();
        if (amountInfo.toLowerCase().contains('given')) {
          data['referralAmount'] = amountInfo.replaceAll('Given', '').trim();
          data['amountGiven'] = 'true';
        } else {
          data['referralAmount'] = '';
          data['amountGiven'] = 'false';
        }
      }
    }

    return data;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _referralNameController.dispose();
    _referralMobileController.dispose();
    super.dispose();
  }
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return AppUtils.CalenderTheme(child: child);
      },
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }
  Future<void> _saveExpense() async {
    String amount = _amountController.text.trim();
    String note = _noteController.text.trim();
    String referralName = _referralNameController.text.trim();
    String referralMobile = _referralMobileController.text.trim();
    if (selectedCategory == null || selectedCategory == 'Select Expense Category') {
      AppUtils.showSnackBar(context, 'Please Select Expense Category');
      return;
    }
    // Mandatory name/mobile for 'Referrals/Commissions' or 'Others'
    if (selectedCategory == 'Referrals/Commissions' || selectedCategory == 'Others') {
      if (referralName.isEmpty || referralMobile.isEmpty) {
        AppUtils.showSnackBar(context, 'Please enter referral person name and mobile number');
        return;
      }
    }

    final userId = await SessionManager.getParentingId() ?? '';
    final formattedNote = (selectedCategory == 'Referrals/Commissions' || selectedCategory == 'Others')
        ? 'Name: $referralName, Mobile: $referralMobile\n$note'
        : note;
    if(edit && widget.expenseResponse !=null){
      context.read<ApiCubit>().ExpenseEdit(id:widget.expenseResponse!.id.toString(),
          store_id:userId,
          title:selectedCategory!,
          amount:amount,
          expanse_date:DateFormat('yyyy-MM-dd').format(selectedDate),
          note:formattedNote
      );
    }else {
      context.read<ApiCubit>().ExpenseAdd(store_id:userId,
          title:selectedCategory!,
          amount:amount,
          expanse_date:DateFormat('yyyy-MM-dd').format(selectedDate),
          note:formattedNote
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: BlocListener<ApiCubit, ApiState>(
        listener: (context, state) {
          if (state is ExpenseAddLoaded) {
            setState(() {
              if(state.success) {
                Navigator.pop(context,true); // Use caution here
                AppUtils.showSnackBar(context,'Successfully Add Expense');
              }else{
              AppUtils.showSnackBar(context,'Failed to add Expense');
              }
            });
          } else if (state is ExpenseAddError) {
            Navigator.pop(context); // Use caution here
            AppUtils.showSnackBar(context,'Failed to add: ${state.error}');
          }else if (state is ExpenseEditLoaded) {
            setState(() {
              if(state.success) {
                Navigator.pop(context,true); // Use caution here
                AppUtils.showSnackBar(context,'Successfully Updated');
              }else{
          AppUtils.showSnackBar(context,'Failed to Update');
              }
            });
          } else if (state is ExpenseEditError) {
            Navigator.pop(context); // Use caution here
            AppUtils.showSnackBar(context,'Failed to update api : ${state.error}');
          }
        },
        child: Container(
          color: AppColors.kPrimary,
          width: double.infinity,
          padding: EdgeInsets.only(top: screenWidth * 0.01),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context); // Explicitly pass `true` when back is clicked
                            },
                            child: Icon(Icons.arrow_back, color: Colors.white, size: 25),
                          ),
                          SizedBox(width: 10),
                          MyTextfield.textStyle_w600('${edit && widget.expenseResponse !=null?'Edit':'Add'} Expense', screenWidth * 0.055, Colors.white),
                        ],
                      ),
                      widget.expenseResponse!=null?Padding(
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

                // Form
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      gradient: AppColors.myGradient,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(screenWidth * 0.07),
                        topLeft: Radius.circular(screenWidth * 0.07),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 6),
                          MyTextfield.textStyle_w400("Title", AppUtils.size_16, Colors.black),
                          SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white, // Background color
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                              border: Border.all(
                                color: AppColors.kPrimaryDark, // Border color
                                width: 1, // Border width
                              ),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            child: PopupMenuButton<String>(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              color: AppColors.kWhiteColor,
                              elevation: 8,
                              onSelected: (value) {
                                setState(() {
                                  selectedCategory = value;
                                });
                              },
                              itemBuilder: (_) => category
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final index = entry.key;
                                final item = entry.value;

                                return PopupMenuItem<String>(
                                  value: item,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      MyTextfield.textStyle_w400(item.toUpperCase(), 15, AppColors.kPrimary),
                                      if (index < category.length - 1)
                                        Divider(
                                          color: AppColors.kPrimaryLight,
                                          height: 4,
                                          thickness: 1,
                                        ),
                                    ],
                                  ),
                                );
                              })
                                  .toList(),
                              enabled: (edit || widget.expenseResponse == null),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: MyTextfield.textStyle_w400( selectedCategory ?? 'Select Expense Category',15, Colors.black)
                                  ),
                                  Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 14),

                          MyTextfield.textStyle_w400("Amount (₹)", AppUtils.size_16, Colors.black),
                          SizedBox(height: 6),
                          MyEdittextfield(
                            controller: _amountController,
                            hintText: "Enter amount",
                            keyboardType: TextInputType.number,
                            readOnly: !edit && widget.expenseResponse!=null,
                          ),
                          SizedBox(height: 14),

                          MyTextfield.textStyle_w400("Date", AppUtils.size_16, Colors.black),
                          SizedBox(height: 6),
                          GestureDetector(
                            onTap:!edit && widget.expenseResponse !=null?null:_pickDate,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.kPrimaryDark, // Border color
                                  width: 1, // Border width
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(AppUtils().formatDate(selectedDate.toString()),
                                      style: MyTextfield.textStyle(14,Colors.black,FontWeight.w600)),
                                  Icon(Icons.calendar_today_outlined, size: 18),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 14),

                          MyTextfield.textStyle_w400("Description", AppUtils.size_16, Colors.black),
                          SizedBox(height: 6),
                          MyEdittextfield(
                            controller: _noteController,
                            hintText: "Write a description",
                            maxLines: 3,
                            readOnly: !edit && widget.expenseResponse!=null,
                          ),
                          if ((selectedCategory == 'Referrals/Commissions' || selectedCategory == 'Others')) ...[
                            SizedBox(height: 14),
                            MyTextfield.textStyle_w400("Referral Person Name", AppUtils.size_16, Colors.black),
                            SizedBox(height: 6),
                            MyEdittextfield(
                              controller: _referralNameController,
                              hintText: "Enter referral name",
                              readOnly: !edit && widget.expenseResponse != null,
                            ),
                            SizedBox(height: 14),
                            MyTextfield.textStyle_w400("Referral Mobile Number", AppUtils.size_16, Colors.black),
                            SizedBox(height: 6),
                            MyEdittextfield(
                              controller: _referralMobileController,
                              hintText: "Enter mobile number",
                              keyboardType: TextInputType.phone,
                              readOnly: !edit && widget.expenseResponse != null,
                            ),
                          ],
                          SizedBox(height: 30),
                          !edit && widget.expenseResponse !=null?SizedBox():MyElevatedButton(
                            onPressed: _saveExpense,
                            buttonText: "Save Expense",
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
