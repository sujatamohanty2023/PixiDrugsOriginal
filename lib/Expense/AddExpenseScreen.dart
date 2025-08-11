import 'package:PixiDrugs/constant/all.dart';
import 'package:intl/intl.dart';

import 'ExpenseResponse.dart';

class Addexpensescreen extends StatefulWidget {
  ExpenseResponse? expenseResponse;
   Addexpensescreen({Key? key,this.expenseResponse}) : super(key: key);

  @override
  State<Addexpensescreen> createState() => _AddexpensescreenState();
}

class _AddexpensescreenState extends State<Addexpensescreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool edit=false;

  @override
  void initState() {
    super.initState();
    if(widget.expenseResponse !=null) {
      selectedDate = DateTime.parse(widget.expenseResponse!.expanseDate);
      _titleController.text = widget.expenseResponse!.title;
      _amountController.text = widget.expenseResponse!.amount;
      _noteController.text = widget.expenseResponse!.note;
    }
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
    String title = _titleController.text.trim();
    String amount = _amountController.text.trim();
    String note = _noteController.text.trim();

    if (title.isEmpty || amount.isEmpty) {
      AppUtils.showSnackBar(context,"Please fill Title and Amount");
      return;
    }
    final userId = await SessionManager.getParentingId() ?? '';
    if(edit && widget.expenseResponse !=null){
      context.read<ApiCubit>().ExpenseEdit(id:widget.expenseResponse!.id.toString(),
          store_id:userId,
          title:title,
          amount:amount,
          expanse_date:DateFormat('yyyy-MM-dd').format(selectedDate),
          note:note
      );
    }else {
      context.read<ApiCubit>().ExpenseAdd(store_id:userId,
          title:title,
          amount:amount,
          expanse_date:DateFormat('yyyy-MM-dd').format(selectedDate),
          note:note
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
                Navigator.pop(context); // Use caution here
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
                Navigator.pop(context); // Use caution here
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
                            onTap: () => Navigator.pop(context),
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
                          MyTextfield.textStyle_w400("Title", AppUtils.size_16, Colors.black),
                          SizedBox(height: 6),
                          MyEdittextfield(
                            controller: _titleController,
                            hintText: "Enter title",
                            readOnly: !edit && widget.expenseResponse!=null,
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

                          MyTextfield.textStyle_w400("Note", AppUtils.size_16, Colors.black),
                          SizedBox(height: 6),
                          MyEdittextfield(
                            controller: _noteController,
                            hintText: "Write a note",
                            maxLines: 3,
                            readOnly: !edit && widget.expenseResponse!=null,
                          ),
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
