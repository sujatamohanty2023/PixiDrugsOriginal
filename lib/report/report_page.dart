import '../ListScreenNew/ExpenseListScreen.dart';
import '../../constant/all.dart';

import '../ListScreenNew/InvoiceReportScreen.dart';
import '../ListScreenNew/SaleReportScreen.dart';
import '../Stock/ProductList.dart';
import 'DashboardCardModel.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({Key? key}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String? role='';
  int selectedTabIndex = 0;

  final List<String> tabs = [
    'Today',
    'This Week',
    'This Month',
    'This Year'
  ];

  final List<DashboardCardModel> topCards = [
    DashboardCardModel(
        title: 'Stock Value',
        amount: '₹0.00',
        color: Colors.teal,
        icon: null,
        svgAsset: ''),
    DashboardCardModel(
        title: 'Cash+Online Balance',
        amount: '₹0.00',
        color: Colors.deepOrangeAccent,
        icon: null,
        svgAsset: ''),
    DashboardCardModel(
        title: 'Purchase amt.',
        amount: '₹0.00',
        color: Colors.pink,
        icon: null,
        svgAsset: ''),
  ];

  final List<DashboardCardModel> middleCards = [
    DashboardCardModel(
        title: 'Sales amt.',
        amount: '₹00.00',
        color: Colors.purple,
        svgAsset: AppImages.sale_amt,
        icon: null),
    DashboardCardModel(
        title: 'Profit',
        amount: '₹00.00',
        color: Colors.teal,
        svgAsset: AppImages.profit,
        icon: null),
  ];

  final List<DashboardCardModel> bottomCards = [
    DashboardCardModel(
        title: 'Expenses',
        amount: '₹0.00',
        color: Colors.cyan,
        icon: null,
        svgAsset: ''),
    DashboardCardModel(
        title: 'Stockist Due',
        amount: '₹0.00',
        color: Colors.green,
        icon: null,
        svgAsset: ''),
    DashboardCardModel(
        title: 'Customer Due',
        amount: '₹0.00',
        color: Colors.red,
        icon: null,
        svgAsset: ''),
  ];

  @override
  void initState() {
    super.initState();
    _getReport();
  }

  Future<void> _getReport() async {
    final userId = await SessionManager.getParentingId() ?? '';
    role = await SessionManager.getRole();
    String range = '';

    if (selectedTabIndex == 0) {
      range = 'today';
    } else if (selectedTabIndex == 1) {
      range = 'week';
    } else if (selectedTabIndex == 2) {
      range = 'month';
    } else if (selectedTabIndex == 3) {
      range = 'year';
    }

    context.read<ApiCubit>().report(store_id: userId, range: range);
    context.read<ApiCubit>().stream.listen((state) {
      if (state is ReportLoaded) {
        setState(() {
          topCards[0].amount = state.report.stock;
          // topCards[1].amount = state.report.balance;
          topCards[2].amount = state.report.purchases;
          middleCards[0].amount = state.report.sales;
          middleCards[1].amount = role=='owner'?state.report.profit:'00.00';
          bottomCards[0].amount =  role=='owner'?state.report.expense:'00.00';
          bottomCards[1].amount = state.report.sellerDue;
          bottomCards[2].amount = state.report.customerDue;
        });
      } else if (state is ReportError) {
        AppUtils.showSnackBar(context, 'Failed: ${state.error}');
      }
    });
  }

  Widget _buildTabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = selectedTabIndex == index;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTabIndex = index;
                    _getReport();
                  });
                },
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.kPrimary : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.kPrimaryDark),
                  ),
                  child: MyTextfield.textStyle_w800(
                    tabs[index],
                    14,
                    isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          _buildTabBar(),
          const SizedBox(height: 12),

          /// 🔹 Top Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: topCards.map((card) {
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (card.title == 'Stock Value') {
                      AppRoutes.navigateTo(context, ProductListPage(flag: 1,));
                    } else if (card.title == 'Cash+Online Balance') {
                      AppRoutes.navigateTo(context, Salereportscreen());
                    } else if (card.title == 'Purchase amt.') {
                      AppRoutes.navigateTo(context, Invoicereportscreen());
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: EdgeInsets.symmetric(
                      vertical: screenWidth * 0.03,
                      horizontal: screenWidth * 0.025,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: card.color.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(3, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          child: MyTextfield.textStyle_w800(
                            card.amount,
                            16,
                            card.color,
                          ),
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          child: MyTextfield.textStyle_w600(
                            card.title.toUpperCase(),
                            12,
                            Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 8),

          /// 🔹 Middle Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - 24) / 2;

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: middleCards.map((card) {
                  return  GestureDetector(
                      onTap: () {
                        if (card.title == 'Sales amt.') {
                          AppRoutes.navigateTo(context, Salereportscreen());
                        }
                      },
                      child: Container(
                        width: cardWidth,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: card.color.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(3, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 8),
                                FittedBox(
                                  child: MyTextfield.textStyle_w800(
                                    card.amount,
                                    18,
                                    card.color,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                MyTextfield.textStyle_w600(
                                  card.title.toUpperCase(),
                                  12,
                                  Colors.black,
                                ),
                              ],
                            ),
                            if (card.svgAsset.isNotEmpty)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: SvgPicture.asset(
                                  card.svgAsset,
                                  width: 60,
                                  height: 60,
                                ),
                              ),
                          ],
                        ),
                      )
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 8),

          /// 🔹 Bottom Cards
          Row(
            children: bottomCards.map((card) {
              return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (role=='owner' && card.title == 'Expenses') {
                        AppRoutes.navigateTo(context, ExpenseListScreen());
                      }else if (card.title == 'Stockist Due') {
                        AppRoutes.navigateTo(context, Invoicereportscreen(topCreditor: true,));
                      }else if (card.title == 'Customer Due') {
                        AppRoutes.navigateTo(context, Salereportscreen(topDebitor: true,));
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: EdgeInsets.symmetric(
                        vertical: screenWidth * 0.03,
                        horizontal: screenWidth * 0.025,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: card.color.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(3, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            child: MyTextfield.textStyle_w800(
                              card.amount,
                              16,
                              card.color,
                            ),
                          ),
                          const SizedBox(height: 6),
                          FittedBox(
                            child: MyTextfield.textStyle_w600(
                              card.title.toUpperCase(),
                              12,
                              Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
