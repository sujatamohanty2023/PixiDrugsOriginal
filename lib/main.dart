import 'package:PixiDrugs/SaleReturn/SaleReturnScreen.dart';
import 'package:PixiDrugs/Home/HomePageScreen.dart';
import 'package:PixiDrugs/SplashScreen.dart';
import 'package:PixiDrugs/Stock/ProductList.dart';
import 'package:PixiDrugs/constant/all.dart';
import 'package:PixiDrugs/login/FCMService.dart';
import 'package:PixiDrugs/login/mobileLoginScreen.dart';
import 'package:PixiDrugs/StockReturn/PurchaseReturnScreen.dart';

import 'PaymentScreen.dart';
import 'Profile/WebviewScreen.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.data['type'] == 'video') {}
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Dynamically choose the provider based on build mode
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _initFCMToken();
    // These need context and should be called from a widget lifecycle method
    FCMService().initFCMMessage(context);
  }

  Future<void> _initFCMToken() async {
    await FCMService().initFCMToken(context);
  }

  @override
  Widget build(BuildContext context) {
    final apiRepository = ApiRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CartCubit()),
        BlocProvider(create: (_) => ApiCubit(apiRepository)),
      ],
      child: Builder(
        builder:
            (context) => BlocListener<ApiCubit, ApiState>(
              listener: (context, state) {
                if (state is UserProfileLoaded) {
                  final user = state.userModel.user;
                  if (user.status != 'inactive' && !_dialogShown) {
                    _dialogShown = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _showGlobalSessionFailedDialog(context);
                    });
                  }
                }
              },
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                navigatorObservers: [routeObserver],
                routes: {
                  '/home': (context) => HomePage(),
                  '/login': (context) => MobileLoginScreen(),
                },
                onGenerateRoute: (settings) {
                  if (settings.name == '/stockList') {
                    final flag = settings.arguments;
                    return MaterialPageRoute(
                      builder:
                          (_) =>
                              ProductListPage(flag: int.parse(flag.toString())),
                    );
                  } else if (settings.name == '/purchaseReturn') {
                    final value = settings.arguments;
                    return MaterialPageRoute(
                      builder:
                          (_) =>
                              PurchaseReturnScreen(invoiceNo: value.toString()),
                    );
                  } else if (settings.name == '/saleReturn') {
                    final value = settings.arguments;
                    return MaterialPageRoute(
                      builder:
                          (_) => SaleReturnScreen(
                            billNo: int.parse(value.toString()),
                          ),
                    );
                  }
                  return null;
                },
                home: SplashScreen(),
              ),
            ),
      ),
    );
  }
  void _showGlobalSessionFailedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // disables outside tap dismiss
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false, // disables back button
          child: AlertDialog(
            title: MyTextfield.textStyle_w600("Session Failed", 25, AppColors.kPrimary),
            content: MyTextfield.textStyle_w300(
              "Your account is inactive. Please contact support or log in again.",
              16,
              AppColors.kBlackColor800,
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  _dialogShown = false;
                  await SessionManager.clearSession();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => MobileLoginScreen()),
                        (route) => false,
                  );
                },
                child: MyTextfield.textStyle_w800('Login Again', 18, AppColors.kRedColor),
              ),
              TextButton(
                onPressed: () {
                  _dialogShown = false;
                  Navigator.of(context).pop(); // close the dialog
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => Webviewscreen(tittle: 'Contact Us'),
                    ),
                  );
                },
                child: MyTextfield.textStyle_w800('Contact Support', 18, AppColors.kPrimary),
              ),
            ],
          ),
        );
      },
    );
  }
}
