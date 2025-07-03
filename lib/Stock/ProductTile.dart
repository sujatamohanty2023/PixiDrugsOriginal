import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pixidrugs/constant/all.dart';
import 'package:pixidrugs/constant/color.dart';
import 'package:pixidrugs/invoiceDataExtraction/InvoiceModel.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
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
                      child: Text(
                        product!.product,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 14, color: Colors.black),
                        children: [
                          const TextSpan(text: 'Sale: '),
                          TextSpan(
                            text: '₹${product!.rate}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
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
                      child: Text(
                        "Code: ${product!.hsn
                        }",
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87),
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 13, color: Colors.black),
                        children: [
                          const TextSpan(text: 'Purchase: '),
                          TextSpan(
                            text:
                            '₹${product!.mrp}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isOutOfStock
                                ? "Out of Stock"
                                : "Stock: ${product!.qty}",
                            style: TextStyle(
                              color: isOutOfStock ? Colors.red : Colors.teal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2,),
                          if (!isOutOfStock)
                            Text(
                              "Ex. Date: ${DateFormat('dd MMM yyyy').format(parseFlexibleExpiry(product!.expiry))}",
                              style: TextStyle(fontSize: 13),
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
                        child: const Text(
                          "Out of Stock",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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
                        child: const Text(
                          "Expired",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else if (isExpiringSoon)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            // border: Border.all(color: Colors.orange),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "Expiring Soon",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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