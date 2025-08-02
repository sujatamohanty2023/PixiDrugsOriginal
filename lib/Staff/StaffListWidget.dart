import 'package:PixiDrugs/Staff/AddStaffScreen.dart';
import 'package:PixiDrugs/constant/all.dart';
import 'StaffModel.dart';

class StaffListWidget extends StatefulWidget {
  final bool isLoading;
  final List<StaffModel> list;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAddPressed;
  const StaffListWidget({
    required this.isLoading,
    required this.list,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onAddPressed,
  });

  @override
  State<StaffListWidget> createState() => _StaffListWidgetState();
}

class _StaffListWidgetState extends State<StaffListWidget> {

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final filteredStaff = widget.list
        .where((i) =>
        i.name.toLowerCase().contains(widget.searchQuery.toLowerCase()))
        .toList();
    return Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.myGradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(screenWidth * 0.07),
                topRight: Radius.circular(screenWidth * 0.07),
              ),
            ),
            child: widget.isLoading
                ? Center(child: CircularProgressIndicator(color: AppColors.kPrimary,))
                : widget.list.isNotEmpty
                ?ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: filteredStaff.length,
              itemBuilder: (_, index) {
                final item = filteredStaff[index];
                return _buildStaffCard(item, screenWidth,context);
              },
            ):NoItemPage(
              onTap: widget.onAddPressed,
              image: AppImages.empty_cart,
              tittle: "No Staff Members",
              description: "Add staff to manage inventory, sales,\nand keep your business running smoothly.",
              button_tittle: "Add Staff",
            ),
          ),
          // FAB Positioned at bottom right
          widget.list.isNotEmpty?Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: widget.onAddPressed,
              backgroundColor: AppColors.kPrimary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ):SizedBox(),
        ]
    );
  }

  Widget _buildStaffCard(StaffModel item, double screenWidth, BuildContext context) {
    return GestureDetector(
      onTap: (){
        AppRoutes.navigateTo(context, AddStaffScreen(staff: item));
      },
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenWidth * 0.015),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.03)),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: Row(
            children: [
              CircleAvatar(
                  radius: screenWidth * 0.08,
                  backgroundColor: AppColors.kPrimaryDark,
                  child: MyTextfield.textStyle_w600( getInitials(item.name),screenWidth * 0.045,AppColors.kPrimary) ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyTextfield.textStyle_w800(item.name,screenWidth * 0.04,AppColors.kPrimary),
                    SizedBox(height: screenWidth * 0.01),
                    MyTextfield.textStyle_w400('Email: ${item.email}',screenWidth * 0.035,Colors.grey.shade700,maxLines: true),
                    SizedBox(height: screenWidth * 0.01),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.status == 'active' ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: item.status == 'active' ? Colors.green : Colors.red,
                        ),
                      ),
                      child:
                      MyTextfield.textStyle_w800(
                          item.status,
                          14,
                          item.status == 'active' ? Colors.green : Colors.red
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.01)
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  launchUrl(
                    Uri.parse(
                      "tel:+91${item.phoneNumber}",
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.call,
                    color: Colors.green,
                    size: 25,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String getInitials(String name) {
    final parts = name.trim().split(' ');
    return parts.take(2).map((e) => e[0].toUpperCase()).join();
  }
}
