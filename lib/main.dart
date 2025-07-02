import 'package:pixidrugs/HomePageScreen.dart';
import 'package:pixidrugs/SplashScreen.dart';
import 'package:pixidrugs/constant/all.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        },
        onGenerateRoute: (settings) {
          /*if (settings.name == '/detail' || settings.name == '/slot') {
            final doctor = settings.arguments as DoctorModel;
            return MaterialPageRoute(
              builder: (_) => DetailsScreen(type: AppString.Doctor, data: doctor,slot:settings.name == '/slot'),
            );
          }
         */
          return null;
        },
        home: SplashScreen(),
      )
    );
  }

}
