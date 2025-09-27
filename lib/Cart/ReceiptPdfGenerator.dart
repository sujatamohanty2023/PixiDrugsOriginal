import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../SaleList/sale_model.dart';
import '../../constant/all.dart';
import '../shareFileToWhatsApp.dart';

class ReceiptPdfGenerator {
  /// Generate receipt PDF and return saved file path
  static Future<String> _generatePdf(SaleModel saleItem,UserProfile user) async {
    final pdf = pw.Document();

    // ✅ Load font
    final fontData = await rootBundle.load('assets/fonts/Signika-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    // ✅ Load logo image
    pw.MemoryImage? logoImage;
    try {
      final bytes = (await rootBundle.load(AppImages.pdf_logo)).buffer.asUint8List();
      logoImage = pw.MemoryImage(bytes);
    } catch (_) {}

    // ✅ Helper to calculate subtotal
    double calculateSubtotal(SaleItem item) {
      final price = item.price ?? 0;
      final quantity = item.quantity ?? 0;
      final discount = item.discount ?? 0;
      final total = price * quantity;
      return total - (total * discount / 100);
    }

    final items = saleItem.items ?? [];
    final totalItemAmount = items.fold<double>(
        0, (sum, item) => sum + ((item.price ?? 0) * (item.quantity ?? 0)));
    final totalDiscount = items.fold<double>(
        0,
            (sum, item) =>
        sum +
            ((item.price ?? 0) *
                (item.quantity ?? 0) *
                ((item.discount ?? 0) / 100)));
    final totalAmount = totalItemAmount - totalDiscount;

    // ✅ Add page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4, // or PdfPageFormat.roll80 for thermal
        margin: const pw.EdgeInsets.all(16),
        build: (context) {
          return _buildReceiptLayout(
            ttf,
            logoImage,
            saleItem,
            items,
            totalItemAmount,
            totalDiscount,
            totalAmount,
            calculateSubtotal,
            user,
          );
        },
      ),
    );

    // ✅ Save PDF in temp dir
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/receipt_${saleItem.invoiceNo}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  /// Download PDF (open in viewer / saved to storage)
  static Future<void> downloadPdf(BuildContext context, SaleModel saleItem,UserProfile user) async {
    try {
      final filePath = await _generatePdf(saleItem,user);
      AppUtils.showSnackBar(context, 'Download Completed...');
      await OpenFile.open(filePath); // Open with default PDF viewer
    } catch (e) {
      AppUtils.showSnackBar(context, 'Error saving PDF: $e');
    }
  }
  /// Share PDF via WhatsApp
  static Future<void> generateAndSharePdf(BuildContext context, SaleModel saleItem,UserProfile user) async {
    try {
      final filePath = await _generatePdf(saleItem,user);
      if (saleItem.customer.phone.isNotEmpty &&
          saleItem.customer.phone != 'no number') {
        await _sharePdfViaWhatsApp(saleItem, filePath);
      } else {
        AppUtils.showSnackBar(context, 'Invalid Mobile No.');
      }
    } catch (e) {
      AppUtils.showSnackBar(context, 'Error sharing PDF: $e');
    }
  }

