import 'package:PixiDrugs/constant/all.dart';

import '../customWidget/BottomLoader.dart';
import '../customWidget/GradientInitialsBox.dart';
import 'AddExpenseScreen.dart';
import 'ExpenseResponse.dart';

class ExpenseListWidget extends StatefulWidget {
  final bool isLoading;
  final List<ExpenseResponse> items;
  final VoidCallback onAddPressed;
  final ScrollController? scrollController;
  final bool hasMoreData;
  final VoidCallback? onRefreshRequested;
  const ExpenseListWidget({
    required this.isLoading,
    required this.items,
    required this.onAddPressed,
    this.scrollController,
    required this.hasMoreData,
    required this.onRefreshRequested,
  });

  @override
  State<ExpenseListWidget> createState() => _ExpenseListWidgetState();
}

class _ExpenseListWidgetState extends State<ExpenseListWidget> {


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemCount = widget.items.length + (widget.hasMoreData ? 1 : 0);
    return Stack(
      children: [
        Container(
          child: widget.isLoading
              ? Center(child: CircularProgressIndicator(color: AppColors.kPrimary,))
              : !widget.isLoading && widget.items.isEmpty
              ? NoItemPage(
            onTap: widget.onAddPressed,
            image: AppImages.no_invoice,
            tittle: 'No Expenses Found',
            description: 'You haven\'t recorded any expenses yet. Add your first expense to keep track of your store\'s spending.',
            button_tittle: 'Add Expense',
          )
              : ListView.builder(
            controller: widget.scrollController,
            padding: EdgeInsets.zero,
            itemCount: itemCount,
            itemBuilder: (_, index) {
              if (index >= widget.items.length) {
                return BottomLoader();
              }
              return _buildExpenseCard(widget.items[index], screenWidth,context);
            },
          ),
        ),
        // FAB Positioned at bottom right
          widget.items.isNotEmpty?Positioned(
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

  Widget _buildExpenseCard(ExpenseResponse item, double screenWidth, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => Addexpensescreen(expenseResponse: item)),
        );

        if (result == true) {
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
                name: item.title,
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyTextfield.textStyle_w800(item.title,screenWidth * 0.04,AppColors.kPrimary),
                    SizedBox(height: screenWidth * 0.01),
                    MyTextfield.textStyle_w400('Dt: ${item.expanseDate}',screenWidth * 0.035,Colors.grey.shade700,maxLines: true),
                    MyTextfield.textStyle_w600("Reason: ${item.note}", screenWidth * 0.035, Colors.teal,maxLines: true),
                    SizedBox(height: screenWidth * 0.01)
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(height: screenWidth * 0.015),
                  Builder(
                    builder: (context) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.025, vertical: screenWidth * 0.01),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(screenWidth * 0.02),
                        ),
                        child: MyTextfield.textStyle_w600(
                          "₹${item.amount}",
                          screenWidth * 0.04,
                          Colors.green,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
