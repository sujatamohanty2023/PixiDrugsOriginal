
import 'package:pixidrugs/constant/all.dart';

import '../Dialog/show_image_picker.dart';

class InvoiceListPage extends StatefulWidget {
  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> with WidgetsBindingObserver, RouteAware{
   String searchQuery = "";
   bool isLoading = false;
   List<Invoice> invoices = [];
   List<Invoice> filteredInvoices=[];

   Future<void> _fetchInvoiceRecord() async {
     setState(() {
       isLoading = true;
     });
     String? userId = await SessionManager.getUserId();
     context.read<ApiCubit>().fetchInvoiceList(user_id: userId!);
   }
   @override
   void initState() {
     super.initState();
     WidgetsBinding.instance.addObserver(this);
     _fetchInvoiceRecord(); // Fetch records when the screen is initialized
   }
   @override
   void didChangeDependencies() {
     super.didChangeDependencies();
     routeObserver.subscribe(this, ModalRoute.of(context)!);
   }
   @override
   void dispose() {
     WidgetsBinding.instance.removeObserver(this);
     routeObserver.unsubscribe(this);
     print("initState dispose: Dashboard disposed");
     super.dispose();
   }
   @override
   void didChangeAppLifecycleState(AppLifecycleState state) {
     if (state == AppLifecycleState.resumed) {
       print("initState App is back in foreground");
       _fetchInvoiceRecord();
     }
   }
   @override
   void didPopNext() {
     print("initState Returned to DoctorDashboard from another screen");
     _fetchInvoiceRecord(); // ✅ Call your API here if needed
   }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    filteredInvoices = invoices
        .where((invoice) => invoice.sellerName!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      body: _buildBlocListener(),
      floatingActionButton: invoices.isNotEmpty
          ? FloatingActionButton(
        onPressed: () => _onAddInvoicePressed(context),
        backgroundColor: AppColors.kPrimary,
        child: Icon(Icons.add, color: Colors.white),
      )
          : SizedBox(),
    );
  }
   Widget _buildBlocListener() {
     return BlocListener<ApiCubit, ApiState>(
       listener: (context, apiState) {
         if (apiState is InvoiceListLoading) {
           setState(() {
             isLoading = true;
           });
         } else if (apiState is InvoiceListLoaded) {
           setState(() {
             isLoading = false;
             invoices = apiState.invoiceList;
             print('invoices records loaded: $invoices'); // Debug print
           });
         } else if (apiState is InvoiceListError) {
           setState(() {
             isLoading = false;
           });
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
             content: Text("Failed to load leave invoices."),
           ));
         }
       },
       child: _buildScreen(),
     );
   }
   Widget _buildScreen() {
    var screenWidth=SizeConfig.screenWidth;
     return Container(
       color: AppColors.kPrimary,
       width: double.infinity,
       padding: EdgeInsets.only(top: screenWidth! * 0.12),
       child: Column(
         children: [
           Padding(
             padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Row(
                   children: [
                     IconButton(
                       icon: Icon(Icons.arrow_back, color: Colors.white, size: screenWidth * 0.065),
                       onPressed: () {
                         Navigator.pop(context);
                       },
                     ),
                     Text(
                       'Invoices',
                       style: TextStyle(
                         color: Colors.white,
                         fontSize: screenWidth * 0.055,
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                   ],
                 ),
               ],
             ),
           ),
           Padding(
             padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.02),
             child: Container(
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(screenWidth * 0.07),
               ),
               child: TextField(
                 decoration: InputDecoration(
                   hintText: "Search by name",
                   prefixIcon: Icon(Icons.search),
                   border: InputBorder.none,
                   isDense: true, // Makes content compact and icon/text aligned
                   contentPadding: EdgeInsets.symmetric(vertical: 14), // Adjusts vertical alignment
                 ),
                 onChanged: (value) {
                   setState(() {
                     searchQuery = value;
                   });
                 },
               ),
             ),
           ),

           Expanded(
             child: Container(
               decoration: BoxDecoration(
                 gradient: AppColors.myGradient,
                 borderRadius: BorderRadius.only(
                   topRight: Radius.circular(screenWidth * 0.07),
                   topLeft: Radius.circular(screenWidth * 0.07),
                 ),
               ),
               child:isLoading
                   ? Center(
                 child: CircularProgressIndicator(
                   valueColor: AlwaysStoppedAnimation<Color>(AppColors.kPrimary),
                 ),
               ):invoices.isEmpty
                   ? NoItemPage(
                 onTap: () => _onAddInvoicePressed(context),
                 image: AppImages.add_invoice,
                 tittle: 'Add an Invoice record.',
                 description: "Please add your invoice details for better tracking.",
                 button_tittle: 'Add Invoice',
               ) :ListView.builder(
                 itemCount: filteredInvoices.length,
                 padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
                 itemBuilder: (context, index) {
                   final invoice = filteredInvoices[index];
                   return buildInvoiceCard(invoice, screenWidth);
                 },
               ),
             ),
           ),
         ],
       ),
     );
   }
   Future<void> _onAddInvoicePressed(BuildContext context) async {
     showImageBottomSheet(context, _setSelectedImage, pdf: true,pick_Size:1);
   }
   void _setSelectedImage(List<File> file) {
     Future.delayed(Duration(milliseconds: 100), () {
       Navigator.push(
         context,
         MaterialPageRoute(
           builder: (context) => AddPurchaseBill(path: file[0].path),
         ),
       );
     });
   }
  Widget buildInvoiceCard(Invoice invoice, double screenWidth) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenWidth * 0.010),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.03)),
      child: IntrinsicHeight(
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(screenWidth * 0.03),
                bottomLeft: Radius.circular(screenWidth * 0.03),
              ),
              child: Container(
                width: screenWidth * 0.015,
                color: AppColors.kPrimary,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.02),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: screenWidth * 0.08,
                      backgroundColor: AppColors.kPrimaryDark,
                      child: Text(
                        getInitials(invoice.sellerName!),
                        style: TextStyle(
                          color: AppColors.kPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.045,
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(invoice.sellerName!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04)),
                          SizedBox(height: screenWidth * 0.01),
                          Text(invoice.invoiceId!, style: TextStyle(color: Colors.grey.shade700, fontSize: screenWidth * 0.035)),
                          SizedBox(height: screenWidth * 0.01),
                          Text(invoice.invoiceDate!, style: TextStyle(color: Colors.grey.shade600, fontSize: screenWidth * 0.03)),
                          Text(
                            "₹${invoice.netAmount!}",
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.045),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {

                            } else if (value == 'delete') {
                              DeleteDialog(context,invoice.invoiceId!);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 'edit',
                           child:Row(
                              children: [
                                Icon(Icons.edit, color: Colors.black),
                                SizedBox(width: 8),
                                MyTextfield.textStyle_w600('Edit', 13, Colors.black),
                              ],
                            )),
                            PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      AppImages.delete,
                                      height: 18,
                                      width: 18,
                                      color: AppColors.kRedColor,
                                    ),
                                    SizedBox(width: 8),
                                    MyTextfield.textStyle_w600('Delete', 13, Colors.black),
                                  ],
                                )
                            ),
                          ],
                          icon: Icon(Icons.more_vert, size: screenWidth * 0.05),
                        ),
                        SizedBox(height: screenWidth * 0.015),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025, vertical: screenWidth * 0.01),
                          decoration: BoxDecoration(
                            //color: invoice.status == "Paid" ? Colors.green.shade100 : Colors.red.shade100,
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(screenWidth * 0.01),
                          ),
                          child: Text(
                            //invoice.status,
                            'Paid',
                            style: TextStyle(
                              //color: invoice.status == "Paid" ? Colors.green : Colors.red,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.03,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
   void DeleteDialog(BuildContext context, String id) {
     CommonConfirmationDialog.show<int>(
         context:context,
         id:int.parse(id), // Pass whether it's a medical record or leave record
         title:'Delete Invoice Record?',
         content: 'Are you sure you want to delete this invoice record?',
          onConfirmed: (int) {
            _deleteRecord(id);
          },
     );
   }
   Future<void> _deleteRecord(String id) async {
     try {
       /* await context
           .read<ApiCubit>()
           .deleteMedicalRecord(recordid: record.id.toString());*/

       // After the deletion is successful, remove the record from the list locally
       _fetchInvoiceRecord();

       // Show success message
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("Record deleted successfully")),
       );
     } catch (e) {
       // Handle any errors that may occur during deletion
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("Failed to delete record: $e")),
       );
     }
   }
  String getInitials(String name) {
    List<String> parts = name.split(" ");
    String initials = "";
    if (parts.isNotEmpty) initials += parts[0][0];
    if (parts.length > 1) initials += parts[1][0];
    return initials.toUpperCase();
  }
}