  /// ✅ Receipt Layout
  static pw.Widget _buildReceiptLayout(
      pw.Font ttf,
      pw.MemoryImage? logoImage,
      SaleModel saleItem,
      List<SaleItem> items,
      double totalItemAmount,
      double totalDiscount,
      double totalAmount,
      double Function(SaleItem) calculateSubtotal,
      UserProfile user,
      ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 30),
        pw.Center(
          child: pw.Text(user.name.toUpperCase() ?? "-",
              style: pw.TextStyle(
                  font: ttf,
                  fontSize: 25,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xFF1976D2))),
        ),
        pw.Center(
            child: pw.Text("Phone: ${user.phoneNumber ?? '-'}",
                style: pw.TextStyle(font: ttf, fontSize: 12))),
        pw.Center(
            child: pw.Text("Address: ${_capitalizeFirstLetter(user.address ?? '-')}",
                style: pw.TextStyle(font: ttf, fontSize: 12))),
        pw.Divider(color: PdfColors.grey400, thickness: 1, height: 20),

        // Invoice info
        pw.Row(children: [
          pw.Text('Invoice No:',
              style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
          pw.Text('#${saleItem.invoiceNo}', style: pw.TextStyle(font: ttf,color: PdfColors.deepOrange,fontSize: 15)),
        ]),
        pw.Row(children: [
          pw.Text('Date:',
              style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
          pw.Text('${saleItem.date ?? ''}', style: pw.TextStyle(font: ttf)),
        ]),
        pw.SizedBox(height: 12),

        // Customer
        pw.Text('Customer Details',
            style: pw.TextStyle(
                font: ttf,
                fontWeight: pw.FontWeight.bold,
                fontSize: 12,
                color: PdfColor.fromInt(0xFF062A49))),
        pw.Text('Name: ${_capitalizeFirstLetter(saleItem.customer.name ?? '')}',
            style: pw.TextStyle(font: ttf, fontSize: 11)),
        pw.Text('Phone: ${saleItem.customer.phone ?? ''}',
            style: pw.TextStyle(font: ttf, fontSize: 11)),
        pw.Text('Address: ${_capitalizeFirstLetter(saleItem.customer.address ?? '')}',
            style: pw.TextStyle(font: ttf, fontSize: 11)),
        pw.Text('Sale Person: ${_capitalizeFirstLetter(saleItem.soldBy.name ?? '')}',
            style: pw.TextStyle(font: ttf, fontSize: 11)),
        pw.SizedBox(height: 20),

        // Table header
        pw.Container(
          color: PdfColor.fromInt(0xFF062A49),
          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: pw.Row(
            children: [
              pw.Expanded(flex: 4, child: pw.Text('Item', style: _headerStyle(ttf))),
              pw.Expanded(
                  flex: 2,
                  child: pw.Text('Qty',
                      style: _headerStyle(ttf),
                      textAlign: pw.TextAlign.center)),
              pw.Expanded(
                  flex: 2,
                  child: pw.Text('MRP',
                      style: _headerStyle(ttf),
                      textAlign: pw.TextAlign.right)),
              pw.Expanded(
                  flex: 2,
                  child: pw.Text('Disc',
                      style: _headerStyle(ttf),
                      textAlign: pw.TextAlign.center)),
              pw.Expanded(
                  flex: 2,
                  child: pw.Text('Total',
                      style: _headerStyle(ttf),
                      textAlign: pw.TextAlign.right)),
            ],
          ),
        ),

        ...items.map((item) {
          final subtotal = calculateSubtotal(item);
          return pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                    flex: 4,
                    child: pw.Text(item.productName ?? '',
                        style: pw.TextStyle(font: ttf, fontSize: 11))),
                pw.Expanded(
                    flex: 2,
                    child: pw.Text('${item.quantity ?? 0}',
                        style: pw.TextStyle(font: ttf, fontSize: 11),
                        textAlign: pw.TextAlign.center)),
                pw.Expanded(
                    flex: 2,
                    child: pw.Text('${(item.price ?? 0).toStringAsFixed(2)}',
                        style: pw.TextStyle(font: ttf, fontSize: 11),
                        textAlign: pw.TextAlign.right)),
                pw.Expanded(
                    flex: 2,
                    child: pw.Text('${item.discount ?? 0}%',
                        style: pw.TextStyle(font: ttf, fontSize: 11),
                        textAlign: pw.TextAlign.center)),
                pw.Expanded(
                    flex: 2,
                    child: pw.Text('${subtotal.toStringAsFixed(2)}',
                        style: pw.TextStyle(font: ttf, fontSize: 11),
                        textAlign: pw.TextAlign.right)),
              ],
            ),
          );
        }).toList(),

        pw.SizedBox(height: 10),

        // Total box
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromInt(0xFFC4DAF6),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _totalRow(ttf, 'Subtotal:', totalItemAmount),
              _totalRow(ttf, 'Discount:', totalDiscount, isDiscount: true),
              pw.Divider(),
              _totalRow(ttf, 'Total:', totalAmount, isTotal: true),
            ],
          ),
        ),

        pw.SizedBox(height: 30),
        _termsAndConditions(ttf),
        pw.SizedBox(height: 30),
        pw.Center(
          child: pw.Text('Thank you for shopping at ${_capitalizeFirstLetter(user.name)}',
              style: pw.TextStyle(
                  font: ttf, fontSize: 12, color: PdfColors.grey600)),
        ),
        pw.Center(
          child: pw.Text('Powered by PixiDrugs by PixiZip',
              style: pw.TextStyle(
                  font: ttf, fontSize: 12, color: PdfColors.cyan)),
        ),

        pw.SizedBox(height: 30),
        if (logoImage != null)
          pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Image(logoImage, height: 80),
          ),
      ],
    );
  }

  static pw.TextStyle _headerStyle(pw.Font ttf) => pw.TextStyle(
    font: ttf,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.white,
  );

  static pw.Widget _totalRow(pw.Font ttf, String label, double value,
      {bool isDiscount = false, bool isTotal = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label,
            style: pw.TextStyle(
                font: ttf,
                fontSize: isTotal ? 18 : 14,
                fontWeight: pw.FontWeight.bold)),
        pw.Text(
          isDiscount ? '-${value.toStringAsFixed(2)}' : '${value.toStringAsFixed(2)}',
          style: pw.TextStyle(
            font: ttf,
            fontSize: isTotal ? 18 : 14,
            fontWeight: pw.FontWeight.bold,
            color: isDiscount ? PdfColors.red : PdfColors.black,
          ),
        ),
      ],
    );
  }

  static pw.Widget _termsAndConditions(pw.Font ttf) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromInt(0xFFC4DAF6)),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Terms and Conditions',
              style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xFF062A49))),
          pw.SizedBox(height: 8),
          pw.Text(
            '1. Medicines must be stored as per the instructions on the packaging.\n'
                '2. Please consult your healthcare professional before using any medicine.\n'
                '3. Returns or exchanges are accepted only for damaged or defective products within 7 days.\n'
                '4. Keep the receipt as proof of purchase for warranty and returns.\n'
                '5. We are not responsible for any misuse or side effects of the medicines.\n'
                '6. Prices are subject to change without prior notice.\n'
                '7. Thank you for choosing PixiDrugs.',
            style:
            pw.TextStyle(fontSize: 10, color: PdfColors.grey800, height: 1.3),
          ),
        ],
      ),
    );
  }

  static Future<void> _sharePdfViaWhatsApp(
      SaleModel saleItem, String filePath) async {
    await shareFileToWhatsApp(
      phoneNumber: "91${saleItem.customer.phone.replaceAll("+91", '')}",
      filePath: filePath,
      message: '''
Dear ${saleItem.customer.name},

Thank you for your purchase.

Invoice No: ${saleItem.invoiceNo}  
Amount: ₹${saleItem.totalAmount}

Please find your receipt attached.

Best regards,  
PixiDrugs
''',
    );
  }

  /// Helper function to capitalize first letter and make rest lowercase
  static String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}