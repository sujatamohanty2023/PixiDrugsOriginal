
enum DiscountType { flat, percent }
class Invoice {
  String? invoiceId;
   String? invoiceDate;
  String? sellerId;
   String? sellerName;
   String? sellerGstin;
   String? sellerAddress;
   String? sellerPhone;
   String? userId;
   String? netAmount;
   List<InvoiceItem> items;

  Invoice({
    this.invoiceId='',
    this.invoiceDate='',
    this.sellerId='',
    this.sellerName='',
    this.sellerGstin='',
    this.sellerAddress='',
    this.sellerPhone='',
    this.userId='',
    this.netAmount='',
    this.items = const [],
  });
  Invoice copyWith({
    String? invoiceId,
    String? invoiceDate,
    String? sellerId,
    String? sellerName,
    String? sellerGstin,
    String? sellerAddress,
    String? sellerPhone,
    String? userId,
    String? netAmount,
    List<InvoiceItem>? items,
  }) {
    return Invoice(
      invoiceId: invoiceId ?? this.invoiceId,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerGstin: sellerGstin ?? this.sellerGstin,
      sellerAddress: sellerAddress ?? this.sellerAddress,
      sellerPhone: sellerPhone ?? this.sellerPhone,
      userId: userId ?? this.userId,
      netAmount: netAmount ?? this.netAmount,
      items: items ?? this.items,
    );
  }
  factory Invoice.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List? ?? [];
    final gstRaw = json['gst_no']?.toString().trim() ?? '';
    return Invoice(
      invoiceId: json['invoice_no']??'',
      invoiceDate: json['invoice_date']??'',
      sellerName: json['seller_name']??'',
      sellerGstin: gstRaw.length > 15 ? gstRaw.substring(0, 15) : gstRaw,
      sellerAddress: json['address']??'',
      sellerPhone: json['phone']??'',
      netAmount: json['net_amount']??'',
      userId: json['user_id']??'',
      items: itemsJson.map((e) => InvoiceItem.fromJson(e)).toList(),
    );
  }
  factory Invoice.fromJson_StockReturn(Map<String, dynamic> json) {
    final seller = json['seller'] ?? {};
    final itemsJson = json['items'] as List? ?? [];

    return Invoice(
      invoiceId: json['invoice_no'] ?? '',
      invoiceDate: json['invoice_date'] ?? '',
      sellerName: seller['name'] ?? '--------',
      sellerAddress: seller['address'] ?? '',
      sellerPhone: seller['mobile'] ?? '',
      sellerId: seller['id'].toString() ?? '',
      items: itemsJson.map((e) => InvoiceItem.fromJson(e)).toList(),
    );
  }
  Map<String, dynamic> toJson() => {
    'invoice_no': invoiceId,
    'invoice_date': invoiceDate,
    'seller_name': sellerName,
    'address': sellerAddress,
    'phone': sellerPhone,
    'gst_no': sellerGstin,
    'user_id': userId,
    'net_amount': netAmount,
    'items': items.map((e) => e.toJson()).toList(),
  };
  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('invoice_no   : $invoiceId');
    buffer.writeln('invoice_date         : $invoiceDate');
    buffer.writeln('Seller Name  : $sellerName');
    buffer.writeln('Seller GSTIN : $sellerGstin');
    buffer.writeln('Items:');
    for (var item in items) {
      buffer.writeln(item.toString());
    }
    return buffer.toString();
  }
}
class InvoiceItem {
    int? id;
   String hsn;
   String product;
   String? composition;
   String packing;
   String batch;
   String mrp;
   String rate;
   String taxable;
   String discount;
    String? discountSale;
   String expiry;
   int qty;
   int qty_free;
   String gst;
   String total;
   DiscountType discountType;

   int invoice_purchase_id;
   bool isSelected;
    int returnQty;

