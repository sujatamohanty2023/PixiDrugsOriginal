class AnalyzeExpenseParser {
  final Map<String, dynamic> json;

  AnalyzeExpenseParser(this.json);

  /// Smart guess for field type when Textract returns "OTHER"
  String guessLabelFromValue(String value) {
    final lower = value.toLowerCase();

    if (lower.contains('gm') || lower.contains('ml') || lower.contains('kg')) return 'packing';
    if (lower.contains('batch') || RegExp(r'^[a-zA-Z]?\d{3,}$').hasMatch(lower)) return 'batch';
    if (lower.contains('exp')) return 'expiry';
    if (lower.contains('hsn') || RegExp(r'^\d{4,8}$').hasMatch(lower)) return 'hsn';
    if (lower.contains('%') || lower.contains('gst')) return 'gst';
    if (lower.contains('disc') || lower.contains('discount')) return 'discount';
    if (lower.contains('mrp')) return 'mrp';

    if (RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
      final num = double.tryParse(value) ?? 0.0;
      if (num < 10) return 'qty';
      if (num < 999) return 'rate';
      return 'total';
    }

    return 'product';
  }

  /// Parse the full invoice
  Map<String, dynamic> parse() {
    final invoice = <String, dynamic>{
      'invoice_no': '',
      'invoice_date': '',
      'seller_name': '',
      'gst_no': '',
      'address': '',
      'net_amount': '',
      'user_id': '',
      'items': <Map<String, String>>[],
    };

    final documents = json['ExpenseDocuments'] as List?;
    if (documents == null || documents.isEmpty) return invoice;

    final doc = documents.first;

    // Parse summary fields
    final summaryFields = doc['SummaryFields'] as List?;
    if (summaryFields != null) {
      for (final field in summaryFields) {
        final type = field['Type']?['Text'] ?? '';
        final value = field['ValueDetection']?['Text'] ?? '';
        switch (type) {
          case 'INVOICE_RECEIPT_ID':
            invoice['invoice_no'] = value;
            break;
          case 'INVOICE_RECEIPT_DATE':
            invoice['invoice_date'] = value;
            break;
          case 'VENDOR_NAME':
            invoice['seller_name'] = value;
            break;
          case 'VENDOR_ADDRESS':
            invoice['address'] = value;
            break;
          case 'VENDOR_GST_NUMBER':
            invoice['gst_no'] = value;
            break;
          case 'TOTAL':
            invoice['net_amount'] = value;
            break;
        }
      }
    }

    // Parse line items
    final lineItemGroups = doc['LineItemGroups'] as List?;
    if (lineItemGroups != null) {
      for (final group in lineItemGroups) {
        final lineItems = group['LineItems'] as List?;

        for (final item in lineItems!) {
          final itemFields = item['LineItemExpenseFields'] as List?;
          final row = <String, String>{};

          if (itemFields != null) {
            for (final f in itemFields) {
              final label = f['LabelDetection']?['Text'] ?? f['Type']?['Text'];
              final value = f['ValueDetection']?['Text'];

              print('itemsValue ${f['LabelDetection']?['Text']}/${f['Type']?['Text']}  = $value');

              // Clean key
              final key = (label.toLowerCase() == 'other')
                  ? guessLabelFromValue(value)
                  : label.toLowerCase().trim();

              row[key] = value.trim();
            }

            if (row.isNotEmpty) {
              invoice['items'].add(row);
            }
          }
        }
      }
    }

    return invoice;
  }
}
