import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../constant/all.dart';
import 'LedgerModel.dart';

Future<void> generateAndSaveLedgerPdf(LedgerModel ledger, BuildContext context) async {
  final pdf = pw.Document();
  final last7 = (ledger.history ?? []).take(7).toList();

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

  // double netDue = totalCredit - totalDebit;

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(ledger.sellerName ?? "-", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),

          // Table header
          pw.Container(
            color: PdfColor.fromInt(0xFF062A49),
            padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: pw.Row(
              children: [
                pw.Expanded(flex: 2, child: pw.Text('Date', style: pw.TextStyle( fontWeight: pw.FontWeight.bold, color: PdfColors.white))),
                pw.Expanded(flex: 2, child: pw.Text('Type', style: pw.TextStyle( fontWeight: pw.FontWeight.bold, color: PdfColors.white))),
                // pw.Expanded(flex: 2, child: pw.Text('Invoice No.', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, color: PdfColors.white), textAlign: pw.TextAlign.center)),
                pw.Expanded(flex: 1, child: pw.Text('Mode', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white))),
                pw.Expanded(flex: 1, child: pw.Text('Ref No', style: pw.TextStyle( fontWeight: pw.FontWeight.bold, color: PdfColors.white))),
                pw.Expanded(flex: 2, child: pw.Text('Amount', style: pw.TextStyle( fontWeight: pw.FontWeight.bold, color: PdfColors.white), textAlign: pw.TextAlign.right)),
              ],
            ),
          ),
          pw.Divider(),
          // Table data
          ...last7.map((item) {
            String typeText = "-";
            final reason = (item.paymentReason ?? "").toLowerCase();
            if (reason == "debit") {
              typeText = "Payment Out";
            } else if (reason == "credit") {
              typeText = "purchase in";
            }

            return pw.Row(children: [
              pw.Expanded(flex: 2, child: pw.Text(item.paymentDate ?? "-")),
              pw.Expanded(flex: 2, child: pw.Text(typeText)),
              pw.Expanded(flex: 1, child: pw.Text(item.paymentType ?? "-")),
              pw.Expanded(flex: 1, child: pw.Text(item.paymentReference ?? "-")),
              pw.Expanded(flex: 2, child: pw.Text(item.amount ?? "0", textAlign: pw.TextAlign.right)),
            ]);
          }),

          pw.Divider(),
          pw.SizedBox(height: 12),

          // Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFFC4DAF6),),
            child: pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [pw.Text('Total Debit:'), pw.Text('${ledger.totalDebit}')],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [pw.Text('Total Credit:'), pw.Text('${ledger.totalCredit}')],
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [pw.Text('Net Due:'), pw.Text('${ledger.dueAmount}')],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Uint8List bytes = await pdf.save();

  // ✅ Save to Downloads folder (visible in device)
  Directory? downloadsDir;

  if (Platform.isAndroid) {
    downloadsDir = Directory('/storage/emulated/0/Download'); // Default Downloads path
  } else {
    downloadsDir = await getApplicationDocumentsDirectory();
  }

  final file = File("${downloadsDir.path}/ledger_${DateTime.now().millisecondsSinceEpoch}.pdf");
  await file.writeAsBytes(bytes);

  // ✅ Open the PDF directly
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("PDF saved to Downloads and opened.")),
  );
}