    InvoiceItem({
    this.id,
    this.hsn='',
    this.product='',
    this.composition,
    this.packing='',
    this.batch='',
    this.mrp='',
    this.rate='',
    this.taxable='',
    this.discount='0',
    this.discountSale,
    this.expiry='',
    this.qty=0,
    this.qty_free=0,
    this.gst='',
    this.total='',
    this.discountType=DiscountType.percent,
    this.isSelected = false,
    this.returnQty = 0,
    this.invoice_purchase_id = 0,
  });
   InvoiceItem copyWith({
     int? id,
     String? hsn,
     String? product,
     String? composition,
     String? packing,
     String? batch,
     String? mrp,
     String? rate,
     String? taxable,
     String? discount,
     String? discountSale,
     String? expiry,
     int? qty,
     int? qty_free,
     String? gst,
     String? total,
     DiscountType? discountType,
     bool? isSelected,
    int? returnQty,
    int? invoice_purchase_id,
   }) {
     return InvoiceItem(
       id: id ?? this.id,
       hsn: hsn ?? this.hsn,
       product: product ?? this.product,
       composition: composition ?? this.composition,
       packing: packing ?? this.packing,
       batch: batch ?? this.batch,
       mrp: mrp ?? this.mrp,
       rate: rate ?? this.rate,
       taxable: taxable ?? this.taxable,
       discount: discount ?? this.discount,
       discountSale: discountSale ?? this.discountSale,
       expiry: expiry ?? this.expiry,
       qty: qty ?? this.qty,
       qty_free: qty_free ?? this.qty_free,
       gst: gst ?? this.gst,
       total: total ?? this.total,
       discountType: discountType??this.discountType,
       returnQty: returnQty??this.returnQty,
       invoice_purchase_id: invoice_purchase_id??this.invoice_purchase_id,
     );
   }


   /// Normalize all JSON keys to lowercase and trim spaces to avoid key mismatches
  static Map<String, String> normalizeJsonKeys(Map<String, dynamic> json) {
    return json.map((key, value) {
      final k = key.toLowerCase().trim();
      final v = value == null ? '' : value.toString().trim();
      return MapEntry(k, v);
    });
  }

  /// Parse quantity considering possible "1+1" or "2" formats
  static int parseQty(String? qtyStr) {
    if (qtyStr == null) return 0;
    qtyStr = qtyStr.trim();
    if (qtyStr.contains('+')) {
      var parts = qtyStr.split('+').map((e) => e.trim()).toList();
      if (parts.isNotEmpty) {
        return int.tryParse(parts[0]) ?? 0;
      }
    }
    return int.tryParse(qtyStr) ?? 0;
  }

  /// Parse free quantity from string like "1+1"
  static int parseQtyFree(String? qtyStr) {
    if (qtyStr == null) return 0;
    qtyStr = qtyStr.trim();
    if (qtyStr.contains('+')) {
      var parts = qtyStr.split('+').map((e) => e.trim()).toList();
      if (parts.length > 1) {
        return int.tryParse(parts[1]) ?? 0;
      }
    }
    return 0;
  }

    static int? parseId(String? id) {
      if (id == null || id.trim().isEmpty) return null;
      return int.tryParse(id);
    }
    static String? parseNullString(String? composition) {
      if (composition == null || composition.trim().isEmpty) return null;
      return composition;
    }

  /// Parse last valid double number from messy string input (handles commas, newlines)
  static double parseNumberFromString(String? input) {
    if (input == null || input.trim().isEmpty) return 0.0;

    // Replace commas with dots for decimal if used as decimal separator
    var cleaned = input.replaceAll(',', '.').replaceAll('\n', ' ').trim();

    // Regex to find all numbers with decimals (e.g. 1234.56)
    final numberRegExp = RegExp(r'\d+(\.\d+)?');

    final matches = numberRegExp.allMatches(cleaned);
    if (matches.isEmpty) return 0.0;

    // Use last number found, assuming it's the correct one (handles cases like "0,00\n7006.44")
    final lastMatch = matches.last.group(0);
    return double.tryParse(lastMatch ?? '') ?? 0.0;
  }

  /// Parse combined GST percentages, sums multiple if needed
  static double parseCombinedGst(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 0.0;

    // Replace newlines with space, split by non-numeric/non-dot chars, filter empty
    final parts = raw
        .replaceAll('\n', ' ')
        .split(RegExp(r'[^0-9.]'))
        .where((e) => e.trim().isNotEmpty);

    if (parts.isEmpty) return 0.0;

    // Sum all parsed double GST parts
    return parts.map((e) => double.tryParse(e) ?? 0.0).fold(0.0, (a, b) => a + b);
  }

