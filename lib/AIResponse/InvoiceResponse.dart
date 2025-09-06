// ✅ Helper for safe double parsing
double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

class InvoiceData {
  final String? fileName;
  final int pageNumber;
  final InvoiceAi invoice;
  final Seller seller;
  final Buyer buyer;
  final List<Item> item;

  InvoiceData({
    this.fileName,
    required this.pageNumber,
    required this.invoice,
    required this.seller,
    required this.buyer,
    required this.item,
  });

  factory InvoiceData.fromJson(Map<String, dynamic> json) {
    return InvoiceData(
      fileName: json['file_name'],
      pageNumber: json['page_number'] ?? 0,
      invoice: InvoiceAi.fromJson(json['invoice'] ?? {}),
      seller: Seller.fromJson(json['seller'] ?? {}),
      buyer: Buyer.fromJson(json['buyer'] ?? {}),
      item: (json['item'] as List<dynamic>? ?? [])
          .map((x) => Item.fromJson(x))
          .toList(),
    );
  }
}

class InvoiceAi {
  final String invoiceNumber;
  final String invoiceDate;
  final String invoiceType;
  final String? dueDate;
  final String? eWaybill;
  final String? poNumber;
  final String? lrNumber;
  final String? transporter;
  final double roundOff;
  final double freightAmount;
  final double otherCharges;
  final String currency;

  InvoiceAi({
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.invoiceType,
    this.dueDate,
    this.eWaybill,
    this.poNumber,
    this.lrNumber,
    this.transporter,
    required this.roundOff,
    required this.freightAmount,
    required this.otherCharges,
    required this.currency,
  });

  factory InvoiceAi.fromJson(Map<String, dynamic> json) {
    return InvoiceAi(
      invoiceNumber: json['invoice_number'] ?? '',
      invoiceDate: json['invoice_date'] ?? '',
      invoiceType: json['invoice_type'] ?? '',
      dueDate: json['due_date'],
      eWaybill: json['e_waybill'],
      poNumber: json['po_number'],
      lrNumber: json['lr_number'],
      transporter: json['transporter'],
      roundOff: _parseDouble(json['round_off']),
      freightAmount: _parseDouble(json['freight_amount']),
      otherCharges: _parseDouble(json['other_charges']),
      currency: json['currency'] ?? '',
    );
  }
}

class Seller {
  final String? name;
  final String? gstin;
  final String? dlNo;
  final String? address;
  final String? state;
  final String? stateCode;
  final String? phone;
  final String? email;

  Seller({
     this.name,
     this.gstin,
    this.dlNo,
     this.address,
     this.state,
     this.stateCode,
     this.phone,
    this.email,
  });

  factory Seller.fromJson(Map<String?, dynamic> json) {
    return Seller(
      name: json['name'] ?? '',
      gstin: json['gstin'] ?? '',
      dlNo: json['dl_no'],
      address: json['address'] ?? '',
      state: json['state'] ?? '',
      stateCode: json['state_code']?.toString() ?? '',
      phone: (json['phone']?.toString().replaceAll(',', '').trim()) ?? '',
      email: json['email']??'',
    );
  }
}

class Buyer {
  final String? name;
  final String? gstin;
  final String? address;
  final String? state;
  final String? stateCode;
  final String? phone;
  final String? email;

  Buyer({
     this.name,
    this.gstin,
     this.address,
    this.state,
    this.stateCode,
    this.phone,
    this.email,
  });

  factory Buyer.fromJson(Map<String?, dynamic> json) {
    return Buyer(
      name: json['name'] ?? '',
      gstin: json['gstin'],
      address: json['address'] ?? '',
      state: json['state'],
      stateCode: json['state_code']??'',
      phone: json['phone']??'',
      email: json['email'],
    );
  }
}

class Item {
  final int? srNo;
  final String? manufacturer;
  final String? description;
  final String? hsn;
  final String? batch;
  final String? expiry;
  final String? pack;
  final String? uom;
  final double? mrp;
  final double? rate;
  final int? qty;
  final int? freeQty;
  final double? discountRate;
  final double? discountAmount;
  final double? taxableAmount;
  final double? cgstRate;
  final double? cgstAmount;
  final double? sgstRate;
  final double? sgstAmount;
  final double? igstRate;
  final double? igstAmount;
  final double? lineSubtotal;
  final double? lineTaxTotal;
  final double? allocatedHeaderCharges;
  final double? total;

  Item({
     this.srNo,
     this.manufacturer,
     this.description,
    this.hsn,
     this.batch,
    this.expiry,
     this.pack,
     this.uom,
     this.mrp,
     this.rate,
     this.qty,
     this.freeQty,
     this.discountRate,
     this.discountAmount,
     this.taxableAmount,
     this.cgstRate,
     this.cgstAmount,
     this.sgstRate,
     this.sgstAmount,
     this.igstRate,
     this.igstAmount,
     this.lineSubtotal,
     this.lineTaxTotal,
     this.allocatedHeaderCharges,
     this.total,
  });

  factory Item.fromJson(Map<String?, dynamic> json) {
    return Item(
      srNo: json['sr_no'] ?? 0,
      manufacturer: json['manufacturer'] ?? '',
      description: json['description'] ?? '',
      hsn: json['hsn']??'',
      batch: json['batch'] ?? '',
      expiry: json['expiry'],
      pack: json['pack'] ?? '',
      uom: json['uom']?? '',
      mrp: _parseDouble(json['mrp']),
      rate: _parseDouble(json['rate']),
      qty: json['qty'] ?? 0,
      freeQty: json['free_qty'] ?? 0,
      discountRate: _parseDouble(json['discount_rate']),
      discountAmount: _parseDouble(json['discount_amount']),
      taxableAmount: _parseDouble(json['taxable_amount']),
      cgstRate: _parseDouble(json['cgst_rate']),
      cgstAmount: _parseDouble(json['cgst_amount']),
      sgstRate: _parseDouble(json['sgst_rate']),
      sgstAmount: _parseDouble(json['sgst_amount']),
      igstRate: _parseDouble(json['igst_rate']),
      igstAmount: _parseDouble(json['igst_amount']),
      lineSubtotal: _parseDouble(json['line_subtotal']),
      lineTaxTotal: _parseDouble(json['line_tax_total']),
      allocatedHeaderCharges: _parseDouble(json['allocated_header_charges']),
      total: _parseDouble(json['line_total']),
    );
  }
}
