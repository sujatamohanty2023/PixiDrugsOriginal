import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../constant/all.dart';
import '../shareFileToWhatsApp.dart';
import 'LedgerModel.dart';

class LedgerPdfGenerator {
  /// 🔹 Internal function to generate and return PDF file path
  static Future<String> _generateLedgerPdf(LedgerModel ledger) async {
    final pdf = pw.Document();
    final last7 = (ledger.history ?? []).take(7).toList();

    // ✅ Load font
    final fontData = await rootBundle.load('assets/fonts/Signika-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    // Load and resize logo image
    final ByteData data = await rootBundle.load(AppImages.AppIcon);
    final Uint8List bytes = data.buffer.asUint8List();
    final img.Image? original = img.decodeImage(bytes);
    final resized = img.copyResize(original!, width: 384);
    final logoBytes = Uint8List.fromList(img.encodePng(resized));

    // Build the PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildLedgerLayout(
          logoBytes: logoBytes,
          ledger: ledger,
          last7: last7,
          ttf:ttf
        ),
      ),
    );

    // Save PDF
    Directory? downloadsDir;
    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download');
    } else {
      downloadsDir = await getApplicationDocumentsDirectory();
    }

    final file = File("${downloadsDir.path}/ledger_${DateTime.now().millisecondsSinceEpoch}.pdf");
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  /// 📥 Download and open PDF
  static Future<void> downloadLedgerPdf(BuildContext context, LedgerModel ledger) async {
    try {
      final path = await _generateLedgerPdf(ledger);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PDF saved to Downloads")),
      );
      await OpenFile.open(path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  /// 📤 Share via WhatsApp
  static Future<void> generateAndShareLedgerPdf(BuildContext context, LedgerModel ledger) async {
    try {
      final path = await _generateLedgerPdf(ledger);
      if (ledger.phone.isNotEmpty) {
        await shareFileToWhatsApp(
          phoneNumber: "91${ledger.phone.replaceAll('+91', '')}",
          filePath: path,
          message: '''
Dear ${ledger.sellerName},

Please find your latest ledger summary attached.

Net Due: ₹${ledger.dueAmount}

Thank you,
PixiDrugs
''',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid mobile number")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sharing PDF: $e")),
      );
    }
  }

  /// 📄 PDF Layout Builder
  static pw.Widget _buildLedgerLayout({
    required Uint8List logoBytes,
    required LedgerModel ledger,
    required List<History> last7,
    required pw.Font ttf,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Align(
          alignment: pw.Alignment.topRight,
          child: pw.Image(pw.MemoryImage(logoBytes), width: 80),
        ),
        pw.Text(
          ledger.sellerName ?? "-",
          style: pw.TextStyle(font: ttf,fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue),
        ),
        pw.SizedBox(height: 8),
        pw.Row(children: [
          pw.Text("Phone: ", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold,font: ttf,)),
          pw.Text(ledger.phone ?? "-", style: pw.TextStyle(fontSize: 14,font: ttf,)),
        ]),
        pw.Row(children: [
          pw.Text("GST No: ", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold,font: ttf,)),
          pw.Text(ledger.gstNo ?? "-", style: pw.TextStyle(fontSize: 14,font: ttf,)),
        ]),
        pw.SizedBox(height: 12),
        _buildLedgerTable(last7,ttf),
        pw.SizedBox(height: 12),
        _buildLedgerSummary(ledger,ttf),
      ],
    );
  }

  /// 🔹 Ledger Table
  static pw.Widget _buildLedgerTable(List<History> entries, pw.Font ttf) {
    return pw.Table(
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
      columnWidths: {
        0: pw.FlexColumnWidth(2),
        1: pw.FlexColumnWidth(2),
        2: pw.FlexColumnWidth(2),
        3: pw.FlexColumnWidth(2),
        4: pw.FlexColumnWidth(2),
        5: pw.FlexColumnWidth(2),
        6: pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF062A49)),
          children: [
            headerCell("Date", font: ttf),
            headerCell("Invoice No", font: ttf),
            headerCell("Type", font: ttf),
            headerCell("Ref", font: ttf),
            headerCell("Debit", alignRight: true, font: ttf),
            headerCell("Credit", alignRight: true, font: ttf),
            headerCell("Amount", alignRight: true, font: ttf),
          ],
        ),
        ...entries.map((item) {
          final reason = (item.paymentReason ?? "").toLowerCase();
          final debit = reason == "debit" ? (item.amount ?? "0") : "";
          final credit = reason == "credit" ? (item.amount ?? "0") : "";

          PdfColor typeColor = PdfColors.grey;
          if ((item.paymentType ?? "").toLowerCase() == "cash") {
            typeColor = PdfColors.green;
          } else if ((item.paymentType ?? "").toLowerCase() == "bank") {
            typeColor = PdfColors.blue;
          }

          return pw.TableRow(
            children: [
              bodyDateCell(item.paymentDate, padding: 6, font: ttf),
              bodyCell(item.invoiceNo, padding: 6, font: ttf),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Container(
                  width: 45,
                  padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                  decoration: pw.BoxDecoration(
                    color: typeColor,
                    borderRadius: pw.BorderRadius.circular(3),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      item.paymentType ?? "-",
                      maxLines: 1,
                      overflow: pw.TextOverflow.clip,
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 10, font: ttf),
                    ),
                  ),
                ),
              ),
              bodyCell(item.paymentReference, padding: 6, font: ttf),
              bodyCell(debit.isEmpty ? "-" : debit, alignRight: true, color: PdfColors.red, padding: 6, font: ttf),
              bodyCell(credit.isEmpty ? "-" : credit, alignRight: true, color: PdfColors.green, padding: 6, font: ttf),
              bodyCell(item.amount, alignRight: true,
                color: (double.tryParse(item.amount ?? "0") ?? 0) < 0 ? PdfColors.red : PdfColors.green,
                padding: 6,
                font: ttf,
              ),
            ],
          );
        }),
      ],
    );
  }


  /// 🔹 Summary Footer
  static pw.Widget _buildLedgerSummary(LedgerModel ledger, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFFC4DAF6)),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total Credit:', style: pw.TextStyle(font: font)),
              pw.Text(ledger.totalCredit, style: pw.TextStyle(color: PdfColors.green, font: font)),
            ],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total Debit:', style: pw.TextStyle(font: font)),
              pw.Text(ledger.totalDebit, style: pw.TextStyle(color: PdfColors.red, font: font)),
            ],
          ),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Net Due:', style: pw.TextStyle(font: font)),
              pw.Text('${ledger.dueAmount}',
                  style: pw.TextStyle(color: PdfColors.green, fontWeight: pw.FontWeight.bold, font: font)),
            ],
          ),
        ],
      ),
    );
  }


  /// 🔹 Header Cell
  static pw.Widget headerCell(String text, {bool alignRight = false, required pw.Font font}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, font: font),
      ),
    );
  }


  /// 🔹 Body Cell
  static pw.Widget bodyCell(String? text,
      {bool alignRight = false, PdfColor? color, double padding = 2, bool noWrap = false, required pw.Font font}) {
    final safeText = (text == null || text.trim().isEmpty) ? "-" : text;
    return pw.Padding(
      padding: pw.EdgeInsets.all(padding),
      child: pw.Text(
        safeText,
        maxLines: noWrap ? 1 : null,
        softWrap: !noWrap,
        overflow: noWrap ? pw.TextOverflow.clip : pw.TextOverflow.visible,
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(color: color ?? PdfColors.black, fontSize: 10, font: font),
      ),
    );
  }


  /// 🔹 Date Cell
  static pw.Widget bodyDateCell(String? rawDate, {double padding = 2, required pw.Font font}) {
    if (rawDate == null || rawDate.isEmpty) {
      return pw.Padding(
        padding: pw.EdgeInsets.all(padding),
        child: pw.Text("-", style: pw.TextStyle(font: font)),
      );
    }

    try {
      DateTime parsed = DateTime.parse(rawDate);
      String dayMonth = DateFormat("dd MMM").format(parsed);
      String year = DateFormat("yyyy").format(parsed);

      return pw.Padding(
        padding: pw.EdgeInsets.all(padding),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(dayMonth, style: pw.TextStyle(fontSize: 10, font: font)),
            pw.Text(year, style: pw.TextStyle(fontSize: 10, font: font)),
          ],
        ),
      );
    } catch (e) {
      return pw.Text(rawDate, style: pw.TextStyle(font: font));
    }
  }

}
