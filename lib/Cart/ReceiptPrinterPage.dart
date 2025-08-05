import 'package:flutter/services.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:PixiDrugs/Home/HomePageScreen.dart';
import 'package:PixiDrugs/SaleList/sale_model.dart';
import 'package:PixiDrugs/constant/all.dart';
import 'package:image/image.dart' as img;
import 'package:network_info_plus/network_info_plus.dart';

class ReceiptPrinterPage extends StatefulWidget {

  final ScrollController? scrollController;
  SaleModel sale;
  ReceiptPrinterPage({Key? key,required this.sale,this.scrollController}) : super(key: key);

  @override
  State<ReceiptPrinterPage> createState() => _ReceiptPrinterPageState();
}

class _ReceiptPrinterPageState extends State<ReceiptPrinterPage> {
  late SaleModel products;
  String? name, phone, address;
  double totalItemAmount = 0;
  double totalDiscount = 0;
  double totalAmount = 0;
  String printerIp = '192.168.1.251';
  List<String> _foundPrinters = [];

  Future<void> savePrinterIp(String ip) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('printer_ip', ip);
  }

  Future<String?> getPrinterIp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('printer_ip');
  }

  @override
  void initState() {
    super.initState();
    products=widget.sale;
    name=products.customer.name;
    phone=products.customer.phone;
    address=products.customer.address;

    totalItemAmount=calculateItemTotal(products.items);
    totalDiscount=calculateTotalDiscount(products.items);
    totalAmount=totalItemAmount - totalDiscount;

    getPrinterIp().then((value) {
      if (value != null) {
        setState(() {
          printerIp = value;
        });
      }else{
        _manualScan();
      }
    });
  }
  double calculateItemTotal(List<SaleItem> items) {
    double totalOriginal= 0;
    for (var item in items) {
      final price = item.price ?? 0;
      final qty = item.quantity;

      double original = price * qty;

      totalOriginal += original;
    }
    return totalOriginal;
  }
  double calculateSubtotal(SaleItem item) {
    final mrp = item.price ?? 0;
    final qty = item.quantity;
    final discount = item.discount ?? 0;

    double subtotal = mrp * qty;

    subtotal -= subtotal * discount / 100;

    return subtotal;
  }
  double calculateTotalDiscount(List<SaleItem> items) {
    double totalDiscount = 0;
    for (var item in items) {
      final price = item.price ?? 0;
      final qty = item.quantity;
      final discount = item.discount ?? 0;

      double original = price * qty;
      double discounted = original * discount / 100;

      totalDiscount += discounted;
    }
    return totalDiscount;
  }

  Future<img.Image> loadLogoImage() async {
    final ByteData data = await rootBundle.load(AppImages.AppIcon);
    final Uint8List bytes = data.buffer.asUint8List();

    final img.Image original = img.decodeImage(bytes)!;

    // Resize and convert to grayscale (optional but good for thermal printers)
    final img.Image resized = img.copyResize(original, width: 384); // for 58mm printers
    final img.Image grayscale = img.grayscale(resized);

    return grayscale;
  }

  void _showManualEntryIPAddress() {
    showDialog(
      context: context,
      builder: (_) => EditValueDialog(
          title: 'IP Address',
          initialValue: printerIp,
         onSave: (value) {
            setState(() {
              printerIp=value;
            });
            savePrinterIp(value);
          },
      ),
    );
  }
  Future<void> _manualScan() async {
    setState(() {
      _foundPrinters.clear();
    });

    final info = NetworkInfo();
    String? ip = await info.getWifiIP();
    String? subnet = ip?.substring(0, ip.lastIndexOf('.'));

    const port = 9100;
    List<String> activeIps = [];

    for (int i = 1; i <= 254; i++) {
      String host = '$subnet.$i';
      try {
        final socket = await Socket.connect(host, port, timeout: Duration(milliseconds: 300));
        socket.destroy();
        activeIps.add(host);
      } catch (_) {}
    }

    setState(() {
      _foundPrinters = activeIps;
      printerIp=_foundPrinters.first.toString();
      savePrinterIp(printerIp);
    });
  }
  Future<void> _printBill(BuildContext context) async {
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(PaperSize.mm80, profile);
    const int port = 9100;

    final PosPrintResult res = await printer.connect(printerIp, port: port);

    if (res == PosPrintResult.success) {
      final boldStyle = PosStyles(bold: true, align: PosAlign.center);
      final normalStyle = PosStyles(align: PosAlign.left);

      final logoImage = await loadLogoImage();
      // Print logo
      printer.image(logoImage); // Use align: PosAlign.center if needed
      //printer.feed(1);
      printer.setStyles(boldStyle);
      printer.text('PixiDrugs');
      printer.setStyles(normalStyle);
      printer.text('Ph: 123456789');
      printer.text('Address: Berhampur');
      printer.feed(1);
      printer.hr();

      printer.text('Bill No: #${products.invoiceNo}');
      printer.text('Date: ${products.date}');
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

      printer.hr();
      double totalCalc = 0;
      for (var item in products.items) {
        double subtotal = calculateSubtotal(item);
        totalCalc += subtotal;

        printer.row([
          PosColumn(text: item.productName, width: 4),
          PosColumn(text: '${item.quantity}', width: 2, styles: PosStyles(align: PosAlign.center)),
          PosColumn(text: '${item.price}', width: 2, styles: PosStyles(align: PosAlign.center)),
          PosColumn(
              text: '${item.discount}%',
              width: 2,
              styles: PosStyles(align: PosAlign.center)),
          PosColumn(text: '${subtotal.toStringAsFixed(2)}', width: 2, styles: PosStyles(align: PosAlign.right)),
        ]);
      }
      printer.hr();
      printer.text('Subtotal: ${totalItemAmount.toStringAsFixed(2)}', styles: PosStyles(align: PosAlign.right));
      printer.text('Discount: -${totalDiscount.toStringAsFixed(2)}', styles: PosStyles(align: PosAlign.right));
      printer.hr();
      printer.text('Total: ${totalAmount.toStringAsFixed(2)}', styles: PosStyles(bold: true, align: PosAlign.right));
      printer.feed(2);
      printer.text('Thank You!', styles: boldStyle);
      printer.text('PixiDrugs by PixiZip', styles: boldStyle);
      printer.feed(1);

      printer.cut();
      printer.disconnect();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Print Success: $res')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Print Failed: $res.Please Check your IP Address.')));
    }
    AppRoutes.navigateTo(context, HomePage());
    context.read<CartCubit>().clearCart(type: CartType.barcode);
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyles.bg_radius_50_decoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    MyTextfield.textStyle_w600("Print Details", AppUtils.size_16, Colors.black),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyTextfield.textStyle_w600('', 16,AppColors.kBlackColor900),
                        GestureDetector(
                          onTap: _showManualEntryIPAddress,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AppColors.myGradient,
                              borderRadius:BorderRadius.circular(5),
                              border: Border.all(color: AppColors.kPrimary)
                            ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: MyTextfield.textStyle_w600("Find IP Address", AppUtils.size_14, AppColors.kPrimary),
                              )),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyTextfield.textStyle_w600('PixiDrugs', 16,AppColors.kBlackColor900),
                        MyTextfield.textStyle_w400('GSTIN: 1234567890', 16,AppColors.kBlackColor900),
                        MyTextfield.textStyle_w400('Ph: 123456789', 16,AppColors.kBlackColor900),
                        MyTextfield.textStyle_w400('Address: Berhampur,Odisha', 16,AppColors.kBlackColor900),
                        const Divider(),

                        MyTextfield.textStyle_w400('Bill No: #${products.invoiceNo}', 16,AppColors.kBlackColor900),
                        MyTextfield.textStyle_w400('Date: ${products.date}', 16,AppColors.kBlackColor900),
                        MyTextfield.textStyle_w400('Customer: $name', 16,AppColors.kBlackColor900),
                        MyTextfield.textStyle_w400('Phone: $phone', 16,AppColors.kBlackColor900),
                        MyTextfield.textStyle_w400('Address: $address', 16,AppColors.kBlackColor900),
                        const Divider(),
                        const SizedBox(height: 8),
                      ],
                    ),



                // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(flex: 2, child: MyTextfield.textStyle_w600('Item', 18,Colors.black)),
                        Expanded(flex: 1, child: MyTextfield.textStyle_w600('Qty',18,Colors.black)),
                        Expanded(flex: 1, child: MyTextfield.textStyle_w600('MRP',18,Colors.black)),
                        Expanded(flex: 1, child: MyTextfield.textStyle_w600('Disc',18,Colors.black)),
                        Expanded(flex: 1, child: MyTextfield.textStyle_w600('Total', 18,Colors.black)),
                      ],
                    ),
                    const Divider(),

                    ...products.items.map((item) {
                      final subtotal = calculateSubtotal(item);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(flex: 2, child: MyTextfield.textStyle_w300(item.productName,16,AppColors.kBlackColor800)),
                            Expanded(flex: 1, child: MyTextfield.textStyle_w300('x${item.quantity}',16,AppColors.kBlackColor800)),
                            Expanded(flex: 1, child: MyTextfield.textStyle_w300('₹${item.price}', 16,AppColors.kBlackColor800)),
                            Expanded(flex: 1, child: MyTextfield.textStyle_w300('${item.discount}%', 16,AppColors.kBlackColor800)),
                            Expanded(flex: 1, child: MyTextfield.textStyle_w300('₹${subtotal.toStringAsFixed(2)}', 16,AppColors.kBlackColor800)),

                          ],
                        ),
                      );
                    }).toList(),

                    const Divider(),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: MyTextfield.textStyle_w400('SubTotal: ₹${calculateItemTotal(products.items).toStringAsFixed(2)}',16,Colors.black),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: MyTextfield.textStyle_w400('Total Discount: -₹${calculateTotalDiscount(products.items).toStringAsFixed(2)}',16,Colors.black),
                    ),
                    const Divider(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: MyTextfield.textStyle_w400('Total: ₹${totalAmount.toStringAsFixed(2)}',18,Colors.black),
                    ),
                    const SizedBox(height: 20),
                    Center(child: MyTextfield.textStyle_w400('PixiDrugs by PixiZip 🙏',20,AppColors.kPrimary),),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 16,
              right: 16,
              top: 10,
            ),
            child: MyElevatedButton(
              buttonText: 'Print Receipt',
              onPressed: () => _printBill(context),
            ),
          ),
        ],
      ),
    );
  }
}
