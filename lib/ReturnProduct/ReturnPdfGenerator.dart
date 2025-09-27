import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

import '../Profile/UserProfileModel.dart';
import '../ReturnStock/PurchaseReturnModel.dart';
import '../SaleReturn/CustomerReturnsResponse.dart';
import '../constant/images.dart';

class ReturnPdfGenerator {
  /// Generate Customer Return PDF (Download + Open + Optional Share)
  static String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  static Future<String> generateCustomerReturnPdf(
      UserProfile user, {
        required CustomerReturnsResponse stockReturn,
        bool share = false,
      }) async {
    final pdf = pw.Document();
    final fontData = await rootBundle.load('assets/fonts/Signika-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);
    final now = DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now());

    // ✅ Load and resize logo properly
    final ByteData data = await rootBundle.load(AppImages.pdf_logo);
    final Uint8List bytes = data.buffer.asUint8List();
    final img.Image? original = img.decodeImage(bytes);
    final img.Image resized = img.copyResize(original!, width: 100);
    final Uint8List logoBytes = Uint8List.fromList(img.encodePng(resized));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(25),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // pw.Center(
              //   child: pw.Text(
              //     "RETURN TO CUSTOMER",
              //     style: pw.TextStyle(
              //       font: ttf,
              //       fontSize: 20,
              //       fontWeight: pw.FontWeight.bold,
              //     ),
              //   ),
              // ),
              pw.SizedBox(height: 30),

              /// ✅ Logo + User Name + Address in Row
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        user.name.toUpperCase() ?? "-",
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        "Phone: ${user.phoneNumber ?? '-'}",
                        style: pw.TextStyle(font: ttf, fontSize: 12),
                      ),
                      pw.Text(
                        "Address: ${_capitalizeFirstLetter(user.address ?? '-')}",
                        style: pw.TextStyle(font: ttf, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Divider(thickness: 1, color: PdfColors.grey),
              pw.SizedBox(height: 20),

              pw.Text("Customer: ${_capitalizeFirstLetter(stockReturn.customer.name ?? '-')}",
                  style: pw.TextStyle(font: ttf, fontSize: 18,fontWeight: pw.FontWeight.bold)),
              pw.Text("Phone: ${stockReturn.customer.phone ?? '-'}",
                  style: pw.TextStyle(font: ttf, fontSize: 14)),
              pw.Text("Date: $now",
                  style: pw.TextStyle(font: ttf, fontSize: 14)),
              pw.Text("Reason: ${stockReturn.reason}",
                  style: pw.TextStyle(font: ttf, fontSize: 14)),
              pw.SizedBox(height: 10),

              _buildTable(
                ttf: ttf,
                headers: ["Product", "Batch", "Qty", "Rate", "Total"],
                rows: stockReturn.items.map((item) {
                  final rate = double.tryParse(item.price) ?? 0;
                  final total = rate * item.quantity;
                  return [
                    item.product.toString(),
                    item.batchNo,
                    item.quantity.toString(),
                    rate.toStringAsFixed(2),
                    total.toStringAsFixed(2),
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 15),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFFC4DAF6)),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total:',style: pw.TextStyle(
                            font: ttf,
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold)),
                        pw.Text('${stockReturn.totalAmount}', style: pw.TextStyle(
                            font: ttf,
                            fontSize: 14,
                            color: PdfColors.green,
                            fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 50),
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
              pw.SizedBox(height: 50),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Image(pw.MemoryImage(logoBytes), height: 150),
                      // pw.SizedBox(width: 2),
                    /*  pw.Column(
                          children: [
                            pw.Text('Powered by ', style: pw.TextStyle(font: ttf,color: PdfColor.fromInt(0xFF173C6E))),
                            pw.Text('PixiZip Solution', style: pw.TextStyle(font: ttf,color: PdfColor.fromInt(0xFF173C6E))),
                          ]
                      )*/
                    ]
                ),
              ),

            ],
          );
        },
      ),
    );

    final file = await _savePdfFile(pdf, "customer_return");

    await openPdf(file.path);
    if (share) await sharePdf(file.path);

    return file.path;
  }

  // 🔽 STOCK RETURN (no change except keeping clean)
  static Future<String> generateStockReturnPdf(UserProfile user,{
    required PurchaseReturnModel stockReturn,
    bool share = false,
  }) async {
    final pdf = pw.Document();
    final fontData = await rootBundle.load('assets/fonts/Signika-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);
    final now = DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now());

    final ByteData data = await rootBundle.load(AppImages.pdf_logo);
    final Uint8List bytes = data.buffer.asUint8List();
    final img.Image? original = img.decodeImage(bytes);
    final img.Image resized = img.copyResize(original!, width: 100);
    final Uint8List logoBytes = Uint8List.fromList(img.encodePng(resized));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(16),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // pw.Center(
              //   child: pw.Text(
              //     "STOCK RETURN",
              //     style: pw.TextStyle(
              //       font: ttf,
              //       fontSize: 20,
              //       fontWeight: pw.FontWeight.bold,
              //     ),
              //   ),
              // ),

              pw.SizedBox(height: 30),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    user.name.toUpperCase() ?? "-",
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    "Phone: ${user.phoneNumber ?? '-'}",
                    style: pw.TextStyle(font: ttf, fontSize: 12),
                  ),
                  pw.Text(
                    "Address: ${_capitalizeFirstLetter(user.address ?? '-')}",
                    style: pw.TextStyle(font: ttf, fontSize: 12),
                  ),
                ],
              ),
          pw.SizedBox(height: 10),
          pw.Divider(thickness: 1, color: PdfColors.grey),
          pw.SizedBox(height: 10),

              pw.SizedBox(height: 10),
              pw.Text( _capitalizeFirstLetter(stockReturn.sellerName ?? '-'),
                  style: pw.TextStyle(font: ttf, fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue,)),
              pw.Text("Date: $now",
                  style: pw.TextStyle(font: ttf, fontSize: 14)),
              pw.Text("Reason: ${stockReturn.reason ?? '-'}",
                  style: pw.TextStyle(font: ttf, fontSize: 14)),
              pw.SizedBox(height: 10),

              _buildTable(
                ttf: ttf,
                headers: ["Product", "Batch", "Qty", "Rate", "Total"],
                rows: stockReturn.items.map((item) {
                  final rate = double.tryParse(item.rate.toString()) ?? 0;
                  final total = rate * item.quantity;
                  return [
                    item.productName ?? '',
                    item.batchNo ?? '-',
                    item.quantity.toString(),
                    rate.toStringAsFixed(2),
                    total.toStringAsFixed(2),
                  ];
                }).toList(),
              ),

              pw.SizedBox(height: 15),
              // pw.Align(
              //   alignment: pw.Alignment.centerRight,
              //   child: pw.Text("Total: ${stockReturn.totalAmount}",
              //       style: pw.TextStyle(
              //           font: ttf,
              //           fontSize: 14,
              //           fontWeight: pw.FontWeight.bold)),
              // ),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFFC4DAF6)),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total:',style: pw.TextStyle(
                            font: ttf,
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold)),
                        pw.Text(stockReturn.totalAmount, style: pw.TextStyle(
                            font: ttf,
                            fontSize: 14,
                            color: PdfColors.green,
                            fontWeight: pw.FontWeight.bold)),
                      ],
                    ),

                  ],
                ),
              ),
              pw.SizedBox(height: 50),
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
              pw.SizedBox(height: 50),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Image(pw.MemoryImage(logoBytes),  height: 150),
                      // pw.SizedBox(width: 2),
                     /* pw.Column(
                          children: [
                            pw.Text('Powered by ', style: pw.TextStyle(font: ttf,color: PdfColor.fromInt(0xFF173C6E))),
                            pw.Text('PixiZip Solution', style: pw.TextStyle(font: ttf,color: PdfColor.fromInt(0xFF173C6E))),
                          ]
                      )*/
                    ]
                ),
              ),
            ],
          );
        },
      ),
    );

    final file = await _savePdfFile(pdf, "stock_return");

    await openPdf(file.path);
    if (share) await sharePdf(file.path);

    return file.path;
  }

  /// Helper for creating table
  static pw.Widget _buildTable({
    required pw.Font ttf,
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    return pw.Table(
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF062A49)),
          children: headers
              .map((h) => pw.Padding(
            padding: const pw.EdgeInsets.all(4),
            child: pw.Text(
              h,
              style:
              pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold,color: PdfColors.white),
            ),
          ))
              .toList(),
        ),
        ...rows.map(
              (row) => pw.TableRow(
            children: row
                .map((cell) => pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(cell,
                  style: pw.TextStyle(font: ttf, fontSize: 12)),
            ))
                .toList(),
          ),
        ),
      ],
    );
  }

  /// Save PDF
  static Future<File> _savePdfFile(pw.Document pdf, String prefix) async {
    final dir = await getTemporaryDirectory();
    final file = File(
        "${dir.path}/${prefix}_${DateTime.now().millisecondsSinceEpoch}.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static Future<void> openPdf(String path) async {
    await OpenFile.open(path);
  }

  static Future<void> sharePdf(String path) async {
    await Share.shareXFiles([XFile(path)], text: "Here is your return report");
  }
}
