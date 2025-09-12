import 'package:PixiDrugs/constant/all.dart';
import '../ListPageScreen/ListScreen.dart';
import 'DashboardCardModel.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  int selectedTabIndex = 0;

  final List<String> tabs = [
    'Today',
    'Last 7 days',
    'Last 30 days',
    'Last 1 year',
  ];

  final List<DashboardCardModel> cards = [
    DashboardCardModel(title: 'Stock Value', amount: '₹0.00',color:Colors.teal),
    DashboardCardModel(title: 'Cash+Online Balance', amount: '₹0.00',color:Colors.deepOrangeAccent),
    DashboardCardModel(title: 'Sales Amt.', amount: '₹0.00',color:Colors.blue),
    DashboardCardModel(title: 'Purchase Amt.', amount: '₹0.00',color:Colors.pink),
    DashboardCardModel(title: 'Profit', amount: '₹0.00',color:Colors.deepPurple),
    DashboardCardModel(title: 'Expenses', amount: '₹0.00',color:Colors.cyan),
    DashboardCardModel(title: 'Stockist Due', amount: '₹0.00',color:Colors.green),
    DashboardCardModel(title: 'Customer Due', amount: '₹0.00',color:Colors.red),
  ];

  @override
  void initState() {
    super.initState();
    _GetReport();
  }

  Future<void> _GetReport() async {
    final userId = await SessionManager.getParentingId() ??'';
    var range='';
    if(selectedTabIndex==0){
      range='today';
    }else if(selectedTabIndex==2){
      range='week';
    }else if(selectedTabIndex==3){
      range='month';
    }else if(selectedTabIndex==4){
      range='year';
    }
    context.read<ApiCubit>().report(store_id:userId ,range: range);
    context.read<ApiCubit>().stream.listen((state) {
      if (state is ReportLoaded) {
        setState(() {
         cards[0].amount=state.report.stock;
         //cards[1].amount=state.report.b;
         cards[2].amount=state.report.sales;
         cards[3].amount=state.report.purchases;
         cards[4].amount=state.report.profit;
         cards[5].amount=state.report.expense;
         cards[6].amount=state.report.sellerDue;
         cards[7].amount=state.report.customerDue;
        });
      } else if (state is ReportError) {
        AppUtils.showSnackBar(context, 'Failed: ${state.error}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 400 ? 2 : screenWidth < 800 ? 3 : 4;
    final aspectRatio = screenWidth < 400 ? 2.0 : 2.5;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTabBar(),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final crossAxisSpacing = screenWidth * 0.03;
              final cardWidth = (screenWidth - (crossAxisSpacing * 1)) / 2; // 2 cards per row

              return Wrap(
                spacing: crossAxisSpacing, // horizontal space
                runSpacing: crossAxisSpacing, // vertical space
                children: cards.map((item) {
                  return SizedBox(
                    width: cardWidth, // fixed width for uniform layout
                    child: _buildCard(item.title, item.amount, item.color),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = selectedTabIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedTabIndex = index;
                  _GetReport();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.kPrimary : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.kPrimaryDark),
                ),
                child: MyTextfield.textStyle_w800(tabs[index], 14, isSelected ? Colors.white : Colors.black),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCard(String title, String amount, Color colorValue) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          print('Tapped on: $title');
          if (title == 'Cash+Online Balance') {
            AppRoutes.navigateTo(context, ListScreen(type: ListType.sale));
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: colorValue.withOpacity(0.08),
            border: Border.all(color: colorValue, width: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyTextfield.textStyle_w800(amount, screenWidth * 0.04, colorValue),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: MyTextfield.textStyle_w400(
                      title.toUpperCase(),
                      screenWidth * 0.032,
                      colorValue,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: screenWidth * 0.033,
                    color: colorValue,
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
