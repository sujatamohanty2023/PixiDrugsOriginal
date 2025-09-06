import 'package:PixiDrugs/constant/all.dart';
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
    DashboardCardModel(title: 'cash+Online Balance', amount: '₹0.00',color:Colors.deepOrangeAccent),
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
    final size = MediaQuery.of(context).size;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final crossAxisCount = isPortrait ? 2 : 3;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTabBar(),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.5,
                children: [
                  ...cards.map((item) => _buildCard(item.title, item.amount,item.color)).toList(),
                ],
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

  Widget _buildCard(String title, String amount,Color colorValue) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient:  LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          colorValue.withOpacity(0.2),
          colorValue.withOpacity(0.2),
        ],
        stops: [0.0, 1.0],
        tileMode: TileMode.clamp),
        border: Border.all(color: colorValue, width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyTextfield.textStyle_w800(amount, SizeConfig.screenWidth! *0.045, colorValue),
          SizedBox(height: 5,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyTextfield.textStyle_w400(title.toUpperCase(), SizeConfig.screenWidth! *0.035,colorValue),
              Icon(Icons.arrow_forward_ios, size: SizeConfig.screenWidth! *0.035,color: colorValue),
            ],
          ),
        ],
      ),
    );
  }
}
