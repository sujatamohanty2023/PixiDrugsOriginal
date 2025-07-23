import 'package:intl/intl.dart';
import 'package:PixiDrugs/constant/all.dart';

class ReturnProductTile extends StatefulWidget {
  final InvoiceItem product;
  final ValueChanged<bool> onChecked;
  final ValueChanged<String> onQtyChanged;

  const ReturnProductTile({super.key, required this.product,
  required this.onChecked, required this.onQtyChanged,});

  @override
  State<ReturnProductTile> createState() => _ReturnProductTileState();
}

class _ReturnProductTileState extends State<ReturnProductTile> {
  late final TextEditingController _returnQtyController;

  @override
  void initState() {
    super.initState();
    _returnQtyController = TextEditingController(
      text: widget.product.returnQty > 0 ? widget.product.returnQty.toString() : '',
    );

    _returnQtyController.addListener(() {
      widget.onQtyChanged(_returnQtyController.text);
    });
  }

  @override
  void didUpdateWidget(covariant ReturnProductTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Sync controller if model is updated externally
    final currentText = _returnQtyController.text;
    final modelQtyText = widget.product.returnQty.toString();

    if (currentText != modelQtyText && widget.product.isSelected) {
      _returnQtyController.text = modelQtyText;
      _returnQtyController.selection = TextSelection.collapsed(offset: modelQtyText.length);
    }
  }

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

    _returnQtyController.text=product.returnQty.toString();

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
                    onTap: () => widget.onChecked(!product.isSelected),
                    child: Icon(
                      size: 30,
                      product.isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                      color: product.isSelected ? Colors.green : Colors.grey,
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
                      product.isSelected ?SizedBox(
                        height: 35,
                        width: 80,
                        child: MyEdittextfield(controller: _returnQtyController, hintText: 'return Qty',keyboardType: TextInputType.number),
                      ):SizedBox(),
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