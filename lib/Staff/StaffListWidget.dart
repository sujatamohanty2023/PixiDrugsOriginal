import 'package:PixiDrugs/Staff/AddStaffScreen.dart';
import 'package:PixiDrugs/constant/all.dart';
import '../customWidget/BottomLoader.dart';
import '../customWidget/GradientInitialsBox.dart';
import 'StaffModel.dart';

class StaffListWidget extends StatefulWidget {
  final bool isLoading;
  final List<StaffModel> list;
  final VoidCallback onAddPressed;
  final ScrollController? scrollController;
  final bool hasMoreData;
  final VoidCallback? onRefreshRequested;
  const StaffListWidget({
    required this.isLoading,
    required this.list,
    required this.onAddPressed,
    this.scrollController,
    required this.hasMoreData,
  required this.onRefreshRequested,
  });

  @override
  State<StaffListWidget> createState() => _StaffListWidgetState();
}

class _StaffListWidgetState extends State<StaffListWidget> {

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemCount = widget.list.length + (widget.hasMoreData ? 1 : 0);
    return Stack(
        children: [
          Container(
            child: widget.isLoading
                ? Center(child: CircularProgressIndicator(color: AppColors.kPrimary,))
                : !widget.isLoading && widget.list.isNotEmpty
                ?ListView.builder(
              controller: widget.scrollController,
              padding: EdgeInsets.zero,
              itemCount: itemCount,
              itemBuilder: (_, index) {
                if (index >= widget.list.length) {
                  return BottomLoader();
                }
                return _buildStaffCard(widget.list[index], screenWidth,context);
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
            bottom: 40,
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
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddStaffScreen(staff: item),),
        );
        if (result==true) {
          widget.onRefreshRequested?.call();
        }
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
              GradientInitialsBox(
                size: screenWidth * 0.15,
                name: item.name,
              ),
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
}
