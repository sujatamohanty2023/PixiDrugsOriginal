
import 'package:PixiDrugs/Ledger/LedgerPdfGenerator.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:PixiDrugs/Ledger/LedgerModel.dart';
import 'package:PixiDrugs/Ledger/PaymentOutBottomSheet.dart';
import 'package:PixiDrugs/constant/all.dart';
import 'package:PixiDrugs/shareFileToWhatsApp.dart';

import '../customWidget/GradientInitialsBox.dart';


class LedgerDetailsPage extends StatefulWidget {
  LedgerModel? ledger;

  LedgerDetailsPage({super.key, required this.ledger});

  @override
  State<LedgerDetailsPage> createState() => _LedgerDetailsPageState();
}

class _LedgerDetailsPageState extends State<LedgerDetailsPage> {
  UserProfile? user;

  String truncateWords(String text, int wordLimit) {
    List<String> words = text.split(" ");
    if (words.length <= wordLimit) return text;
    return words.take(wordLimit).join(" ") + " ...";
  }

  int deleteId = 0;
  String? role;
  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    role = await SessionManager.getRole();
    String? userId = await SessionManager.getUserId();
    if (userId != null) {
      context.read<ApiCubit>().GetUserData(userId: userId, useCache: false);
    }
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: BlocListener<ApiCubit, ApiState>(
        listener: (context, state) {
          if (state is DeletePaymentLoaded) {
            AppUtils.showSnackBar(context,state.message);
            setState(() {
              widget.ledger!.history.removeWhere(
                    (ledger) => ledger.id == deleteId,
              );
            });
          } else if (state is DeletePaymentError) {
            AppUtils.showSnackBar(context,'Failed: ${state.error}');
          }else if (state is UserProfileLoaded) {
            setState(() {
              user=state.userModel.user;
            });
          }
        },
        child: Container(
          color: AppColors.kPrimary,
          width: double.infinity,
          padding: EdgeInsets.only(top: screenWidth * 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                          'Party Details',
                          screenWidth * 0.055,
                          Colors.white,
                        ),
                      ],
                    ),
                    Container(
                      height: 40,
                      child: MyElevatedButton(
                        onPressed: () => _AddPaymentPressed(widget.ledger!),
                        backgroundColor: AppColors.kPrimaryDark,
                        titleColor: AppColors.kPrimary,
                        custom_design: true,
                        buttonText: "Pay stockist",
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.02,
                    vertical: screenWidth * 0.02,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.myGradient,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(screenWidth * 0.07),
                      topLeft: Radius.circular(screenWidth * 0.07),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Party Card
                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.03,
                          ),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.only(
                            left: 10,
                            right: 10,
                            top: 10,
                            bottom: 10,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Main Content: Avatar + Party Info
                              Row(
                                children: [
                                  GradientInitialsBox(
                                    size: screenWidth * 0.15,
                                    name: widget.ledger!.sellerName,
                                  ),
                                  SizedBox(width: screenWidth * 0.03),

                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            MyTextfield.textStyle_w800(
                                                truncateWords(widget.ledger!.sellerName, 2),
                                                screenWidth * 0.04,
                                                AppColors.kPrimary,
                                                maxLines: 1
                                            ),
                                            SizedBox(
                                              height: screenWidth * 0.01,
                                            ),
                                            MyTextfield.textStyle_w400(
                                              'GSTIN: ${widget.ledger!.gstNo}',
                                              screenWidth * 0.035,
                                              Colors.grey.shade700,
                                              maxLines: true,
                                            ),
                                            MyTextfield.textStyle_w600(
                                              "Credit: ₹${widget.ledger!.totalCredit}",
                                              screenWidth * 0.035,
                                              Colors.green,
                                            ),
                                            MyTextfield.textStyle_w600(
                                              "Debit: ₹${widget.ledger!.totalDebit}",
                                              screenWidth * 0.035,
                                              Colors.orange,
                                            ),
                                            SizedBox(
                                              height: screenWidth * 0.01,
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                          children: [
                                            // Call button
                                            !widget.ledger!.phone.contains('NA')?GestureDetector(
                                              onTap: () {
                                                launchUrl(
                                                  Uri.parse(
                                                    "tel:${AppUtils().validateAndNormalizePhone(widget.ledger!.phone)}",
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: Colors.green[100],
                                                  borderRadius:
                                                  BorderRadius.circular(10),
                                                ),
                                                child: Icon(
                                                  Icons.call,
                                                  color: Colors.green,
                                                  size: 25,
                                                ),
                                              ),
                                            ):SizedBox(),
                                            SizedBox(
                                              height: screenWidth * 0.05,
                                            ),
                                            Builder(
                                              builder: (context) {
                                                Color amountColor =
                                                widget.ledger!.dueAmount
                                                    .contains('-')
                                                    ? Colors.red
                                                    : Colors.green;

                                                return Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                    screenWidth * 0.025,
                                                    vertical:
                                                    screenWidth * 0.01,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: amountColor
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                      screenWidth * 0.02,
                                                    ),
                                                  ),
                                                  child: MyTextfield.textStyle_w600(
                                                    "₹${widget.ledger!.dueAmount}",
                                                    screenWidth * 0.032,
                                                    amountColor,
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 10),
                      // Invoices & Payments
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  MyTextfield.textStyle_w600('Transaction Details', screenWidth * 0.05, Colors.black),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _showTransactionsBottomSheet(context);
                                      });
                                      print("Options tapped");
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: AppColors.myGradient,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.remove_red_eye, color: AppColors.kPrimary, size: 18),
                                          SizedBox(width: 5,),
                                          MyTextfield.textStyle_w600('History', 16, AppColors.kPrimary),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),

                            Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: widget.ledger!.history.length,
                                itemBuilder: (context, index) {
                                  final payment =
                                      widget
                                          .ledger!
                                          .history[index]
                                          .paymentReason;
                                  final icon =
                                  payment == 'debit'
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward;

                                  return Card(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Stack(
                                        children: [
                                          Row(
                                            // crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Avatar with Icon
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 12.0,
                                                ),
                                                child: CircleAvatar(
                                                  radius: 30,
                                                  backgroundColor:
                                                  payment == 'debit'
                                                      ? Colors.green[100]
                                                      : Colors.red[100],
                                                  child: Icon(
                                                    icon,
                                                    color:
                                                    payment == 'debit'
                                                        ? Colors.green[800]
                                                        : Colors.red[800],
                                                  ),
                                                ),
                                              ),
                                              // Payment Info
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    // Header Title
                                                    MyTextfield.textStyle_w600(
                                                      payment == 'debit' ? 'Payment Out' : 'Purchase In',
                                                      screenWidth * 0.04,
                                                      AppColors.kBlackColor900,
                                                    ),
                                                    const SizedBox(height: 1),

                                                    // Date Row
                                                    Row(
                                                      children: [
                                                        MyTextfield.textStyle_w400(
                                                          "Dt.",
                                                          screenWidth * 0.03,
                                                          Colors.grey[700]!,
                                                        ),
                                                        MyTextfield.textStyle_w400(
                                                          widget.ledger!.history[index].paymentDate,
                                                          screenWidth * 0.035,
                                                          AppColors.kBlackColor800,
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 1),

                                                    // ✅ Invoice No (only visible for Purchase In)
                                                    payment != 'debit'
                                                        ? Row(
                                                      children: [
                                                        MyTextfield.textStyle_w400(
                                                          "Invoice No:",
                                                          screenWidth * 0.035,
                                                          Colors.grey[700]!,
                                                        ),
                                                        MyTextfield.textStyle_w400(
                                                          '#${widget.ledger!.history[index].invoiceNo}',
                                                          screenWidth * 0.035,
                                                          Colors.teal,
                                                        ),
                                                      ],
                                                    )
                                                        : const SizedBox(),
                                                    const SizedBox(height: 1),

                                                    // ✅ Payment Type (only visible for Payment Out)
                                                    payment == 'debit'
                                                        ? Row(
                                                      children: [
                                                        MyTextfield.textStyle_w400(
                                                          "Payment type:",
                                                          screenWidth * 0.035,
                                                          Colors.grey[700]!,
                                                        ),
                                                        MyTextfield.textStyle_w400(
                                                          widget.ledger!.history[index].paymentType,
                                                          screenWidth * 0.035,
                                                          AppColors.kBlackColor800,
                                                        ),
                                                      ],
                                                    )
                                                        : const SizedBox(),
                                                    const SizedBox(height: 6),

                                                    // Amount Container
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: payment == 'debit'
                                                            ? Colors.green[100]
                                                            : Colors.red[100],
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: MyTextfield.textStyle_w600(
                                                        "₹ ${widget.ledger!.history[index].amount}",
                                                        screenWidth * 0.038,
                                                        payment == 'debit'
                                                            ? Colors.green[800]!
                                                            : Colors.red[800]!,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Popup menu
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                                children: [
                                                  PopupMenuButton<String>(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(16), // Rounded shape
                                                    ),
                                                    color: AppColors.kWhiteColor, // so gradient shows
                                                    elevation: 10,
                                                    onSelected: (value) {
                                                      if (value == 'edit') {
                                                        _AddPaymentPressed(
                                                          widget.ledger!,
                                                          edit: true,
                                                          index: index,
                                                        );
                                                      } else if (value ==
                                                          'delete') {
                                                        _showDeleteDialog(
                                                          context,
                                                          widget.ledger!.history[index].id.toString(),
                                                        );
                                                      }
                                                    },
                                                    itemBuilder:
                                                        (
                                                        BuildContext context,
                                                        ) => [
                                                      PopupMenuItem(
                                                        value: 'edit',
                                                        child: Row(
                                                          children: [
                                                            SvgPicture.asset(AppImages.edit, height: 18, color: AppColors.kPrimary),
                                                            SizedBox(
                                                              width: 8,
                                                            ),
                                                            MyTextfield.textStyle_w600('Edit', 13, AppColors.kPrimary),
                                                          ],
                                                        ),
                                                      ),
                                                      if(role=='owner')
                                                        PopupMenuItem(
                                                          value: 'delete',
                                                          child: Row(
                                                            children: [
                                                              SvgPicture.asset(AppImages.delete, height: 18,  color: AppColors.kRedColor,),
                                                              SizedBox(width: 8),
                                                              MyTextfield.textStyle_w600('Delete', 13, AppColors.kRedColor),
                                                            ],
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: screenWidth * 0.05,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      await LedgerPdfGenerator.generateAndShareLedgerPdf(context,  widget.ledger!,user!);
                                                    },
                                                    child: SvgPicture.asset(
                                                      'assets/share.svg',
                                                      width: 18,
                                                      height: 18,
                                                      color: AppColors.kGreyColor700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showTransactionsBottomSheet(BuildContext context) async {

    double screenWidth = MediaQuery.of(context).size.width;
    final last7 = (widget.ledger!.history ?? []).take(7).toList();

    double totalDebit = 0;
    double totalCredit = 0;

    for (var item in last7) {
      final reason = (item.paymentReason ?? "").toLowerCase();
      final amount = double.tryParse(item.amount ?? '0') ?? 0;

      if (reason == 'debit') {
        totalDebit += amount;
      } else if (reason == 'purchase in') {
        totalCredit += amount;
      }
    }

    // ✅ Correct Net Due Logic (Credit - Debit)
    // double netDue = totalCredit - totalDebit;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyTextfield.textStyle_w800(
                widget.ledger!.sellerName ?? "-",
                screenWidth * 0.038,
                Colors.black,
              ),
              const SizedBox(height: 12),

              // Table Header
              Container(
                color: AppColors.kPrimary,
                padding:  EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child:  Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: MyTextfield.textStyle_w400(
                        "Date",
                        screenWidth * 0.038,
                        Colors.white,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: MyTextfield.textStyle_w400(
                        "Type",
                        screenWidth * 0.038,
                        Colors.white,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: MyTextfield.textStyle_w400(
                        "Mode",
                        screenWidth * 0.038,
                        Colors.white,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: MyTextfield.textStyle_w400(
                        "Ref No",
                        screenWidth * 0.038,
                        Colors.white,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: MyTextfield.textStyle_w400("Amount", screenWidth * 0.038, Colors.white,textAlign: TextAlign.right,),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Table Data
              ...last7.map((item) {
                String typeText = "-";
                Color amountColor = Colors.black;
                final reason = (item.paymentReason ?? "").toLowerCase();

                if (reason == "debit") {
                  typeText = "Payment Out";
                  amountColor = Colors.red;
                } else if (reason == "credit") {
                  typeText = "purchase in";
                  amountColor = Colors.green;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child:
                      MyTextfield.textStyle_w400(item.paymentDate ?? "-", screenWidth * 0.038, Colors.black,),
                      ),
                      Expanded(flex: 2, child:
                      MyTextfield.textStyle_w400(typeText, screenWidth * 0.038, amountColor,),
                      ),
                      Expanded(flex: 1, child: MyTextfield.textStyle_w400(item.paymentType ?? "-", screenWidth * 0.038, Colors.black,),
                      ),
                      Expanded(flex: 1, child: MyTextfield.textStyle_w400(item.paymentReference ?? "-", screenWidth * 0.038, Colors.black,),
                      ),
                      Expanded(
                        flex: 2,
                        child: MyTextfield.textStyle_w400( item.amount ?? "0", screenWidth * 0.038, Colors.green,textAlign: TextAlign.right,),
                      ),
                    ],
                  ),
                );
              }),

              const Divider(thickness: 1),
              const SizedBox(height: 8),

              // Summary Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:  Color(0xFFC4DAF6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyTextfield.textStyle_w400('Total Credit:', screenWidth * 0.038, Colors.black,),
                        MyTextfield.textStyle_w400( '${widget.ledger!.totalCredit}', screenWidth * 0.038, Colors.green,),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyTextfield.textStyle_w400( 'Total Debit:', screenWidth * 0.038, Colors.black,),
                        MyTextfield.textStyle_w400( '${widget.ledger!.totalDebit}', screenWidth * 0.038, Colors.red,),
                      ],
                    ),

                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyTextfield.textStyle_w400('Net Due:', screenWidth * 0.038, Colors.black,),
                        MyTextfield.textStyle_w400('${widget.ledger!.dueAmount}', screenWidth * 0.038, Colors.green,),
                      ],
                    ),

                  ],
                ),
              ),
              // const SizedBox(height: 10),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: MyElevatedButton(
                      onPressed: () async {
                        await LedgerPdfGenerator.generateAndShareLedgerPdf(context,  widget.ledger!,user!);
                      },
                      buttonText: 'Share',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MyElevatedButton(
                      onPressed: () async {
                        await LedgerPdfGenerator.downloadLedgerPdf(context,  widget.ledger!,user!);
                      },
                      buttonText: 'Download',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
  void _deleteRecord(String id) async {
    try {
      deleteId = int.parse(id);
      await context.read<ApiCubit>().DeletePayment(id: id);
    } catch (e) {
      AppUtils.showSnackBar(context,"Failed to delete record: $e");
    }
  }

  void _showDeleteDialog(BuildContext context, String id) {
    CommonConfirmationDialog.show<String>(
      context: context,
      id: id,
      title: 'Delete this Payment Record?',
      content: 'Are you sure you want to delete this payment record?',
      onConfirmed: (_) => _deleteRecord(id),
    );
  }

  void _AddPaymentPressed(
      LedgerModel ledger, {
        var edit = false,
        var index = 0,
      }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.kWhiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
      ),
      constraints: BoxConstraints.loose(
        Size(SizeConfig.screenWidth!, SizeConfig.screenHeight! * 0.83),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.73,
        minChildSize: 0.73,
        maxChildSize: 0.85,
        builder: (context, scrollController) {
          return PaymentOutEntryPage(
            edit: edit,
            index: index,
            ledger: ledger,
            scrollController: scrollController,
          );
        },
      ),
    );
  }
}
