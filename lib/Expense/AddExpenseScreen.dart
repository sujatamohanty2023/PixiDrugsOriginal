import 'package:PixiDrugs/constant/all.dart';
import 'package:intl/intl.dart';

class Addexpensescreen extends StatefulWidget {
  const Addexpensescreen({Key? key}) : super(key: key);

  @override
  State<Addexpensescreen> createState() => _AddexpensescreenState();
}

class _AddexpensescreenState extends State<Addexpensescreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
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
        //_dateController.text = DateFormat('dd MMM, yyyy').format(selectedDate);
      });
    }
  }

  void _saveExpense() {
    String title = _titleController.text.trim();
    String amount = _amountController.text.trim();
    String note = _noteController.text.trim();

    if (title.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill Title and Amount")),
      );
      return;
    }
    // TODO: Call your API or Bloc function here
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
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
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back, color: Colors.white, size: 25),
                    ),
                    SizedBox(width: 10),
                    MyTextfield.textStyle_w600('Add Expense', screenWidth * 0.055, Colors.white),
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
                        ),
                        SizedBox(height: 14),

                        MyTextfield.textStyle_w400("Amount (₹)", AppUtils.size_16, Colors.black),
                        SizedBox(height: 6),
                        MyEdittextfield(
                          controller: _amountController,
                          hintText: "Enter amount",
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 14),

                        MyTextfield.textStyle_w400("Date", AppUtils.size_16, Colors.black),
                        SizedBox(height: 6),
                        GestureDetector(
                          onTap: _pickDate,
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
                                Text(DateFormat.yMMMd().format(selectedDate),
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
                        ),
                        SizedBox(height: 30),
                        MyElevatedButton(
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
    );
  }
}
