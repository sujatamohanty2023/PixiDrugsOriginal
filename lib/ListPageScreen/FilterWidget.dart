import 'package:PixiDrugs/ListPageScreen/ListScreen.dart';
import 'package:intl/intl.dart';
import 'package:PixiDrugs/constant/all.dart';

import '../customWidget/PaymentTypeWidget.dart';

class FilterWidget extends StatefulWidget {
  final void Function(
      DateTime? from,
      DateTime? to,
      String range,
      String? paymentType,
      String? paymentReason,
      ) onApply;
  final void Function() onReset;
  final DateTime? initialFrom;
  final DateTime? initialTo;
  final String? initialRange;
  final String? initialPaymentType;
  final String? initialPaymentReason;
  final ListType? type;

  const FilterWidget({Key? key, required this.onApply, this.initialFrom, this.initialTo,
    this.initialRange,this.initialPaymentType,this.initialPaymentReason, required this.onReset, required this.type}) : super(key: key);

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  DateTime? fromDate;
  DateTime? toDate;
  String selectedRange = 'Today';
  String selectedPaymentType = "Cash";
  String selectedPaymentReason='All';

  final List<String> quickRanges = [
    'Today',
    'Yesterday',
    'Past 7 Days',
    'Last 30 Days',
    'Last 1 Year',
    'Custom',
  ];


