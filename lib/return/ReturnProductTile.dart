import 'package:intl/intl.dart';
import 'package:pixidrugs/constant/all.dart';

class ReturnProductTile extends StatefulWidget {
  final InvoiceItem product;

  const ReturnProductTile({super.key, required this.product});

  @override
  State<ReturnProductTile> createState() => _ReturnProductTileState();
}

class _ReturnProductTileState extends State<ReturnProductTile> {
  bool isChecked = false;
  final TextEditingController _returnQtyController = TextEditingController();

  @override
  void dispose() {
    _returnQtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final DateTime now = DateTime.now();
    final expiryDate = parseFlexibleExpiry(product.expiry);

    final bool isExpired = expiryDate.isBefore(now);
    final bool isExpiringSoon =
        !isExpired && expiryDate.isBefore(now.add(const Duration(days: 120)));

    final expColor = isExpired
        ? Colors.red
        : isExpiringSoon
        ? Colors.orange
        : AppColors.kBlackColor800;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isChecked = !isChecked;
                      });
                    },
                    child: Icon(
                      size: 30,
                      isChecked ? Icons.check_box : Icons.check_box_outline_blank,
                      color: isChecked ? Colors.green : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyTextfield.textStyle_w800('${product.product}(${product.packing})',16,AppColors.kPrimary,maxLines: 1),
                        const SizedBox(height: 4),
                        MyTextfield.textStyle_w400("HSN: ${product.hsn}",14,Colors.grey),
                        MyTextfield.textStyle_w400("Batch: ${product.batch ?? '-'}",14,Colors.grey),
                        MyTextfield.textStyle_w400("Stock: ₹${product.qty}",16,Colors.deepOrangeAccent),
                        MyTextfield.textStyle_w600("Exp: ${DateFormat('dd MMM yyyy').format(parseFlexibleExpiry(product.expiry))}",16,expColor),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// ✅ RIGHT SIDE: Checkbox or ✅ icon, Sale, MRP, Return Qty
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      MyTextfield.textStyle_w400("Sale: ₹${product.rate}",14,Colors.teal),
                      MyTextfield.textStyle_w400("MRP: ₹${product.mrp}",14,Colors.amber),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 35,
                        width: 80,
                        child: MyEdittextfield(controller: _returnQtyController, hintText: 'return Qty',keyboardType: TextInputType.number),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const Divider(height: 1, thickness: 1, color: AppColors.kPrimaryLight),
            ],
          ),
        ),

      ],
    );
  }
}
DateTime parseFlexibleExpiry(String input) {
  try {
    if (input.contains('/')) {
      return parseExpiry(input); // "03/26"
    } else {
      return DateTime.parse(input); // "2027-12-31"
    }
  } catch (e) {
    throw FormatException('Unrecognized date format: $input');
  }
}
DateTime parseExpiry(String input) {
  try {
    // Parse assuming format is MM/yy
    final format = DateFormat('MM/yy');
    final date = format.parseStrict(input);

    // Fix year/month (parsed date will be 2026-03-01 by default)
    return DateTime(date.year, date.month + 1, 0); // Last day of the month
  } catch (e) {
    throw FormatException('Invalid expiry format: $input');
  }
}