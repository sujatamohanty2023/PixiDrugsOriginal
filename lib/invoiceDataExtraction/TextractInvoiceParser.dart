class AnalyzeExpenseParser {
  final Map<String, dynamic> json;

  AnalyzeExpenseParser(this.json);

  Map<String, dynamic> parse() {
    final invoice = <String, dynamic>{
      'invoiceId': '',
      'invoiceDate': '',
      'sellerName': '',
      'sellerGstin': '',
      'sellerAddress': '',
      'netAmount': '',
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
        final type = field['Type']?['Text'];
        final value = field['ValueDetection']?['Text'];
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
            invoice['net_amount'] = value ?? '';
            break;
        }
      }
    }

    // Parse line items
    final lineItemGroups = doc['LineItemGroups'] as List?;
    if (lineItemGroups != null) {
      for (final group in lineItemGroups) {
        final lineItems = group['LineItems'] as List?;
        if (lineItems == null) continue;

        for (final item in lineItems) {
          final itemFields = item['LineItemExpenseFields'] as List?;
          final row = <String, String>{};
          if (itemFields != null) {
            for (final f in itemFields) {
              final label = f['LabelDetection']?['Text'] ?? f['Type']?['Text'];
              final value = f['ValueDetection']?['Text'];
              if (label != null && value != null) {
                row[label] = value;
              }
            }
            if (row.isNotEmpty) invoice['items'].add(row);
          }
        }
      }
    }

    return invoice;
  }

}
