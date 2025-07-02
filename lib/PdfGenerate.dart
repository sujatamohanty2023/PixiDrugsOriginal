import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:pixidrugs/constant/all.dart';

class ReceiptPrinterPage extends StatelessWidget {
  final List<InvoiceItem> products;
  int totalAmount=0;
  ReceiptPrinterPage({
    Key? key,
    required this.products,
  }) : super(key: key);

  Future<void> testPrint() async {
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(PaperSize.mm58, profile);
    final res = await printer.connect('192.168.1.251', port: 9100);

    if (res == PosPrintResult.success) {
      printer.text('Test Print');
      printer.cut();
      printer.disconnect();
    }

    print('Test result: ${res.msg}');
  }
  Future<void> _printBill(BuildContext context) async {
    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(PaperSize.mm58, profile);

    const String printerIp = '192.168.1.251';
    const int port = 9100;

    final PosPrintResult res = await printer.connect(printerIp, port: port);

    if (res == PosPrintResult.success) {
      final PosStyles boldStyle = PosStyles(bold: true, align: PosAlign.center);
      final PosStyles normalStyle = PosStyles(align: PosAlign.left);

      printer.setStyles(boldStyle);
      printer.text('PixiDrugs');
      printer.setStyles(normalStyle);
      printer.text('GSTIN: 123456789');
      printer.text('Ph: 1234567890');
      printer.feed(1);
      printer.hr();

      printer.text('Bill No: 123');
      printer.text('Date: ${DateTime.now()}');
      printer.text('Customer: Pradeep');
      printer.hr();

      printer.text('Items:', styles: PosStyles(bold: true));
      printer.row([
        PosColumn(text: 'Item', width: 6),
        PosColumn(
            text: 'Qty', width: 2, styles: PosStyles(align: PosAlign.center)),
        PosColumn(
            text: 'MRP', width: 2, styles: PosStyles(align: PosAlign.center)),
        PosColumn(
            text: 'Total', width: 2, styles: PosStyles(align: PosAlign.right)),
      ]);

      for (var item in products) {
        printer.row([
          PosColumn(text: item.product, width: 6),
          PosColumn(text: '${item.qty}',
              width: 2,
              styles: PosStyles(align: PosAlign.center)),
          PosColumn(text: '${item.mrp}',
              width: 2,
              styles: PosStyles(align: PosAlign.center)),
          PosColumn(text: '${item.total}',
              width: 2,
              styles: PosStyles(align: PosAlign.right)),
        ]);
        totalAmount=totalAmount+(int.parse(item.mrp) * item.qty);
      }

      printer.hr();
      printer.feed(1);

      printer.hr();
      printer.text('Total: ₹$totalAmount',
          styles: PosStyles(bold: true, align: PosAlign.right));
      printer.feed(2);
      printer.text('Thank You!', styles: boldStyle);
      printer.feed(3);

      printer.cut();
      printer.disconnect();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Print Success: $res')));
    }else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Print Failed: $res')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Receipt Preview')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('PixiDrugs', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('GSTIN: 1234567'),
            Text('Ph: 123456789'),
            Divider(),

            Text('Bill No: 12345'),
            Text('Date: ${DateTime.now()}'),
            Text('Customer: Pixi'),
            Divider(),

            Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...products.map((e) => Text('${e.product} x${e.qty} - ₹${e.total}')),
            Divider(),

            Text('*** BILL RECEIPT ***', style: TextStyle(fontWeight: FontWeight.bold)),
            ...products.map((e) => Text('${e.product} x${e.qty} - ₹${e.mrp}')),
            Divider(),

            Align(
              alignment: Alignment.centerRight,
              child: Text('Total: ₹$totalAmount', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: Text('Pixidrougs by Pixizip 🙏', style: TextStyle(fontWeight: FontWeight.bold)),
            ),

            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => testPrint(),
                child: Text('Print'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}