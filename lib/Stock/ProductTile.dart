import 'package:intl/intl.dart';
import 'package:pixidrugs/constant/all.dart';

class ProductTile extends StatelessWidget {
  InvoiceItem? product;

  ProductTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = product!.qty <= 0;
    final DateTime now = DateTime.now();
    final expiryDate = parseFlexibleExpiry(product!.expiry);

    final bool isExpired = expiryDate.isBefore(now);
    final bool isExpiringSoon =
        !isExpired && expiryDate.isBefore(now.add(const Duration(days: 120)));

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Removed the CircleAvatar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child:MyTextfield.textStyle_w600(product!.product, SizeConfig.screenWidth! * 0.045, AppColors.kPrimary)
                    ),
                    RichText(
                      text: TextSpan(
                        style: MyTextfield.textStyle(13, Colors.black, FontWeight.w300),
                        children: [
                          const TextSpan(text: 'Sale: '),
                          TextSpan(
                            text: '₹${product!.rate}',
                            style: MyTextfield.textStyle(14, Colors.teal, FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: MyTextfield.textStyle(13, Colors.black, FontWeight.w300),
                          children: [
                            const TextSpan(text: 'HSN: '),
                            TextSpan(
                              text: '${product!.hsn}',
                              style: MyTextfield.textStyle(13, Colors.black54, FontWeight.w300),
                            ),
                          ],
                        ),
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        style: MyTextfield.textStyle(13, Colors.black, FontWeight.w300),
                        children: [
                          const TextSpan(text: 'Purchase: '),
                          TextSpan(
                            text:
                            '₹${product!.mrp}',
                            style: MyTextfield.textStyle(14, Colors.deepOrange, FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6,),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyTextfield.textStyle_w400(isOutOfStock
                      ? "Out of Stock"
                              : "Stock: ${product!.qty}",16, isOutOfStock ? Colors.red : Colors.teal),
                          SizedBox(height: 2,),
                          if (!isOutOfStock)
                            MyTextfield.textStyle_w400(
                              "Ex. Date: ${DateFormat('dd MMM yyyy').format(parseFlexibleExpiry(product!.expiry))}",14,Colors.grey.shade700
                            ),
                        ],
                      ),
                    ),

                    if (isOutOfStock)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          // border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: MyTextfield.textStyle_w600(
                          "Out of Stock",16,Colors.white
                        ),
                      )
                    else if (isExpired)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          // border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: MyTextfield.textStyle_w400("Expired",16,Colors.white),
                      )
                    else if (isExpiringSoon)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            // border: Border.all(color: Colors.orange),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child:MyTextfield.textStyle_w400("Expiring Soon",16,Colors.white)
                        ),
                  ],
                ),
                const Divider(color: AppColors.kPrimaryDark),
              ],
            ),
          ),
        ],
      ),
    );
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

}