  final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    if (widget.initialRange != null &&
        widget.initialRange == 'Custom' &&
        widget.initialFrom != null &&
        widget.initialTo != null) {
      selectedRange = 'Custom';
      fromDate = widget.initialFrom;
      toDate = widget.initialTo;
    } else if (widget.initialRange != null && widget.initialRange != 'Custom') {
      selectedRange = widget.initialRange!;
      _setDatesForRange(selectedRange);
    } else {
      selectedRange = 'Today';
      _setDatesForRange(selectedRange);
    }
    if (widget.initialPaymentType != null){
      selectedPaymentType=widget.initialPaymentType??'Cash';
    }
    if (widget.initialPaymentReason != null){
      selectedPaymentReason=widget.initialPaymentReason??'All';
    }
  }

  void _setDatesForRange(String range) {
    final now = DateTime.now();

    switch (range) {
      case 'Today':
        fromDate = DateTime(now.year, now.month, now.day);
        toDate = DateTime(now.year, now.month, now.day);
        break;

      case 'Yesterday':
        final yesterday = now.subtract(Duration(days: 1));
        fromDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
        toDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
        break;

      case 'Past 7 Days':
        toDate = DateTime(now.year, now.month, now.day);
        fromDate = toDate!.subtract(Duration(days: 6)); // 7 days including today
        break;

      case 'Last 30 Days':
        toDate = DateTime(now.year, now.month, now.day);
        fromDate = toDate!.subtract(Duration(days: 29)); // 30 days including today
        break;

      case 'Last 1 Year':
        toDate = DateTime(now.year, now.month, now.day);
        fromDate = toDate!.subtract(Duration(days: 365));
        break;

      case 'Custom':
        fromDate = null;
        toDate = null;
        break;
    }
  }

  Future<void> _pickDate(BuildContext context, bool isFrom) async {
    final initialDate =
        isFrom ? (fromDate ?? DateTime.now()) : (toDate ?? DateTime.now());
    final firstDate = DateTime(2000);
    final lastDate = DateTime(2100);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
          if (toDate != null && toDate!.isBefore(picked)) {
            toDate = null; // Reset toDate if it's before fromDate
          }
        } else {
          toDate = picked;
          if (fromDate != null && fromDate!.isAfter(picked)) {
            fromDate = null; // Reset fromDate if after toDate
          }
        }
        if (selectedRange != 'Custom') selectedRange = 'Custom';
      });
    }
  }

  void _resetFilters() {
    setState(() {
      selectedRange = 'Today';
      selectedPaymentType = "Cash";
      selectedPaymentReason='All';
      _setDatesForRange(selectedRange);
    });
    widget.onReset();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.myGradient
      ),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 10,
          right: 10,
          top: 30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: MyTextfield.textStyle_w800(
                    "Filter",
                    AppUtils.size_18,
                    Colors.black,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.clear, color: AppColors.kPrimary),
                  onPressed: () => Navigator.pop(context),  // closes the sheet
                ),
              ],
            ),
            Divider(color: AppColors.kPrimaryLight,),
            SizedBox(height: 10,),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyTextfield.textStyle_w400(
                        "From Date",
                        AppUtils.size_16,
                        Colors.black54,
                      ),
                      SizedBox(height: 6),
                      GestureDetector(
                        onTap: selectedRange == 'Custom' ? () => _pickDate(context, true) : null,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.kPrimaryDark, width: 1),
                          ),
                          child: MyTextfield.textStyle_w400(
                              fromDate != null ? _dateFormat.format(fromDate!) : "mm/dd/yyyy",
                              AppUtils.size_16,
                              fromDate != null ? Colors.black : Colors.grey
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyTextfield.textStyle_w400(
                        "To Date",
                        AppUtils.size_16,
                        Colors.black54,
                      ),
                      SizedBox(height: 6),
                      GestureDetector(
                        onTap: selectedRange == 'Custom' ? () => _pickDate(context, false) : null,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.kPrimaryDark, width: 1),
                          ),
                          child: MyTextfield.textStyle_w400(
                              toDate != null ? _dateFormat.format(toDate!) : "mm/dd/yyyy",
                              AppUtils.size_16,
                              toDate != null ? Colors.black : Colors.grey
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyTextfield.textStyle_w400(
                        "Quick Range",
                        AppUtils.size_16,
                        Colors.black54,
                      ),
                      SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.kPrimaryDark, width: 1),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: PopupMenuButton<String>(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: AppColors.kWhiteColor,
                          elevation: 8,
                          onSelected: (value) {
                            setState(() {
                              selectedRange = value;
                              if (selectedRange != 'Custom') {
                                _setDatesForRange(selectedRange);
                              } else {
                                fromDate = null;
                                toDate = null;
                              }
                            });
                          },
                          itemBuilder: (_) => quickRanges
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
                                  MyTextfield.textStyle_w400(
                                    item.toUpperCase(),
                                    15,
                                    AppColors.kPrimary,
                                  ),
                                  if (index < quickRanges.length - 1)
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: MyTextfield.textStyle_w400(
                                  selectedRange,
                                  15,
                                  Colors.black,
                                ),
                              ),
                              Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: PaymentPopupMenu(
                    label: "Payment Method",
                    selectedValue: selectedPaymentType,
                    onChanged: (val) {
                      setState(() {
                        selectedPaymentType = val;
                      });
                    },
                    items: AppString.paymentTypes,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: widget.type==ListType.ledger?PaymentPopupMenu(
                    label: "Payment Reason",
                    selectedValue: selectedPaymentReason,
                    onChanged: (val) {
                      setState(() {
                        selectedPaymentReason = val;
                      });
                    },
                    items: AppString.paymentReason,
                  ):SizedBox(),
                ),
              ],
            ),

            SizedBox(height: 15),

            // Buttons: Apply Filters & Reset
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: MyElevatedButton(
                    onPressed: () {
                      if (selectedRange == 'Custom') {
                        if (fromDate == null || toDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Please select both From and To dates',
                              ),
                            ),
                          );
                          return;
                        }
                        if (fromDate!.isAfter(toDate!)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'From Date cannot be after To Date',
                              ),
                            ),
                          );
                          return;
                        }
                      }
                      widget.onApply(fromDate, toDate, selectedRange,selectedPaymentType,selectedPaymentReason);
                    },
                    buttonText: 'Apply Filters'),
                  ),
                SizedBox(width: 12),
                Expanded(
                  child: MyElevatedButton(
                    onPressed: _resetFilters,
                    buttonText: 'Reset',
                    backgroundColor: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
