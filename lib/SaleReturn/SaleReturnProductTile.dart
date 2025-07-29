import 'package:intl/intl.dart';
import 'package:PixiDrugs/constant/all.dart';

import 'BillingModel.dart';

class SaleReturnProductTile extends StatefulWidget {
  final Item product;
  final ValueChanged<bool> onChecked;
  final ValueChanged<String> onQtyChanged;
  final bool editable;

  const SaleReturnProductTile({super.key, required this.product,
    required this.onChecked, required this.onQtyChanged,required this.editable,});

  @override
  State<SaleReturnProductTile> createState() => _SaleReturnProductTileState();
}

class _SaleReturnProductTileState extends State<SaleReturnProductTile> {
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
  void didUpdateWidget(covariant SaleReturnProductTile oldWidget) {
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
                    onTap: widget.editable
                        ? () => widget.onChecked(!product.isSelected)
                        : null,
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
                        MyTextfield.textStyle_w800('${product.productName}',16,AppColors.kPrimary,maxLines: 1),
                        const SizedBox(height: 4),
                        MyTextfield.textStyle_w400("ProductId: ${product.productId}",14,Colors.grey),
                        MyTextfield.textStyle_w400("Qty: ${product.quantity}",16,Colors.teal),
                        MyTextfield.textStyle_w400("Discount: ${product.discount ?? '-'}",14,Colors.red),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// ✅ RIGHT SIDE: Checkbox or ✅ icon, Sale, MRP, Return Qty
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      MyTextfield.textStyle_w400("Price: ₹${product.price}",14,Colors.deepOrangeAccent),
                      MyTextfield.textStyle_w400("Total: ₹${product.subtotal}",16,AppColors.kPrimary),
                      const SizedBox(height: 20),
                      product.isSelected ?SizedBox(
                        height: 35,
                        width: 80,
                        child: MyEdittextfield(readOnly:!widget.editable,controller: _returnQtyController, hintText: 'StockReturn Qty',keyboardType: TextInputType.number),
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