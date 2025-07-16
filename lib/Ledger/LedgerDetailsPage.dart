import 'package:pixidrugs/Ledger/LedgerModel.dart';
import 'package:pixidrugs/Ledger/PaymentOutBottomSheet.dart';
import 'package:pixidrugs/constant/all.dart';

class LedgerDetailsPage extends StatefulWidget {
  LedgerModel? ledger;

  LedgerDetailsPage({super.key, required this.ledger});

  @override
  State<LedgerDetailsPage> createState() => _LedgerDetailsPageState();
}

class _LedgerDetailsPageState extends State<LedgerDetailsPage> {
  int deleteId = 0;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: BlocListener<ApiCubit, ApiState>(
        listener: (context, state) {
          if (state is DeletePaymentLoaded) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            setState(() {
              widget.ledger!.history.removeWhere(
                (ledger) => ledger.id == deleteId,
              );
            });
          } else if (state is DeletePaymentError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Failed: ${state.error}')));
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
                      width: 140,
                      child: MyElevatedButton(
                        onPressed: () => _AddPaymentPressed(widget.ledger!),
                        backgroundColor: AppColors.kPrimaryDark,
                        titleColor: AppColors.kPrimary,
                        custom_design: true,
                        buttonText: "Add Payment",
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
                                  CircleAvatar(
                                    radius: screenWidth * 0.08,
                                    backgroundColor: AppColors.kPrimaryDark,
                                    child: MyTextfield.textStyle_w400(
                                      getInitials(widget.ledger!.sellerName),
                                      screenWidth * 0.045,
                                      AppColors.kPrimary,
                                    ),
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
                                              widget.ledger!.sellerName,
                                              screenWidth * 0.04,
                                              AppColors.kPrimary,
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
                                            GestureDetector(
                                              onTap: () {
                                                launchUrl(
                                                  Uri.parse(
                                                    "tel:+91${widget.ledger!.phone}",
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
                                            ),
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
                                                    screenWidth * 0.04,
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
                              child: MyTextfield.textStyle_w600(
                                'Payment History',
                                screenWidth * 0.05,
                                Colors.black,
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
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    MyTextfield.textStyle_w600(
                                                      payment == 'debit'
                                                          ? 'Payment Out'
                                                          : 'Purchase In',
                                                      20,
                                                      AppColors.kBlackColor900,
                                                    ),
                                                    SizedBox(height: 1),
                                                    Row(
                                                      children: [
                                                        MyTextfield.textStyle_w400(
                                                          "Dt.",
                                                          14,
                                                          Colors.grey[700]!,
                                                        ),
                                                        MyTextfield.textStyle_w400(
                                                          widget
                                                              .ledger!
                                                              .history[index]
                                                              .paymentDate,
                                                          16,
                                                          AppColors
                                                              .kBlackColor800,
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 1),
                                                    Row(
                                                      children: [
                                                        MyTextfield.textStyle_w400(
                                                          "Invoice No:",
                                                          14,
                                                          Colors.grey[700]!,
                                                        ),
                                                        MyTextfield.textStyle_w400(
                                                          '#${widget.ledger!.history[index].invoiceNo}',
                                                          16,
                                                          Colors.teal,
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 1),
                                                    payment == 'debit'
                                                        ? Row(
                                                          children: [
                                                            MyTextfield.textStyle_w400(
                                                              "Payment type:",
                                                              16,
                                                              Colors.grey[700]!,
                                                            ),
                                                            MyTextfield.textStyle_w400(
                                                              widget
                                                                  .ledger!
                                                                  .history[index]
                                                                  .paymentType,
                                                              14,
                                                              AppColors
                                                                  .kBlackColor800,
                                                            ),
                                                          ],
                                                        )
                                                        : SizedBox(),
                                                    SizedBox(height: 6),
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            payment == 'debit'
                                                                ? Colors
                                                                    .green[100]
                                                                : Colors
                                                                    .red[100],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                      child: MyTextfield.textStyle_w600(
                                                        "₹ ${widget.ledger!.history[index].amount}",
                                                        14,
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
                                                          widget
                                                              .ledger!
                                                              .history[index]
                                                              .id
                                                              .toString(),
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
                                                                Icon(
                                                                  Icons.edit,
                                                                  size: 18,
                                                                ),
                                                                SizedBox(
                                                                  width: 8,
                                                                ),
                                                                Text('Edit'),
                                                              ],
                                                            ),
                                                          ),
                                                          PopupMenuItem(
                                                            value: 'delete',
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  Icons.delete,
                                                                  size: 18,
                                                                  color:
                                                                      Colors
                                                                          .red,
                                                                ),
                                                                SizedBox(
                                                                  width: 8,
                                                                ),
                                                                Text(
                                                                  'Delete',
                                                                  style: TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .red,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                  ),
                                                  SizedBox(
                                                    height: screenWidth * 0.05,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      Share.share(
                                                        'Transaction: ${widget.ledger!.history[index]}',
                                                      );
                                                    },
                                                    child: SvgPicture.asset(
                                                      'assets/share.svg',
                                                      width: 18,
                                                      height: 18,
                                                      color:
                                                          AppColors
                                                              .kGreyColor700,
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

  void _deleteRecord(String id) async {
    try {
      deleteId = int.parse(id);
      await context.read<ApiCubit>().DeletePayment(id: id);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to delete record: $e")));
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
      builder:
          (context) => DraggableScrollableSheet(
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

  String getInitials(String name) {
    List<String> parts = name.trim().split(" ");
    return parts.length >= 2
        ? "${parts[0][0]}${parts[1][0]}"
        : name.substring(0, 2);
  }
}
