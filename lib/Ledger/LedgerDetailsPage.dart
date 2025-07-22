import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pixidrugs/Ledger/LedgerModel.dart';
import 'package:pixidrugs/Ledger/PaymentOutBottomSheet.dart';
import 'package:pixidrugs/constant/all.dart';
import 'package:pixidrugs/shareFileToWhatsApp.dart';

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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  MyTextfield.textStyle_w600('Payment History', screenWidth * 0.05, Colors.black),
                                  GestureDetector(
                                    onTap: () => _shareLast7Transactions(widget.ledger!),
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: AppColors.myGradient,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.share, color: AppColors.kPrimary,size: 16),
                                          SizedBox(width: 5),
                                          MyTextfield.textStyle_w600('Share',16, AppColors.kPrimary),
                                        ],
                                      ),
                                    ),
                                  ),
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
                                                      _shareLast7Transactions(widget.ledger!);
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

  Future<void> _shareLast7Transactions(LedgerModel ledger) async {
    final pdf = pw.Document();
    final fontData = await rootBundle.load('assets/fonts/Signika-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    pw.MemoryImage? logoImage;
    try {
      final bytes = (await rootBundle.load(AppImages.AppIcon)).buffer.asUint8List();
      logoImage = pw.MemoryImage(bytes);
    } catch (_) {}

    // Sort and get last 7 transactions
    List<History> recentTransactions = ledger.history
        .where((t) => t.paymentDate != null && t.paymentDate.isNotEmpty)
        .toList();

    recentTransactions.sort((a, b) =>
        DateTime.parse(b.paymentDate).compareTo(DateTime.parse(a.paymentDate)));

    List<History> last7 = recentTransactions.take(7).toList();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(16),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (logoImage != null)
                pw.Align(
                  alignment: pw.Alignment.topRight,
                  child: pw.Image(logoImage, height: 80),
                ),
              pw.Align(
                alignment: pw.Alignment.topRight,
                child: pw.Text('PixiDrugs',
                    style: pw.TextStyle(
                        font: ttf,
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(0xFF062A49))),
              ),
              pw.Align(
                alignment: pw.Alignment.topRight,
                child: pw.Text('GSTIN: 1234567890',
                    style: pw.TextStyle(font: ttf, fontSize: 9)),
              ),
              pw.Align(
                alignment: pw.Alignment.topRight,
                child: pw.Text('Phone: 123456789',
                    style: pw.TextStyle(font: ttf, fontSize: 9)),
              ),
              pw.Align(
                alignment: pw.Alignment.topRight,
                child: pw.Text('Address: Berhampur',
                    style: pw.TextStyle(font: ttf, fontSize: 9)),
              ),
              pw.Divider(color: PdfColors.grey400, thickness: 1, height: 20),

              // Payment History Title
              pw.Text('Payment History',
                  style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16)),
              pw.SizedBox(height: 10),

              // Supplier Info
              pw.Text('Supplier Details',
                  style: pw.TextStyle(
                      font: ttf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                      color: PdfColor.fromInt(0xFF062A49))),
              pw.Text('Name: ${ledger.sellerName}',
                  style: pw.TextStyle(font: ttf, fontSize: 11)),
              pw.Text('Phone: ${ledger.phone}',
                  style: pw.TextStyle(font: ttf, fontSize: 11)),
              pw.Text('GSTIN: ${ledger.gstNo}',
                  style: pw.TextStyle(font: ttf, fontSize: 11)),
              pw.SizedBox(height: 20),

              // Table Header
              pw.Container(
                color: PdfColor.fromInt(0xFF062A49),
                padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: pw.Row(
                  children: [
                    pw.Expanded(flex: 2, child: pw.Text('Date', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, color: PdfColors.white))),
                    pw.Expanded(flex: 2, child: pw.Text('Type', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, color: PdfColors.white))),
                    pw.Expanded(flex: 2, child: pw.Text('Invoice No.', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, color: PdfColors.white), textAlign: pw.TextAlign.center)),
                    pw.Expanded(flex: 1, child: pw.Text('Mode', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, color: PdfColors.white))),
                    pw.Expanded(flex: 1, child: pw.Text('Ref No', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, color: PdfColors.white))),
                    pw.Expanded(flex: 2, child: pw.Text('Amount', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, color: PdfColors.white), textAlign: pw.TextAlign.right)),
                  ],
                ),
              ),

              // Table Rows
              ...last7.map((item) {
                return pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(flex: 2, child: pw.Text(item.paymentDate, style: pw.TextStyle(font: ttf, fontSize: 11))),
                      pw.Expanded(flex: 2, child: pw.Text(
                        item.paymentReason == 'debit' ? 'Payment Out' : 'Purchase In',
                        style: pw.TextStyle(font: ttf, fontSize: 11),
                      )),
                      pw.Expanded(flex: 2, child: pw.Text('#${item.invoiceNo}', style: pw.TextStyle(font: ttf, fontSize: 11), textAlign: pw.TextAlign.center)),
                      pw.Expanded(flex: 1, child: pw.Text('${item.paymentType}', style: pw.TextStyle(font: ttf, fontSize: 11))),
                      pw.Expanded(flex: 1, child: pw.Text('${item.paymentReference }', style: pw.TextStyle(font: ttf, fontSize: 11))),
                      pw.Expanded(flex: 2, child: pw.Text('${item.amount}', style: pw.TextStyle(font: ttf, fontSize: 11), textAlign: pw.TextAlign.right)),
                    ],
                  ),
                );
              }).toList(),

              pw.SizedBox(height: 20),

              // Summary Box
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFC4DAF6),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total Debit:',
                            style: pw.TextStyle(
                                font: ttf,
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold)),
                        pw.Text(
                            '${ledger.totalDebit}',
                            style: pw.TextStyle(font: ttf, fontSize: 14)),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total Credit:',
                            style: pw.TextStyle(
                                font: ttf,
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold)),
                        pw.Text(
                            '${ledger.totalCredit}',
                            style: pw.TextStyle(font: ttf, fontSize: 14)),
                      ],
                    ),
                    pw.Divider(),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Net Due:',
                            style: pw.TextStyle(
                                font: ttf,
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold)),
                        pw.Text(
                            '${ledger.dueAmount}',
                            style: pw.TextStyle(
                                font: ttf,
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),

              // Footer Message
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 30),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border:
                  pw.Border.all(color: PdfColor.fromInt(0xFFC4DAF6)),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Terms and Conditions',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(0xFF062A49),
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      '1. Payments are subject to verification.\n'
                          '2. Contact us for any disputes or queries.\n'
                          '3. Thank you for your business.',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey800,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text('Thank you for choosing PixiDrugs!',
                    style: pw.TextStyle(
                        font: ttf,
                        fontSize: 12,
                        color: PdfColors.grey600)),
              ),
            ],
          );
        },
      ),
    );

    // Save & share the PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/payment_history_${ledger.sellerName}.pdf');
    await file.writeAsBytes(await pdf.save());

    _sharePdfViaWhatsApp(ledger,file.path);
  }

  Future<void> _sharePdfViaWhatsApp(LedgerModel ledger, String filePath1) async {
    await shareFileToWhatsApp(
      phoneNumber: "91${ledger.phone.replaceAll("+91", '')}",
      filePath: filePath1,
      message: 'Dear Sir/Madam,\nPlease find attached the payment history for ${ledger.sellerName}.\n\nNet Due: ₹${ledger.dueAmount}\n\nThank you for your continued support.\n\nPixiDrugs',
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
