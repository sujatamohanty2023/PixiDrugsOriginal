import 'dart:async';
import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http_parser/http_parser.dart';

import '../AIResponse/InvoiceResponse.dart';
import '../../constant/all.dart';

class AddPurchaseBill extends StatefulWidget {
  final List<String> paths;
  final bool manualAdd;
  Invoice? invoice1;
  AddPurchaseBill({
    super.key,
    this.paths = const [],
    this.manualAdd = false,
    Invoice? invoice,
  })  : invoice1 = invoice ??  Invoice(items: [InvoiceItem()]);

  @override
  State<AddPurchaseBill> createState() => _AddPurchaseBillState();
}

class _AddPurchaseBillState extends State<AddPurchaseBill> {
  final productNameController = TextEditingController();
  final batchNoController = TextEditingController();
  final expDateController = TextEditingController();
  final hsnCodeController = TextEditingController();
  final gstRateController = TextEditingController();
  final unitPerPackController = TextEditingController();
  final billedQtyController = TextEditingController();
  final billedQtyFreeController=TextEditingController();
  final rateController = TextEditingController();
  final mrpController = TextEditingController();
  final discController = TextEditingController();
  final taxableController = TextEditingController();
  final totalController = TextEditingController();
  VoidCallback? _discResetListener;

  int totalProducts = 0;
  int total = 0;
  int currentIndex = 0;
  List<InvoiceItem> productList = [];
  InvoiceItem? product;
  Invoice? invoice;

  bool _isLoading = true;
  int? editIndex;
  List<String> gstItems = ["0%", "3%","5%", "12%","18%","28%"];

  double _loadingProgress = 0.0;
  String _loadingStatus = "Initializing...";
  bool _showProgressBar = false;

  Timer? _debounceTimer;

  // Validation state variables for field highlighting
  bool _hasProductNameError = false;
  bool _hasBatchNoError = false;
  bool _hasExpDateError = false;
  bool _hasHsnCodeError = false;
  bool _hasGstRateError = false;
  bool _hasUnitPerPackError = false;
  bool _hasBilledQtyError = false;
  bool _hasBilledQtyFreeError = false;
  bool _hasRateError = false;
  bool _hasMrpError = false;
  bool _hasDiscError = false;
  bool _hasTaxableError = false;
  bool _hasTotalError = false;
  bool _hasDiscountTypeError = false;

  final _accessKey = 'AKIAZOZQGAKUA3XO3NB7';
  final _secretKey = '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';
  final _region = 'us-east-1';