  /// Parse total amount as string, try multiple possible keys
  static String parseTotal(Map<String, String> normalized) {
    List<String> keys = [
      'total',
      'amount',
      'net amount',
      'netamt.',
      'net amt.',
      'line_total',
      'net amt',
      'net amount'
    ];
    for (var key in keys) {
      if (normalized.containsKey(key)) {
        final val = normalized[key];
        final parsedVal = parseNumberFromString(val);
        if (parsedVal > 0) {
          return parsedVal.toStringAsFixed(2);
        }
      }
    }
    return '0.00';
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    final normalized = normalizeJsonKeys(json);

    final rawGstString = normalized['gst'] ??
        normalized['gst_rate'] ??
        normalized['tax'] ??
        normalized['tax_rate'] ??
        normalized['% gst'] ??
        normalized['%'] ??
        '';

    final gstValue = parseCombinedGst(rawGstString);

    final mrpValue = parseNumberFromString(normalized['mrp']??
        normalized['mrp'] ??normalized['MRP'] ?? normalized['maximum_retail_price']);
    final rateValue =
    parseNumberFromString(normalized['rate'] ?? normalized['price'] ?? normalized['unit price']??normalized['unit_price']);
    final taxableValue = parseNumberFromString(normalized['taxable']??normalized['Taxable']);
    final discountValue =
    parseNumberFromString(normalized['disc.'] ??normalized['Disc.'] ?? normalized['dis'] ?? normalized['discount']);

    final qtyRaw = normalized['quantity'] ?? normalized['qty'] ?? '0';
    final qty = parseQty(qtyRaw);
    final qtyFree = parseQtyFree(qtyRaw);

    return InvoiceItem(
      id: parseId(normalized['id']),
      hsn: normalized['Product_Code']??normalized['hsn_code'] ?? normalized['hsn']?? normalized['HSN'] ?? normalized['Product Code']??'',
      product: normalized['product name'] ??
          normalized['product Name'] ??
          normalized['product_name']??
          normalized['item'] ??
          normalized['description'] ??
          normalized['product'] ??
          normalized['drugname'] ??
          normalized['name'] ??
          '',
      composition: parseNullString(normalized['composition']),
      packing: normalized['pack'] ?? normalized['package'] ?? normalized['packing'] ?? '',
      batch:normalized['Batch No']?? normalized['batch no'] ??normalized['batch_no'] ?? normalized['batch'] ?? normalized['batch number'] ?? '',
      mrp: mrpValue.toStringAsFixed(2),
      rate: rateValue.toStringAsFixed(2),
      taxable: taxableValue.toStringAsFixed(2),
      discount: discountValue.toString(),
      discountSale: parseNullString(normalized['discountSale']),
      expiry: normalized['expiry date'] ??
          normalized['expiry'] ??
          normalized['exp'] ??
          normalized['exp.'] ??
          normalized['ex.dt'] ??
          normalized['Ex.Dt'] ??
          '',
      qty: qty,
      qty_free: qtyFree,
      gst: gstValue.toStringAsFixed(2),
      total: parseNullString(normalized['TOTAL']?? normalized['total']?? normalized['Amount']?? normalized['amount']
          ?? normalized['Net Amount']?? normalized['net amount'])??'',
      //total:parseTotal(normalized),
      invoice_purchase_id: parseId(normalized['invoice_purchase_id'])??0,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'hsn': hsn,
    'product': product,
    if (composition != null) 'composition': composition,
    'packing': packing,
    'batch_no': batch,
    'mrp': mrp,
    'rate': rate,
    'taxable': taxable,
    'discount': discount,
    if (discountSale != null) 'discountSale': discountSale,
    'expiry': expiry,
    'quantity': qty,
    'qty_free': qty_free,
    'gst': gst,
    'total': total,
  };

  @override
  String toString() {
    return 'InvoiceItem(id:$id,hsn: $hsn, product: $product, composition:$composition,packing: $packing, batch_no: $batch, mrp: $mrp, rate: $rate, taxable: $taxable, discount: $discount,discountSale: $discountSale, expiry: $expiry, quantity: $qty, qty_free: $qty_free, gst: $gst, total: $total)';
  }
}


