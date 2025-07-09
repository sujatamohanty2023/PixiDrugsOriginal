import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:image/image.dart';
import 'package:pixidrugs/constant/all.dart';
import 'package:image/image.dart' as img;

class ReceiptPrinterPage extends StatefulWidget {
  const ReceiptPrinterPage({Key? key}) : super(key: key);

  @override
  State<ReceiptPrinterPage> createState() => _ReceiptPrinterPageState();
}

class _ReceiptPrinterPageState extends State<ReceiptPrinterPage> {
  List<InvoiceItem> products = [];
  String? name, phone, address;
  double totalAmount = 0;

  @override
  void initState() {
    super.initState();
  }

  double calculateSubtotal(InvoiceItem item) {
    final mrp = double.tryParse(item.mrp) ?? 0;
    final qty = item.qty;
    final discount = double.tryParse(item.discount) ?? 0;

    double subtotal = mrp * qty;

    if (item.discountType == DiscountType.percent) {
      subtotal -= subtotal * discount / 100;
    } else if (item.discountType == DiscountType.flat) {
      subtotal -= discount;
    }

    return subtotal;
  }
  Future<img.Image> loadLogoImage() async {
    final ByteData data = await rootBundle.load('assets/images/splash.jpg');
    final Uint8List bytes = data.buffer.asUint8List();

    final img.Image original = img.decodeImage(bytes)!;

    // Resize and convert to grayscale (optional but good for thermal printers)
    final img.Image resized = img.copyResize(original, width: 384); // for 58mm printers
    final img.Image grayscale = img.grayscale(resized);

    return grayscale;
  }
  Future<void> _printBill(BuildContext context) async {
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(PaperSize.mm80, profile);

    const String printerIp = '192.168.1.251';
    const int port = 9100;

    final PosPrintResult res = await printer.connect(printerIp, port: port);

    if (res == PosPrintResult.success) {
      final boldStyle = PosStyles(bold: true, align: PosAlign.center);
      final normalStyle = PosStyles(align: PosAlign.left);

      final logoImage = await loadLogoImage();
      // Print logo
      printer.image(logoImage); // Use align: PosAlign.center if needed
      printer.feed(1);

      printer.setStyles(boldStyle);
      printer.text('PixiDrugs');
      printer.setStyles(normalStyle);
      printer.text('Ph: 123456789');
      printer.text('Address: Berhampur');
      printer.feed(1);
      printer.hr();

      printer.text('Bill No: 123');
      printer.text('Date: ${DateTime.now()}');
      printer.text('Customer: $name');
      printer.text('Ph: $phone');
      printer.text('Address: $address');
      printer.hr();

      printer.row([
        PosColumn(text: 'Item', width: 4),
        PosColumn(text: 'Qty', width: 2, styles: PosStyles(align: PosAlign.center)),
        PosColumn(text: 'MRP', width: 2, styles: PosStyles(align: PosAlign.center)),
        PosColumn(text: 'Disc', width: 2, styles: PosStyles(align: PosAlign.center)),
        PosColumn(text: 'Total', width: 2, styles: PosStyles(align: PosAlign.right)),
      ]);

      double totalCalc = 0;
      for (var item in products) {
        double subtotal = calculateSubtotal(item);
        totalCalc += subtotal;

        printer.row([
          PosColumn(text: item.product, width: 4),
          PosColumn(text: '${item.qty}', width: 2, styles: PosStyles(align: PosAlign.center)),
          PosColumn(text: '${item.mrp}', width: 2, styles: PosStyles(align: PosAlign.center)),
          PosColumn(
              text: '${item.discount}',
              width: 2,
              styles: PosStyles(align: PosAlign.center)),
          PosColumn(text: '${subtotal.toStringAsFixed(2)}', width: 2, styles: PosStyles(align: PosAlign.right)),
        ]);
      }

      printer.hr();
      printer.text('Total: ${totalCalc.toStringAsFixed(2)}', styles: PosStyles(bold: true, align: PosAlign.right));
      printer.feed(2);
      printer.text('Thank You!', styles: boldStyle);
      printer.text('PixiDrugs by PixiZip', styles: boldStyle);
      printer.feed(1);

      printer.cut();
      printer.disconnect();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Print Success: $res')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Print Failed: $res')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (state is CartLoaded) {
          products.clear();
          products.addAll(state.barcodeCartItems);
          name = state.customerName;
          phone = state.customerPhone;
          address = state.customerAddress;

          totalAmount = 0;
          for (var item in products) {
            totalAmount += calculateSubtotal(item);
          }

          return Scaffold(
            appBar: AppBar(title: const Text('Receipt Preview')),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Center(child: Text('PixiDrugs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 4),
                  Text('GSTIN: 1234567'),
                  Text('Ph: 123456789'),
                  const Divider(),

                  Text('Bill No: 123'),
                  Text('Date: ${DateTime.now()}'),
                  Text('Customer: $name'),
                  Text('Phone: $phone'),
                  Text('Address: $address'),
                  const Divider(),

                  Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

// Header Row
                  Row(
                    children: const [
                      Expanded(flex: 4, child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('MRP', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('Disc', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 3, child: Text('Total', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                  const Divider(),

                  ...products.map((item) {
                    final subtotal = calculateSubtotal(item);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(flex: 4, child: Text(item.product)),
                          Expanded(flex: 2, child: Text('x${item.qty}', textAlign: TextAlign.center)),
                          Expanded(flex: 2, child: Text('₹${item.mrp}', textAlign: TextAlign.center)),
                          Expanded(
                            flex: 2,
                            child: Text(
                              item.discountType == DiscountType.percent
                                  ? '${item.discount}%'
                                  : '₹${item.discount}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text('₹${subtotal.toStringAsFixed(2)}', textAlign: TextAlign.right),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  const Divider(),


                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('Total: ₹${totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(height: 20),
                  Center(child: Text('PixiDrugs by PixiZip 🙏', style: const TextStyle(fontWeight: FontWeight.w500))),

                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _printBill(context),
                      child: const Text('Print Receipt'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator(color: AppColors.kPrimary));
      },
    );
  }
}
