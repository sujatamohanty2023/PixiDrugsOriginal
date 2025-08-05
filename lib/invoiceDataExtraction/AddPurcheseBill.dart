import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:PixiDrugs/constant/all.dart';

class AddPurchaseBill extends StatefulWidget {
  final String path;
  Invoice? invoice1;
  AddPurchaseBill({
    super.key,
    this.path = '',
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

  int totalProducts = 0;
  int total = 0;
  int currentIndex = 0;
  List<InvoiceItem> productList = [];
  InvoiceItem? product;
  Invoice? invoice;

  bool _isLoading = true;

  final _accessKey = 'AKIAZOZQGAKUA3XO3NB7';
  final _secretKey = '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';
  final _region = 'us-east-1';

  @override
  void initState() {
    super.initState();
    _initialize();
  }
  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
    });
    try {
      Invoice? loadedInvoice;

      if (widget.path.isEmpty) {
        loadedInvoice = widget.invoice1;
      } else {
        loadedInvoice = await InvoiceRead();
        print("📄 Invoice : ${loadedInvoice.toJson()}");
      }

      setState(() {
        invoice = loadedInvoice;
        productList = invoice!.items;

        totalProducts = productList.length;

        total = 0;
        for (var item in productList) {
          final sanitizedTotal = double.tryParse(item.total.replaceAll(',', '') ?? '') ?? 0;
          total += sanitizedTotal.round();
        }
        if (productList.isNotEmpty) {
          currentIndex = 0;
          product = productList[currentIndex];
          _populateControllers();
        }
      });
    } catch (e) {
      print("❌ Failed to load invoice: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to read invoice data')),
      );
    }finally {
      setState(() {
        _isLoading = false; // End loading
      });
    }
  }
  Future<Invoice> InvoiceRead()async{
    final bytes = await fileToBytes(widget.path);
    final jsonData = await analyzeDocumentWithTextract(bytes);
    //final String jsonString = await rootBundle.loadString('assets/invoice1.json');
    //final jsonData = json.decode(jsonString);
    final parser = AnalyzeExpenseParser(jsonData);
    final invoiceData = parser.parse();
    printInvoiceData(invoiceData);
    return Invoice.fromJson(invoiceData);
  }
  void printInvoiceData(Map<String, dynamic> invoiceData) {
    invoiceData.forEach((key, value) {
      if (key == 'items' && value is List) {
        print('$key:');
        for (var i = 0; i < value.length; i++) {
          print('  Item ${i + 1}:');
          final item = value[i];
          if (item is Map) {
            item.forEach((itemKey, itemValue) {
              print('    $itemKey: $itemValue');
            });
          } else {
            print('    $item');
          }
          print('');
        }
      } else {
        print('$key: $value\n');
      }
    });
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
    if (gst == null || gst.isEmpty) return '0%';
    double gstDouble = double.tryParse(gst) ?? 0;
    int gstInt = gstDouble.toInt();
    return '$gstInt%';
  }
  void _populateControllers() {
    productNameController.text= product?.product ?? '';
    batchNoController.text = product?.batch ?? '';
    expDateController.text = product?.expiry ?? '';
    hsnCodeController.text = product?.hsn.toString()??'0';
    gstRateController.text = normalizeGst(product?.gst);
    unitPerPackController.text = product?.packing ?? '';
    billedQtyController.text = product?.qty.toString() ?? '';
    billedQtyFreeController.text = product?.qty_free.toString() ?? '0';
    rateController.text = product?.rate.toString() ?? '';
    mrpController.text = product?.mrp.toString() ?? '';
    discController.text = product?.discount.toString() ?? '';
    taxableController.text =product?.taxable.toString() ?? '';
    totalController.text = product?.total.toString() ?? '0.0';
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
  }

  void _deleteRecord() async {
    setState(() {
      // Remove the current product
      productList.removeAt(currentIndex);
      totalProducts = productList.length;

      // Recalculate total
      total = 0;
      for (var item in productList) {
        final sanitizedTotal = double.parse(item.total!.replaceAll(',', ''));
        total += sanitizedTotal.round() ?? 0;
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("product deleted successfully")),
        );
      }
    });
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
          ): SizedBox()
        ],
      ),
      body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.myGradient,
          ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.kPrimary,)) // Show loader
            :SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyTextfield.textStyle_w600(
                                    product!.product!.isNotEmpty?product!.product!:'Product $currentIndex',
                                    AppUtils.size_18,
                                    Colors.black,
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () {
                                      showEditDialog(
                                        context: context,
                                        title: "Edit Product Name",
                                        initialValue:  product?.product ??
                                            '',
                                        onSave: (value) {
                                          setState(() {
                                            productNameController.text=value;
                                          });
                                        },
                                      );
                                    },
                                    child: Icon(Icons.edit, size: 18, color: AppColors.kPrimary),
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
                    Expanded(child:_formField("Batch No",batchNoController,keyboardType: TextInputType.number)),
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
                    Expanded(child: _formField("Discount Value", discController,keyboardType: TextInputType.numberWithOptions(decimal: true))),
                    const SizedBox(width: 12),
                    Expanded(child: _formField("Taxable", taxableController,keyboardType: TextInputType.numberWithOptions(decimal: true)),),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    //Expanded(child: _dropdownField("GST", ["0%", "6%", "12%","9%", "18%"], gstRateController.text)),
                    Expanded(child: _formField("GST", gstRateController,keyboardType: TextInputType.numberWithOptions(decimal: true))),
                    const SizedBox(width: 12),
                    Expanded(child: _formField("Total", totalController,keyboardType: TextInputType.numberWithOptions(decimal: true))),
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
                      MyTextfield.textStyle_w800(totalController.text, AppUtils.size_18, AppColors.kPrimary)
                    ],
                  ),
                ),
                const SizedBox(height: 20),
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
              Expanded(
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
                        product?.total = totalController.text;
                      }

                      setState(() {
                        if (productNameController.text.isNotEmpty &&
                            batchNoController.text.isNotEmpty &&
                            expDateController.text.isNotEmpty &&
                            hsnCodeController.text.isNotEmpty &&
                            gstRateController.text.isNotEmpty &&
                            unitPerPackController.text.isNotEmpty &&
                            billedQtyController.text.isNotEmpty &&
                            billedQtyFreeController.text.isNotEmpty &&
                            rateController.text.isNotEmpty &&
                            mrpController.text.isNotEmpty &&
                            discController.text.isNotEmpty &&
                            taxableController.text.isNotEmpty &&
                            totalController.text.isNotEmpty) {
                          _saveCurrentProductData();

                          if (currentIndex == totalProducts - 1) {
                            final updatedJson = invoice!.copyWith(
                                items: productList).toJson();
                            print("Updated Invoice JSON: $updatedJson");
                            final updatedInvoice = invoice!.copyWith(
                                items: productList);
                            AppRoutes.navigateTo(context,
                                InvoiceSummaryPage(invoice: updatedInvoice,edit:widget.path.isEmpty));
                          } else {
                            currentIndex++;
                            product = productList[currentIndex];
                            _populateControllers();
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(
                                'Please enter all required fields.')),
                          );
                        }
                      });

                  },
                  label: MyTextfield.textStyle_w600(currentIndex == totalProducts - 1 ? "Confirm" : "Next", AppUtils.size_18, AppColors.kWhiteColor),
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

  Widget _formField(String label, TextEditingController controller, {String? hint,TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MyTextfield.textStyle_w600(
                label, AppUtils.size_16, Colors.black54),
            MyTextfield.textStyle_w600(" *", AppUtils.size_16, Colors.red)
          ],
        ),
        SizedBox(height: 5),
        MyEdittextfield(
            controller: controller, hintText: "Enter $label",keyboardType: keyboardType,),
      ],
    );
  }

  Widget _dropdownField(String label, List<String> items, String selectedValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MyTextfield.textStyle_w600(
                label, AppUtils.size_16, Colors.black),
            MyTextfield.textStyle_w600(" *", AppUtils.size_16, Colors.red)
          ],
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: selectedValue,
          iconEnabledColor: AppColors.kGreyColor800,
          iconDisabledColor:AppColors.kGreyColor800,
          decoration: InputDecoration(
            filled: true, // This enables the background color
            fillColor: AppColors.kWhiteColor,
            isDense: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color:AppColors.kPrimary.withOpacity(0.3), // Border color when not focused
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.kPrimary.withOpacity(0.3), // Border color when focused
                width: 1,
              ),
            ),
          ),
          style:MyTextfield.textStyle( 14,AppColors.kBlackColor800,FontWeight.w300),
          items: items.map((e) => DropdownMenuItem(
            value: e,
            child:  MyTextfield.textStyle_w600(e, AppUtils.size_14, AppColors.kGreyColor800)
          )).toList(),
          onChanged: (value) {
            gstRateController.text = value!;
          },
        )

      ],
    );
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
}