  @override
  void initState() {
    super.initState();
    // Ensure GST items are unique and properly formatted
    _cleanupGstItems();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
    rateController.addListener(_debouncedRecalculation);
    billedQtyController.addListener(_debouncedRecalculation);
    discController.addListener(_debouncedRecalculation);
    gstRateController.addListener(_debouncedRecalculation);
    _discResetListener = () {
      if (discController.text.isNotEmpty && discController.text != '0') {
        setState(() {
          product?.discountType = null; // Force re-selection
        });
      } else {
        setState(() {
          product?.discountType = DiscountType.percent; // Reset to default
        });
      }
    };
    discController.addListener(_discResetListener!);
  }
  @override
  void dispose() {
    _debounceTimer?.cancel();
    rateController.removeListener(_debouncedRecalculation);
    billedQtyController.removeListener(_debouncedRecalculation);
    discController.removeListener(_debouncedRecalculation);
    gstRateController.removeListener(_debouncedRecalculation);
    if (_discResetListener != null) {
      discController.removeListener(_discResetListener!);
    }

    // Dispose controllers
    productNameController.dispose();
    batchNoController.dispose();
    expDateController.dispose();
    hsnCodeController.dispose();
    gstRateController.dispose();
    unitPerPackController.dispose();
    billedQtyController.dispose();
    billedQtyFreeController.dispose();
    rateController.dispose();
    mrpController.dispose();
    discController.dispose();
    taxableController.dispose();
    totalController.dispose();

    super.dispose();
  }
  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
      _loadingProgress = 0.0;
      _loadingStatus = "Initializing...";
      _showProgressBar = widget.paths.isNotEmpty;
    });

    try {
      Invoice? loadedInvoice;

      // Check if we are in edit mode
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      editIndex = args?['edit_product_index'] as int?;

      if (widget.paths.isEmpty && widget.invoice1 != null) {
        setState(() {
          _loadingStatus = "Loading invoice data...";
          _loadingProgress = 1.0;
        });
        loadedInvoice = widget.invoice1;
      } else if (widget.paths.isNotEmpty) {
        //loadedInvoice = await _readMultipleInvoicesAWS(widget.paths);
        loadedInvoice=await _readMultipleInvoicesAI(widget.paths);
      } else {
        setState(() {
          _loadingStatus = "Creating new invoice...";
          _loadingProgress = 1.0;
        });
        loadedInvoice = widget.invoice1 ?? Invoice(items: [InvoiceItem()]);
      }

      setState(() {
        _loadingStatus = "Processing invoice data...";
        _loadingProgress = 0.9;
      });

      setState(() {
        invoice = loadedInvoice;
        productList = invoice!.items;

        totalProducts = productList.length;

        total = 0;
        for (var item in productList) {
          final sanitizedTotal = double.tryParse(item.total.replaceAll(',', '') ?? '') ?? 0;
          total += sanitizedTotal.round();
        }
        if (editIndex != null && editIndex! >= 0 && editIndex! < productList.length) {
          currentIndex = editIndex!;
          product = productList[currentIndex];
        } else {
          currentIndex = 0;
          product = productList.isNotEmpty ? productList[0] : InvoiceItem();
        }
        _populateControllers();
        _loadingStatus = "Completed!";
        _loadingProgress = 1.0;
      });
    } catch (e) {
      print("❌ Failed to load invoice: $e");
      if (mounted) {
        setState(() {
          _loadingStatus = "Error loading invoice";
          _loadingProgress = 1.0;
        });
        AppUtils.showSnackBar(context,'Failed to read invoice data');
      }
    }finally {
      if (mounted) {
        // Small delay to show completion
        await Future.delayed(Duration(milliseconds: 500));
        setState(() {
          _isLoading = false;
          _showProgressBar = false;
        });
      }
    }
  }
  Future<Invoice> _readMultipleInvoicesAWS(List<String> paths) async {
    final allItems = <InvoiceItem>[];
    final allInvoices = <Invoice>[];
    final invoiceIds = <String>{};

    for (String path in paths) {
      try {
        final bytes = await fileToBytes(path);
        final jsonData = await analyzeDocumentWithTextract(bytes);
        final parser = AnalyzeExpenseParser(jsonData);
        final invoiceData = parser.parse();
        print('invoiceData=${invoiceData.toString()}');
        final invoice = Invoice.fromJson(invoiceData);

        allInvoices.add(invoice);

        if (invoice.invoiceId != null && invoice.invoiceId!.isNotEmpty) {
          invoiceIds.add(invoice.invoiceId!);
        }
      } catch (e) {
        print("❌ Error processing $path: $e");
      }
    }

    // Check if all invoice IDs are the same
    if (invoiceIds.length > 1) {
      print("⚠ Error: Multiple different invoice IDs found: $invoiceIds");
      AppUtils.showSnackBar(context, 'Multiple different invoice IDs found');
      // You could throw an exception, return empty, or handle differently
      return Invoice(items: []);
    }

    // Merge items from invoices (since all IDs match)
    for (final inv in allInvoices) {
      allItems.addAll(inv.items);
    }
    final updatedInvoice = allInvoices.first.copyWith(
        items: allItems);
    return updatedInvoice;
  }
  Future<Invoice> _readMultipleInvoicesAI(List<String> paths) async {
    final allItems = <InvoiceItem>[];
    final allInvoices = <Invoice>[];
    final invoiceIds = <String>{};
    List<MultipartFile> multipartFiles = [];

    setState(() {
      _loadingStatus = "Preparing files...";
      _loadingProgress = 0.1;
    });

    for (int i = 0; i < paths.length; i++) {
      multipartFiles.add(await createMultipartFile(paths[i]));
      setState(() {
        _loadingProgress = 0.1 + (0.2 * (i + 1) / paths.length);
        _loadingStatus = "Preparing file ${i + 1} of ${paths.length}...";
      });
    }

    if (multipartFiles.isNotEmpty) {
      try {
        setState(() {
          _loadingStatus = "Uploading files to server...";
          _loadingProgress = 0.3;
        });

        var formData = FormData.fromMap({
          'files': multipartFiles,
          'requirement': 'Analyze this document and provide a detailed summary with key insights, main points, and actionable recommendations.',
          'type':3
        });

        setState(() {
          _loadingStatus = "Processing...";
          _loadingProgress = 0.5;
        });

        var dio = Dio();
        var response = await dio.post(
          'https://pixi.dexcy.in/api/process',
          data: formData,
        );

        if (response.statusCode == 200) {
          setState(() {
            _loadingStatus = "Parsing response data...";
            _loadingProgress = 0.7;
          });

          var jsonData = response.data['data'];
          print("Raw Data: ${jsonData.runtimeType} - $jsonData");

          final List<InvoiceData> data = [];
          if (jsonData is List) {
            for (int i = 0; i < jsonData.length; i++) {
              var fileEntry = jsonData[i];
              setState(() {
                _loadingProgress = 0.7 + (0.1 * (i + 1) / jsonData.length);
                _loadingStatus = "Processing file ${i + 1} of ${jsonData.length}...";
              });

              if (fileEntry is List) {
                for (var invoiceJson in fileEntry) {
                  if (invoiceJson is Map<String, dynamic>) {
                    data.add(InvoiceData.fromJson(invoiceJson));
                  }
                }
              } else if (fileEntry is Map<String, dynamic>) {
                // Handle case where there's no outer list (single file)
                data.add(InvoiceData.fromJson(fileEntry));
              }
            }
          } else if (jsonData is Map<String, dynamic>) {
            data.add(InvoiceData.fromJson(jsonData));
          } else {
            print("⚠️ Unexpected data format: ${jsonData.runtimeType}");
            throw Exception("API returned unexpected data format.");
          }

          setState(() {
            _loadingStatus = "Converting to invoice format...";
            _loadingProgress = 0.8;
          });

          // Convert to internal model
          for (int i = 0; i < data.length; i++) {
            final invoice = convertFromOcrInvoiceData(data[i]);
            allInvoices.add(invoice);
            if (invoice.invoiceId != null && invoice.invoiceId!.isNotEmpty) {
              invoiceIds.add(invoice.invoiceId!);
            }
            setState(() {
              _loadingProgress = 0.8 + (0.1 * (i + 1) / data.length);
            });
          }
        }
      } catch (e) {
        print("❌ Error processing: $e");
        setState(() {
          _loadingStatus = "Error: ${e.toString().length > 50 ? e.toString().substring(0, 50) + '...' : e.toString()}";
          _loadingProgress = 1.0;
        });
        // Re-throw to let the calling function handle it
        rethrow;
      }
    }

    // Check if all invoice IDs are the same
    if (invoiceIds.length > 1) {
      print("⚠ Error: Multiple different invoice IDs found: $invoiceIds");
      AppUtils.showSnackBar(context, 'Multiple different invoice IDs found');
      return Invoice(items: []);
    }

    // Merge items from invoices (since all IDs match)
    for (final inv in allInvoices) {
      allItems.addAll(inv.items);
    }

    // --- FIX: Check if allInvoices is empty before accessing .first ---
    if (allInvoices.isEmpty) {
      print("⚠️ No invoices were successfully processed.");
      return Invoice(items: []);
    }

    final updatedInvoice = allInvoices.first.copyWith(
        items: allItems);
    return updatedInvoice;
  }

  Future<MultipartFile> createMultipartFile(String path) async {
    String extension = path.split('.').last.toLowerCase();
    MediaType contentType;

    switch (extension) {
      case 'pdf':
        contentType = MediaType('application', 'pdf');
        break;
      case 'jpg':
      case 'jpeg':
        contentType = MediaType('image', 'jpeg');
        break;
      case 'png':
        contentType = MediaType('image', 'png');
        break;
      default:
        contentType = MediaType('application', 'octet-stream');
    }

    return await MultipartFile.fromFile(
      path,
      filename: path.split('/').last,
      contentType: contentType,
    );
  }

  Invoice convertFromOcrInvoiceData(InvoiceData data) {
    List<InvoiceItem> items = data.item.map((item) {
      final double gst = item.gstRate ?? 0;
      final String gstFormatted = '${gst.toInt()}%';
      _addUniqueGstItem(gstFormatted);
      print('gst=$gstFormatted');
      print('Data=${item.toString()}');
      // Handle both discount rate and discount amount
      final bool hasDiscountRate = (item.discountRate ?? 0) > 0;
      final bool hasDiscountAmount = (item.discountAmount ?? 0) > 0;
      
      double discountValue = 0;
      DiscountType? discountType;
      
      if (hasDiscountAmount && !hasDiscountRate) {
        // Flat amount discount
        discountValue = item.discountAmount ?? 0;
        discountType = DiscountType.flat;
      } else if (hasDiscountRate) {
        // Percentage discount (prioritize rate if both are present)
        discountValue = item.discountRate ?? 0;
        discountType = DiscountType.percent;
      }
      
      return InvoiceItem(
        hsn: item.hsn ?? '',
        product: item.description ?? '',
        packing: item.pack ?? '',
        batch: item.batch ?? '',
        expiry: item.expiry ?? '',
        mrp: (item.mrp ?? 0).toStringAsFixed(2),
        rate: (item.rate ?? 0).toStringAsFixed(2),
        taxable: (item.taxableAmount ?? 0).toStringAsFixed(2),
        discount: discountValue.toStringAsFixed(2),
        discountType: discountType,
        qty: item.qty ?? 0,
        qty_free: item.freeQty ?? 0,
        gst: gstFormatted,
        total: item.total.toString(),
        sellerName: data.seller.name ?? '',
        sellerPhone: AppUtils().validateAndNormalizePhone(data.seller.phone) ,
      );
    }).toList();

    double netAmount = items.fold(0.0, (sum, item) {
      return sum + (double.tryParse(item.total) ?? 0.0);
    });
    final result =  AppUtils().extractTwoPhones(data.seller.phone??'');
    final sellerPhone1= result['phone1'];
    final sellerPhone2= result['phone2'];

    return Invoice(
      invoiceId: data.invoice.invoiceNumber ?? '',
      invoiceDate: data.invoice.invoiceDate ?? '',
      sellerName: data.seller.name ?? '',
      sellerGstin: data.seller.gstin ?? '',
      sellerAddress: data.seller.address ?? '',
      sellerPhone1: sellerPhone1,
      sellerPhone2: sellerPhone2,
      netAmount: netAmount.toStringAsFixed(2),
      items: items,
    );
  }
  Future<Uint8List> fileToBytes(String filePath) async {
    final file = File(filePath);
    return await file.readAsBytes();
  }
  Future<Map<String, dynamic>> analyzeDocumentWithTextract(Uint8List imageBytes) async {
    final credentials = AWSCredentials(_accessKey, _secretKey);
    final signer = AWSSigV4Signer(
      credentialsProvider: AWSCredentialsProvider(credentials),
    );

    final scope = AWSCredentialScope(
      region: _region,
      service: AWSService.textract,
    );

    final endpoint = Uri.https('textract.$_region.amazonaws.com', '/');

    final payload = json.encode({
      'Document': {
        'Bytes': base64Encode(imageBytes),
      },
    });

    final request = AWSHttpRequest(
      method: AWSHttpMethod.post,
      uri: endpoint,
      headers: {
        //AWSHeaders.contentType: 'application/x-amz-json-1.1',
        //AWSHeaders.target: 'Textract.AnalyzeExpense',
        'Content-Type':'application/x-amz-json-1.1',
        'X-Amz-Target': 'Textract.AnalyzeExpense'
      },
      body: payload.codeUnits,
    );

    final signedRequest = await signer.sign(request, credentialScope: scope);

    final dio = Dio();
    final response = await dio.post(
      endpoint.toString(),
      data: payload,
      options: Options(
        headers: signedRequest.headers,
        responseType: ResponseType.json,
      ),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data is String) {
        return jsonDecode(data);
      } else {
        throw Exception('Unexpected response type: ${data.runtimeType}');
      }
    } else {
      throw Exception('Failed: ${response.statusCode} - ${response.statusMessage}');
    }
  }
  String normalizeGst(String? gst) {
    if (gst == null || gst.trim().isEmpty) return '0%';
    final numeric = gst.replaceAll('%', '').trim();
    return '$numeric%';
  }

  void _cleanupGstItems() {
    print("🔧 Before cleanup: $gstItems");
    
    // Remove duplicates and ensure proper formatting
    final Set<String> uniqueGstItems = <String>{};
    for (String item in gstItems) {
      final normalized = normalizeGst(item);
      uniqueGstItems.add(normalized);
    }
    gstItems = uniqueGstItems.toList();
    gstItems.sort((a, b) {
      final numA = double.tryParse(a.replaceAll('%', '')) ?? 0;
      final numB = double.tryParse(b.replaceAll('%', '')) ?? 0;
      return numA.compareTo(numB);
    });
    
    print("✅ After cleanup: $gstItems");
  }

  void _addUniqueGstItem(String gstRate) {
    final normalized = normalizeGst(gstRate);
    if (!gstItems.contains(normalized)) {
      gstItems.add(normalized);
      // Re-sort after adding new item
      gstItems.sort((a, b) {
        final numA = double.tryParse(a.replaceAll('%', '')) ?? 0;
        final numB = double.tryParse(b.replaceAll('%', '')) ?? 0;
        return numA.compareTo(numB);
      });
    }
  }
  void _populateControllers() {
    productNameController.text= product?.product ?? '';
    batchNoController.text = product?.batch ?? '';
    expDateController.text = product?.expiry ?? '';
    hsnCodeController.text = product?.hsn.toString()??'0';
    
    // Normalize GST value and ensure it exists in gstItems
    final normalizedGst = normalizeGst(product?.gst);
    gstRateController.text = gstItems.contains(normalizedGst) ? normalizedGst : (gstItems.isNotEmpty ? gstItems.first : '0%');
    
    unitPerPackController.text = product?.packing ?? '';
    billedQtyController.text = product?.qty.toString() ?? '';
    billedQtyFreeController.text = product?.qty_free.toString() ?? '0';
    rateController.text = product?.rate.toString() ?? '';
    mrpController.text = product?.mrp.toString() ?? '';
    discController.text = product?.discount.toString() ?? '';
    taxableController.text =product?.taxable.toString() ?? '';
    totalController.text = product?.total.toString() ?? '';
    if (product != null) {
      // If discount value exists but no type is set, force user to select
      if ((product!.discount.isNotEmpty &&
          product!.discount != '0' && product!.discount != '0.0') &&
          product!.discountType == null) {
        // Don't set a default - force user selection
        product!.discountType = null;
      } else if (product!.discountType == null) {
        // Set default only when no discount value or discount is 0
        product!.discountType = DiscountType.percent;
      }
    }
    _recalculateTaxableAndTotal();
  }
  void _clearControllers() {
    batchNoController.clear();
    expDateController.clear();
    hsnCodeController.clear();
    gstRateController.clear();
    unitPerPackController.clear();
    billedQtyController.clear();
    billedQtyFreeController.clear();
    rateController.clear();
    mrpController.clear();
    discController.clear();
    taxableController.clear();
    totalController.clear();
    
    // Reset validation errors
    _clearValidationErrors();
  }

  void _clearValidationErrors() {
    setState(() {
      _hasProductNameError = false;
      _hasBatchNoError = false;
      _hasExpDateError = false;
      _hasHsnCodeError = false;
      _hasGstRateError = false;
      _hasUnitPerPackError = false;
      _hasBilledQtyError = false;
      _hasBilledQtyFreeError = false;
      _hasRateError = false;
      _hasMrpError = false;
      _hasDiscError = false;
      _hasTaxableError = false;
      _hasTotalError = false;
      _hasDiscountTypeError = false;
    });
  }

  void _deleteRecord() async {
    setState(() {
      // Remove the current product
      productList.removeAt(currentIndex);
      totalProducts = productList.length;

      // Recalculate total safely
      total = 0;
      for (var item in productList) {
        final sanitizedTotal = double.tryParse(item.total.replaceAll(',', '') ?? '0') ?? 0;
        total += sanitizedTotal.round();
      }

      // Handle edge cases
      if (productList.isEmpty) {
        product = null;
      } else {
        if (currentIndex >= productList.length) {
          currentIndex = productList.length - 1;
        }
        product = productList[currentIndex];
        _populateControllers();
        AppUtils.showSnackBar(context,"product deleted successfully");
      }
    });
  }
  bool _isDiscountTypeValidForCurrentProduct() {
    if (product == null) return true;

    String discountValue = discController.text.trim();
    bool hasDiscount = discountValue.isNotEmpty &&
        discountValue != '0' &&
        discountValue != '0.0';

    if (!hasDiscount) {
      return true; // No discount entered, so type validation not needed
    }

    // Discount is entered, so type must be properly selected
    return product!.discountType != null;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kWhiteColor,
      appBar: AppUtils.BaseAppBar(
        context: context,
        title: 'Add Purchase Bill',
        leading: true,
        actions: [
          currentIndex == totalProducts - 1 ?
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: MyElevatedButton(
              onPressed: () {
                setState(() {
                  final newItem = InvoiceItem();

                  productList.add(newItem);
                  currentIndex = productList.length - 1;
                  product = newItem;
                  totalProducts = productList.length;

                  _clearControllers();
                  _populateControllers(); // optional if you want to repopulate default values
                });
              },
              backgroundColor: AppColors.kPrimaryLight,
              titleColor:AppColors.kPrimary,
              custom_design: true,
              buttonText: "Add Product",
            ),
          ): Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child:!_isLoading? MyTextfield.textStyle_w800(
                '${currentIndex + 1} / $totalProducts',
                AppUtils.size_18,
                AppColors.kWhiteColor):SizedBox(),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.myGradient,
        ),
        child: _isLoading
            ? _buildLoadingWidget() // Show enhanced loader
            :SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16,right: 16,top: 16,bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product != null) ...[

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.kPrimary,
                            child: MyTextfield.textStyle_w600(
                              product!.product!.isNotEmpty?product!.product!.substring(0, 2):'P$currentIndex',
                              AppUtils.size_18,
                              Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    product!.product.isNotEmpty ? product!.product : 'Product $currentIndex',
                                    style: MyTextfield.textStyle(AppUtils.size_16, AppColors.kPrimary, FontWeight.w600),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () {
                                      showEditDialog(
                                        context: context,
                                        title: "Edit Product Name",
                                        initialValue: product?.product ?? '',
                                        onSave: (value) {
                                          setState(() {
                                            productNameController.text = value;
                                            product?.product = value;
                                          });
                                        },
                                      );
                                    },
                                    child: SvgPicture.asset(AppImages.edit, height: 18, color: Colors.teal),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              MyTextfield.textStyle_w200(
                                '# ${product!.hsn!}',
                                AppUtils.size_14,
                                Colors.black54,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        CommonConfirmationDialog.show<int>(
                            context: context,
                            id: currentIndex,
                            // Pass whether it's a medical record or leave record
                            title: 'Delete Product?',
                            content: 'Are you sure you want to delete this product?',
                            onConfirmed: (int) {
                              _deleteRecord();
                            });
                      },
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.kRedLightColor,
                        child: SvgPicture.asset(
                          AppImages.delete,
                          height: 18,
                          width: 18,
                          color: AppColors.kRedColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                /// Fields Layout
                Row(
                  children: [
                    Expanded(child:_formField("Batch No",batchNoController,keyboardType: TextInputType.text)),
                    const SizedBox(width: 12),
                    Expanded(child: _formField("Expiry Date", expDateController,keyboardType: TextInputType.datetime)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _formField("HSN Code", hsnCodeController,keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: _formField("Packing", unitPerPackController)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _formField("Qty", billedQtyController,keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: _formField("Free", billedQtyFreeController,keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _formField("MRP", mrpController,keyboardType: TextInputType.numberWithOptions(decimal: true))),
                    const SizedBox(width: 12),
                    Expanded(child: _formField("Rate", rateController,keyboardType: TextInputType.numberWithOptions(decimal: true))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _formField("Discount Value", discController,keyboardType: TextInputType.numberWithOptions(decimal: true)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dropdownField(
                        "Discount Type",
                        ["Select", "Percent", "Amount"],
                        _getDiscountTypeDisplay(product?.discountType),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _formField("Taxable", taxableController,keyboardType: TextInputType.numberWithOptions(decimal: true)),),
                    const SizedBox(width: 12),
                    Expanded(child: _dropdownField("GST", gstItems, gstRateController.text)),
                  ],
                ),
                const SizedBox(height: 16),

                /// Amount Total
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.kPrimaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MyTextfield.textStyle_w600("Amount: ", AppUtils.size_18, AppColors.kBlackColor800),
                      MyTextfield.textStyle_w800(totalController.text, AppUtils.size_18, AppColors.kPrimary),
                      SizedBox(width: 10,),
                      GestureDetector(
                        onTap: () {
                          showEditDialog(
                            context: context,
                            title: "Total Amount",
                            initialValue: totalController.text,
                            onSave: (value) {
                              setState(() {
                                totalController.text = value;
                                product?.total = value;
                              });
                            },
                          );
                        },
                        child:  SvgPicture.asset(AppImages.edit, height: 18, color: Colors.teal),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:_isLoading
          ? null // Hide buttons while loading
          :  Row(
        children: [
          if (currentIndex > 0)
            editIndex != null?SizedBox():Expanded(
              child:
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      currentIndex--;
                      product = productList[currentIndex];
                      _populateControllers();
                    });
                  },
                  label:  MyTextfield.textStyle_w600("Previous", AppUtils.size_18, AppColors.kPrimary),
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.kPrimaryLight,side: BorderSide(color: AppColors.kPrimary,width: 1.2)
                  ),
                ),
              ),
            ),
          if (currentIndex > 0) const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left:8,right: 8),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Clear previous validation errors
                  _clearValidationErrors();
                  
                  // Validate HSN Code
                  if (!RegExp(r'^\d+$').hasMatch(hsnCodeController.text)) {
                    setState(() {
                      _hasHsnCodeError = true;
                    });
                    return;
                  }
                  
                  // Validate Discount Type
                  if (!_isDiscountTypeValidForCurrentProduct()) {
                    setState(() {
                      _hasDiscountTypeError = true;
                    });
                    return;
                  }

                  void _saveCurrentProductData() {
                    product?.product = productNameController.text;
                    product?.batch = batchNoController.text;
                    product?.expiry = expDateController.text;
                    product?.hsn = hsnCodeController.text.replaceAll(
                        RegExp(r'\s+'), '');
                    product?.gst =
                        gstRateController.text.replaceAll('%', '');
                    product?.packing = unitPerPackController.text;
                    product?.qty = int.parse(billedQtyController.text);
                    product?.qty_free =
                        int.parse(billedQtyFreeController.text);
                    product?.rate = rateController.text;
                    product?.mrp = mrpController.text;
                    product?.taxable = taxableController.text;
                    product?.discount = discController.text;
                    product?.discountType = product?.discountType ?? DiscountType.percent;
                    product?.total = totalController.text;
                  }

                  setState(() {
                    // Validate all required fields and mark errors
                    bool hasValidationErrors = false;
                    
                    if (productNameController.text.isEmpty) {
                      _hasProductNameError = true;
                      hasValidationErrors = true;
                    }
                    if (batchNoController.text.isEmpty) {
                      _hasBatchNoError = true;
                      hasValidationErrors = true;
                    }
                    if (expDateController.text.isEmpty) {
                      _hasExpDateError = true;
                      hasValidationErrors = true;
                    }
                    if (hsnCodeController.text.isEmpty) {
                      _hasHsnCodeError = true;
                      hasValidationErrors = true;
                    }
                    if (gstRateController.text.isEmpty) {
                      _hasGstRateError = true;
                      hasValidationErrors = true;
                    }
                    if (unitPerPackController.text.isEmpty) {
                      _hasUnitPerPackError = true;
                      hasValidationErrors = true;
                    }
                    if (billedQtyController.text.isEmpty) {
                      _hasBilledQtyError = true;
                      hasValidationErrors = true;
                    }
                    if (billedQtyFreeController.text.isEmpty) {
                      _hasBilledQtyFreeError = true;
                      hasValidationErrors = true;
                    }
                    if (rateController.text.isEmpty) {
                      _hasRateError = true;
                      hasValidationErrors = true;
                    }
                    if (mrpController.text.isEmpty) {
                      _hasMrpError = true;
                      hasValidationErrors = true;
                    }
                    if (discController.text.isEmpty) {
                      _hasDiscError = true;
                      hasValidationErrors = true;
                    }
                    if (taxableController.text.isEmpty) {
                      _hasTaxableError = true;
                      hasValidationErrors = true;
                    }
                    if (totalController.text.isEmpty) {
                      _hasTotalError = true;
                      hasValidationErrors = true;
                    }
                    
                    if (!hasValidationErrors) {
                      _saveCurrentProductData();
                      if (editIndex != null) {
                        final updatedInvoice = invoice!.copyWith(items: productList);
                        Navigator.pop(context, updatedInvoice);
                      }else {
                        if (currentIndex == totalProducts - 1) {
                          final updatedJson = invoice!.copyWith(
                              items: productList).toJson();
                          print("Updated Invoice JSON: $updatedJson");
                          final updatedInvoice = invoice!.copyWith(
                              items: productList);
                          AppRoutes.navigateTo(context,
                              InvoiceSummaryPage(invoice: updatedInvoice,
                                  edit: widget.paths.isEmpty,manualAdd:widget.manualAdd));
                        } else {
                          currentIndex++;
                          product = productList[currentIndex];
                          _populateControllers();
                        }
                      }
                    }
                  });

                },
                label: MyTextfield.textStyle_w600( editIndex != null ? "Save" :(currentIndex == totalProducts - 1? "Confirm" : "Next"), AppUtils.size_18, AppColors.kWhiteColor),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.kPrimary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  String? _getDiscountTypeDisplay(DiscountType? type) {

    switch (type) {
      case DiscountType.percent:
        return "Percent";
      case DiscountType.flat:
        return "Amount";
      default:
        return "Select";
    }
  }

  Widget _formField(String label, TextEditingController controller, {String? hint,TextInputType keyboardType = TextInputType.text}) {
    // Determine if this field has an error
    bool hasError = false;
    if (label == "Product Name") hasError = _hasProductNameError;
    else if (label == "Batch No") hasError = _hasBatchNoError;
    else if (label == "Expiry Date") hasError = _hasExpDateError;
    else if (label == "HSN Code") hasError = _hasHsnCodeError;
    else if (label == "Packing") hasError = _hasUnitPerPackError;
    else if (label == "Qty") hasError = _hasBilledQtyError;
    else if (label == "Free") hasError = _hasBilledQtyFreeError;
    else if (label == "MRP") hasError = _hasMrpError;
    else if (label == "Rate") hasError = _hasRateError;
    else if (label == "Discount Value") hasError = _hasDiscError;
    else if (label == "Taxable") hasError = _hasTaxableError;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MyTextfield.textStyle_w400(
                label, AppUtils.size_16, hasError ? Colors.red : Colors.black54),
            MyTextfield.textStyle_w400(" *", AppUtils.size_16, Colors.red)
          ],
        ),
        SizedBox(height: 5),
        Container(
          decoration: hasError ? BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red, width: 2),
          ) : null,
          child: MyEdittextfield(
            controller: controller, 
            hintText: hasError ? "This field is required" : "Enter $label",
            keyboardType: keyboardType,
            onChanged: (value) {
              // Clear error when user starts typing
              if (hasError && value.isNotEmpty) {
                setState(() {
                  if (label == "Product Name") _hasProductNameError = false;
                  else if (label == "Batch No") _hasBatchNoError = false;
                  else if (label == "Expiry Date") _hasExpDateError = false;
                  else if (label == "HSN Code") _hasHsnCodeError = false;
                  else if (label == "Packing") _hasUnitPerPackError = false;
                  else if (label == "Qty") _hasBilledQtyError = false;
                  else if (label == "Free") _hasBilledQtyFreeError = false;
                  else if (label == "MRP") _hasMrpError = false;
                  else if (label == "Rate") _hasRateError = false;
                  else if (label == "Discount Value") _hasDiscError = false;
                  else if (label == "Taxable") _hasTaxableError = false;
                });
              }
            },
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: MyTextfield.textStyle_w400(
              "This field is required", 
              AppUtils.size_14,
              Colors.red
            ),
          ),
      ],
    );
  }
  Widget _dropdownField(String label, List<String> items, String? selectedValue) {
    // Determine if this field has an error
    bool hasError = false;
    if (label == "GST") hasError = _hasGstRateError;
    else if (label == "Discount Type") hasError = _hasDiscountTypeError;
    
    // Ensure the selected value exists in items, otherwise set to first item or null
    String? validatedValue;
    if (selectedValue != null && items.contains(selectedValue)) {
      validatedValue = selectedValue;
    } else if (items.isNotEmpty) {
      validatedValue = items.first;
      // Update controller if we had to change the value
      if (label == "GST" && validatedValue != selectedValue) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          gstRateController.text = validatedValue!;
        });
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MyTextfield.textStyle_w400(
              label, 
              AppUtils.size_16, 
              hasError ? Colors.red : Colors.black54
            ),
            MyTextfield.textStyle_w400(" *", AppUtils.size_16, Colors.red)
          ],
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: validatedValue,
          iconEnabledColor: AppColors.kGreyColor800,
          iconDisabledColor: AppColors.kGreyColor800,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.kWhiteColor,
            isDense: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.red : AppColors.kPrimaryDark,
                width: hasError ? 2 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? Colors.red : AppColors.kPrimaryDark,
                width: hasError ? 2 : 1,
              ),
            ),
          ),
          style: MyTextfield.textStyle(14, AppColors.kBlackColor800, FontWeight.w300),
          items: items.map((e) => DropdownMenuItem(
            value: e,
            child: MyTextfield.textStyle_w600(e, AppUtils.size_14, Colors.black),
          )).toList(),
          onChanged: (value) {
            // Clear error when user makes selection
            if (hasError) {
              setState(() {
                if (label == "GST") _hasGstRateError = false;
                else if (label == "Discount Type") _hasDiscountTypeError = false;
              });
            }
            
            if (label == "GST") {
              gstRateController.text = value!;
            } else if (label == "Discount Type") {
              if (value == "Select") {
                product?.discountType = null;
                return;
              }
              setState(() {
                product?.discountType = value == "Percent" ? DiscountType.percent : DiscountType.flat;
                _recalculateTaxableAndTotal();
              });
            }
          },
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: MyTextfield.textStyle_w400(
              label == "Discount Type" ? "Please select discount type" : "This field is required", 
              AppUtils.size_14,
              Colors.red
            ),
          ),
      ],
    );
  }
  void _recalculateTaxableAndTotal() {
    if (product == null) return;

    double rate = double.tryParse(rateController.text) ?? 0;
    int qty = int.tryParse(billedQtyController.text) ?? 0;
    double discountValue = double.tryParse(discController.text) ?? 0;

    if (rate == 0 && qty == 0) return; // Skip calculation if no meaningful input

    double subtotal = rate * qty;

    double discountAmount = 0;
    if (product!.discountType == DiscountType.percent) {
      discountAmount = subtotal * (discountValue / 100);
    } else {
      discountAmount = discountValue;
    }

    double taxable = subtotal - discountAmount;
    double gstRate = double.tryParse(gstRateController.text.replaceAll('%', '')) ?? 0;
    double gstAmount = taxable * (gstRate / 100);
    double total = taxable + gstAmount;

    // Batch update controllers to reduce rebuilds
    final taxableFormatted = taxable.toStringAsFixed(2);
    final totalFormatted = total.toStringAsFixed(2);

    if (taxableController.text != taxableFormatted) {
      taxableController.text = taxableFormatted;
    }
    if (totalController.text != totalFormatted) {
      totalController.text = totalFormatted;
    }

    // Update product model immediately
    product!.taxable = taxableFormatted;
    product!.total = totalFormatted;
  }

  void _debouncedRecalculation() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 300), () {
      _recalculateTaxableAndTotal();
    });
  }

  void showEditDialog({
    required BuildContext context,
    required String title,
    required String initialValue,
    required void Function(String) onSave,
  }) {
    showDialog(
      context: context,
      builder: (_) => EditValueDialog(
        title: title,
        initialValue: initialValue,
        onSave: onSave,
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.kWhiteColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: SpinKitThreeBounce(
                    color:AppColors.kPrimary,
                    size: 30.0,
                  ),
                ),
                SizedBox(height: 24),
                if (_showProgressBar) ...[
                  Container(
                    width: 250,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MyTextfield.textStyle_w600(
                              "Progress",
                              AppUtils.size_14,
                              AppColors.kBlackColor800,
                            ),
                            MyTextfield.textStyle_w600(
                              "${(_loadingProgress * 100).toInt()}%",
                              AppUtils.size_14,
                              AppColors.kPrimary,
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _loadingProgress,
                            backgroundColor: AppColors.kGreyColor700,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.kPrimary),
                            minHeight: 8,
                          ),
                        ),
                        SizedBox(height: 16),
                        MyTextfield.textStyle_w400(
                          _loadingStatus,
                          AppUtils.size_14,
                          AppColors.kBlackColor800,
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  SizedBox(height: 16),
                  MyTextfield.textStyle_w400(
                    "Loading...",
                    AppUtils.size_16,
                    AppColors.kBlackColor800,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

}