import 'package:flutter/foundation.dart';
import 'package:pixidrugs/Home/HomePageScreen.dart';
import 'package:pixidrugs/SplashScreen.dart';
import 'package:pixidrugs/Stock/ProductList.dart';
import 'package:pixidrugs/constant/all.dart';
import 'package:pixidrugs/login/FCMService.dart';
import 'package:pixidrugs/login/mobileLoginScreen.dart';
import 'package:pixidrugs/return/PurchaseReturnScreen.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.data['type'] == 'video') {

  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Dynamically choose the provider based on build mode
  await FirebaseAppCheck.instance.activate(
    androidProvider:
    kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
              builder: (_) => ProductListPage(flag: int.parse(flag.toString())),
            );
          }else if (settings.name == '/purchaseReturn') {
            final value = settings.arguments;
            return MaterialPageRoute(
              builder: (_) => PurchaseReturnScreen(invoiceNo: value.toString()),
            );
          }
          return null;
        },
        home: SplashScreen(),
      )
    );
  }

}
