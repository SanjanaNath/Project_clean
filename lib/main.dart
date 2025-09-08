import 'package:flutter/material.dart';
import 'package:project_clean/controllers/admin_dashboard_controller.dart';
import 'package:project_clean/controllers/auth_controller.dart';
import 'package:project_clean/modules/survey_module/splash_screen.dart';
import 'package:project_clean/services/local_database.dart';
import 'package:provider/provider.dart';
import 'package:project_clean/modules/survey_module/register_screen.dart';
import 'package:project_clean/modules/survey_module/login_screen.dart';
import 'package:project_clean/utils/color_constants.dart';
import 'controllers/screens_controller.dart';
import 'modules/admin_panel/dashboard.dart';
import 'modules/admin_panel/hostel_detail/hostel_detail_screen.dart';
import 'modules/admin_panel/hostel_detail/hostel_list_screen.dart';
import 'modules/admin_panel/officers_detail/officer_List_screen.dart';
import 'modules/admin_panel/officers_detail/officer_detail_screen.dart';
import 'modules/survey_module/home_screen.dart';
import 'modules/survey_module/report_screen.dart';


Future<void> main() async {
  await LocalDatabase.initialize();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScreenController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => DashboardController()),
      ],
      child: const MyApp(),
    ),
  );
  // runApp(
  //   DevicePreview(
  //     enabled: !bool.fromEnvironment('dart.vm.product'), // Enable only in debug mode
  //     builder: (context) => const MyApp(), // Wrap your app
  //   ),
  // );
}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hostel Inspection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFFFF),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF333333),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Color(0xFF333333)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFFFFFF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: ColorConstants().teal, width: 2.0),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorConstants().teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
     navigatorKey: navigatorKey,
      initialRoute: "/splash",
      onGenerateRoute: (settings) {
        final arguments = settings.arguments;
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          case '/home':
            return MaterialPageRoute(builder: (_) => HomeScreen());
          case '/report':
            return MaterialPageRoute(builder: (_) => ReportScreen());
          case '/splash':
            return MaterialPageRoute(builder: (_) => SplashScreen());
          case '/adminDashboard':
            return MaterialPageRoute(builder: (_) => AdminDashboard());
          case '/officerList':
            return MaterialPageRoute(builder: (_) => OfficerListScreen());
          case '/officerDetail':
            OfficerDetailScreen? data = arguments as dynamic;
            return MaterialPageRoute(
              builder: (_) => OfficerDetailScreen(officerID: data?.officerID ?? '', officerName: data?.officerName ?? '', officerNo: data?.officerNo ?? '',)
            );
            case '/hostelList':
            return MaterialPageRoute(builder: (_) => HostelListScreen());

          case '/hostelDetail':
            HostelDetailScreen? data = arguments as dynamic;
            return MaterialPageRoute(
                builder: (_) => HostelDetailScreen(hostelID: data?.hostelID ?? '', hostelName: data?.hostelName ?? '', hostelTotalVisits: data?.hostelTotalVisits ?? '',)
            );
          default:
            return MaterialPageRoute(builder: (_) => const Text('Error: Unknown Route'));
        }
      },
    );
  }
}
