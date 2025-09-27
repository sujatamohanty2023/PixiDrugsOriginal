import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../constant/all.dart';
import '../shareFileToWhatsApp.dart';
import 'LedgerModel.dart';

class LedgerPdfGenerator {
  /// 🔹 Internal function to generate and return PDF file path
  static Future<String> _generateLedgerPdf(LedgerModel ledger,UserProfile user) async {
    final pdf = pw.Document();
    final last7 = (ledger.history ?? []).take(7).toList();

    // ✅ Load font
    final fontData = await rootBundle.load('assets/fonts/Signika-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    // Load and resize logo image
    final ByteData data = await rootBundle.load(AppImages.pdf_logo);
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
          user:user,
          last7: last7,
          ttf:ttf
        ),
      ),
    );

    // Save PDF with proper error handling
    Directory? downloadsDir;
    try {
      if (Platform.isAndroid) {
        // Try external storage first, fallback to app documents
        final externalDir = Directory('/storage/emulated/0/Download');
        if (await externalDir.exists()) {
          downloadsDir = externalDir;
        } else {
          downloadsDir = await getApplicationDocumentsDirectory();
        }
      } else {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      // Ensure directory exists
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final fileName = "ledger_${ledger.sellerName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final file = File("${downloadsDir.path}/$fileName");
      
      await file.writeAsBytes(await pdf.save());
      
      // Verify file was written
      if (!await file.exists() || await file.length() == 0) {
        throw Exception("Failed to write PDF file");
      }

      return file.path;
    } catch (e) {
      // Fallback to app cache directory if all else fails
      final cacheDir = await getTemporaryDirectory();
      final fileName = "ledger_${ledger.sellerName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final file = File("${cacheDir.path}/$fileName");
      await file.writeAsBytes(await pdf.save());
      return file.path;
    }
  }

  /// 📥 Download and open PDF
  static Future<void> downloadLedgerPdf(BuildContext context, LedgerModel ledger,UserProfile user) async {
    try {
      final path = await _generateLedgerPdf(ledger,user);
      
      // Check if file was created successfully
      final file = File(path);
      if (await file.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("PDF downloaded: ${file.path.split('/').last}"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Try to open the file
        final result = await OpenFile.open(path);
        if (result.type != ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("PDF saved but couldn't open automatically. Check Downloads folder."),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        throw Exception("Failed to create PDF file");
      }
    } catch (e) {
      print("Error downloading PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error downloading PDF: ${e.toString()}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  /// 📤 Share via WhatsApp
  static Future<void> generateAndShareLedgerPdf(BuildContext context, LedgerModel ledger,UserProfile user) async {
    try {
      final path = await _generateLedgerPdf(ledger,user);
      
      // Check if phone is valid (not empty, not 'NA', and has valid format)
      final phone = ledger.phone.trim();
      if (phone.isNotEmpty && !phone.contains('NA') && phone.length >= 10) {
        // Clean phone number: remove +91, spaces, and ensure it starts with 91
        String cleanPhone = phone.replaceAll(RegExp(r'[+\s-]'), '');
        if (!cleanPhone.startsWith('91') && cleanPhone.length == 10) {
          cleanPhone = '91$cleanPhone';
        }
        
        await shareFileToWhatsApp(
          phoneNumber: cleanPhone,
          filePath: path,
          message: '''Dear ${ledger.sellerName},

Please find your latest ledger summary attached.

Net Due: ₹${ledger.dueAmount}

Thank you,
PixiDrugs''',
        );
        AppUtils.showSnackBar(context, "PDF shared successfully");
      } else {
        AppUtils.showSnackBar(context, "Please add a valid mobile number for this party");
      }
    } catch (e) {
      print("Error sharing PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sharing PDF: ${e.toString()}"), backgroundColor: Colors.red),
      );
    }
  }
  static String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// 📄 PDF Layout Builder
  static pw.Widget _buildLedgerLayout({
    required Uint8List logoBytes,
    required LedgerModel ledger,
    required UserProfile user,
    required List<History> last7,
    required pw.Font ttf,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [

        // 🟦 Header Row with Logo and User Info
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 30),
                pw.Text(
                  user.name.toUpperCase() ?? "-",
                  style: pw.TextStyle(font: ttf, fontSize: 25, fontWeight: pw.FontWeight.bold, color: PdfColors.blue),
                ),
                pw.SizedBox(height: 4),
                pw.Text("Phone: ${user.phoneNumber ?? '-'}", style: pw.TextStyle(fontSize: 12, font: ttf)),
                pw.Text("Address: ${_capitalizeFirstLetter(user.address ?? '-')}", style: pw.TextStyle(fontSize: 12, font: ttf)),
              ],
            ),
          ],
        ),

        pw.SizedBox(height: 4),

        // 🟨 Divider Line
        pw.Divider(thickness: 1, color: PdfColors.grey),

        pw.SizedBox(height: 10),

        // 🧾 Seller Info
        pw.Text(
          ledger.sellerName ?? "-",
          style: pw.TextStyle(font: ttf, fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue),
        ),
        pw.SizedBox(height: 8),
        pw.Row(children: [
          pw.Text("Phone: ", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, font: ttf)),
          pw.Text(ledger.phone ?? "-", style: pw.TextStyle(fontSize: 14, font: ttf)),
        ]),
        pw.Row(children: [
          pw.Text("GST No: ", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, font: ttf)),
          pw.Text(ledger.gstNo ?? "-", style: pw.TextStyle(fontSize: 14, font: ttf)),
        ]),

        pw.SizedBox(height: 12),

        // 📊 Ledger Table and Summary
        _buildLedgerTable(last7, ttf),
        pw.SizedBox(height: 12),
        _buildLedgerSummary(ledger, ttf),
        pw.SizedBox(height: 30),
        pw.Image(pw.MemoryImage(logoBytes), height: 150),
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
