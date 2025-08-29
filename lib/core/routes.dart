// import 'package:flutter/material.dart';
// import 'package:ttms_app/screens/modules/auth/loginScreen/login.dart';
// import 'package:ttms_app/screens/modules/auth/registerScreen/register_screen.dart';
// import 'package:ttms_app/screens/modules/auth/welcome_screen.dart';
// import 'package:ttms_app/screens/modules/splash_screen/splash_screen.dart';
// import '../modules/survey_module/splash_screen.dart';
// import '../screens/modules/dashboard/dashboard.dart';
// import '../screens/modules/home/home_screen.dart';
// import '../screens/modules/feedback/feedback_screen.dart';
// import '../screens/modules/pre_test/test_screen.dart';
// import '../screens/modules/registration/add_info/add_info_screen.dart';
// import '../screens/modules/registration/training_register/training_detail.dart';
// import '../screens/modules/registration/training_register/training_detail_scan.dart';
// import '../screens/modules/registration/add_info/traning_register.dart';
// import '../screens/modules/session/session_screen.dart';
// import '../screens/modules/trainings/trainings_screen.dart';
// import '../services/internet_connectivity.dart';
//
// class Routes {
//   ///1) All Routs Path...
//   static const String initialRoute = '/';
//   static const String welcome = 'welcome';
//   static const String auth = 'login';
//   static const String register = 'register';
//   static const String home = 'home';
//   static const String dashboard = 'dashboard';
//   static const String trainingDetailScan = 'training_detail_scan';
//   static const String preTest = 'preTest';
//   static const String trainings = 'trainings';
//   static const String trainingRegister = 'training_register';
//   static const String addInfo = 'add_info';
//   static const String sessions = 'sessions';
//   static const String feedback = 'feedback';
//   static const String trainingDetail = 'training_detail';
//
//   static Widget initialRoutScreen() {
//     return  SplashScreen();
//     // return const FeedbackScreen();
//
//   }
//
//   ///2.1) Generate Routs from Path...
//   static Route<dynamic> generateRoute(RouteSettings settings) {
//     final arguments = settings.arguments;
//     switch (settings.name) {
//       case initialRoute:
//         return materialPageRoute(route: initialRoutScreen());
//
//       case welcome:
//         return PageTransitions.pageTransition(route: const WelcomeScreen());
//
//       case auth:
//         return PageTransitions.pageTransition(route: const LoginPage());
//
//       case register:
//         return PageTransitions.pageTransition(route: const RegisterScreen());
//
//       case home:
//       // return PageTransitions.pageTransition(route: ConnectivityListener(child: HomeScreen()));
//         return PageTransitions.pageTransition(route: HomeScreen());
//       case dashboard:
//         return PageTransitions.pageTransition(route: DashBoard());
//
//       case trainingDetailScan:
//         return PageTransitions.pageTransition(route: const TrainingDetailScan());
//
//       case preTest:
//         PreTestScreen? data = arguments as dynamic;
//         return PageTransitions.pageTransition(route:  PreTestScreen( trainingID: data?.trainingID ?? "", questionMode: data?.questionMode ?? '',));
//
//       case trainings:
//         TrainingsScreen? data = arguments as dynamic;
//         return PageTransitions.sizeTransition4(route:  TrainingsScreen( screenTab: data!.screenTab,cardTab: data.cardTab,trainingID: data.trainingID,));
//
//     // case trainingRegister:
//     //   TrainingRegister? data = arguments as dynamic;
//     // return PageTransitions.sizeTransition4(route:  TrainingRegister(trainingID: data?.trainingID ?? '',));
//
//     // case addInfo:
//     //   AddInfoScreen? data = arguments as dynamic;
//     // return PageTransitions.sizeTransition4(route:  AddInfoScreen( trainingID: data!.trainingID , empID:data!.empID , Mobile:data!.Mobile ,));
//
//       case sessions:
//         SessionScreen? data = arguments as dynamic;
//         return PageTransitions.sizeTransition4(route:  SessionScreen(  trainingID: data?.trainingID ?? '', cardTab: data?.cardTab ?? '',));  case sessions:
//
//       case feedback:
//         FeedbackScreen? data = arguments as dynamic;
//         return PageTransitions.sizeTransition4(route:  FeedbackScreen(trainingID: data?.trainingID ?? "", questionMode: data?.questionMode ?? '',));
//       case trainingDetail:
//         TrainingDetail? data = arguments as dynamic;
//         return PageTransitions.sizeTransition4(route:  TrainingDetail(scannedResult: data?.scannedResult ?? '',));
//
//       default:
//         return materialPageRoute(route: unknownRout(settings));
//     }
//   }
//
//   ///3)  Unknown Route...
//
//   static Scaffold unknownRout(RouteSettings settings) {
//     return Scaffold(
//       body:
//       Center(child: Text('No Route defined for unknown  ${settings.name}')),
//     );
//   }
//
//   ///4)  Material Page Route...
//
//   static MaterialPageRoute<dynamic> materialPageRoute(
//       {required Widget route}) =>
//       MaterialPageRoute(builder: (context) => route);
//
//   static void pushAndRemoveUntil(BuildContext context, String routeName, {Object? arguments}) {
//     Navigator.pushAndRemoveUntil(
//       context,
//       generateRoute(RouteSettings(name: routeName, arguments: arguments)), // Pass arguments
//           (Route<dynamic> route) => false,
//     );
//   }
//
//   static void push(BuildContext context, String routeName, {Object? arguments}) {
//     Navigator.push(
//       context,
//       generateRoute(RouteSettings(name: routeName, arguments: arguments)), // Pass arguments
//     );
//   }
//
//   static void pushReplacement(BuildContext context, String routeName, {Object? arguments}) {
//     Navigator.pushReplacement(
//       context,
//       generateRoute(RouteSettings(name: routeName, arguments: arguments)), // Pass arguments
//     );
//   }
//
// // static void push(BuildContext context, String routeName) {
// //   Navigator.push(
// //     context,
// //     generateRoute(RouteSettings(name: routeName)),
// //   );
// // }
//
// }
//
// ///Animated Screen Transition
// class PageTransitions {
//   static PageRouteBuilder<dynamic> pageTransition({
//     required Widget route,
//     Duration? transitionDuration,
//   }) {
//     return PageRouteBuilder(
//       pageBuilder: (context, animation, anotherAnimation) => route,
//       transitionDuration:
//       transitionDuration ?? const Duration(milliseconds: 2000),
//       transitionsBuilder: (context, animation, anotherAnimation, child) {
//         animation = CurvedAnimation(
//           curve: Curves.fastLinearToSlowEaseIn,
//           parent: animation,
//         );
//         return Align(
//           alignment: Alignment.bottomCenter,
//           child: SizeTransition(
//             sizeFactor: animation,
//             child: route,
//             axisAlignment: 0,
//           ),
//         );
//       },
//     );
//   }
//
//   static PageRouteBuilder<dynamic> sizeTransition1({
//     required Widget route,
//     Duration? transitionDuration,
//   }) {
//     return PageRouteBuilder(
//       pageBuilder: (context, animation, anotherAnimation) => route,
//       transitionDuration:
//       transitionDuration ?? const Duration(milliseconds: 2000),
//       reverseTransitionDuration: const Duration(milliseconds: 200),
//       transitionsBuilder: (context, animation, anotherAnimation, child) {
//         animation = CurvedAnimation(
//             curve: Curves.fastLinearToSlowEaseIn,
//             parent: animation,
//             reverseCurve: Curves.fastOutSlowIn);
//         return Align(
//           alignment: Alignment.bottomCenter,
//           child: SizeTransition(
//             sizeFactor: animation,
//             axisAlignment: 0,
//             child: route,
//           ),
//         );
//       },
//     );
//   }
//
//   static PageRouteBuilder<dynamic> sizeTransition2({
//     required Widget route,
//     Duration? transitionDuration,
//   }) {
//     return PageRouteBuilder(
//       pageBuilder: (context, animation, anotherAnimation) => route,
//       transitionDuration:
//       transitionDuration ?? const Duration(milliseconds: 1000),
//       reverseTransitionDuration: const Duration(milliseconds: 200),
//       transitionsBuilder: (context, animation, anotherAnimation, child) {
//         animation = CurvedAnimation(
//             curve: Curves.fastLinearToSlowEaseIn,
//             parent: animation,
//             reverseCurve: Curves.fastOutSlowIn);
//         return Align(
//           alignment: Alignment.topCenter,
//           child: SizeTransition(
//             sizeFactor: animation,
//             axisAlignment: 0,
//             child: route,
//           ),
//         );
//       },
//     );
//   }
//
//   static PageRouteBuilder<dynamic> sizeTransition3({
//     required Widget route,
//     Duration? transitionDuration,
//   }) {
//     return PageRouteBuilder(
//       pageBuilder: (context, animation, anotherAnimation) => route,
//       transitionDuration: const Duration(milliseconds: 1000),
//       reverseTransitionDuration: const Duration(milliseconds: 200),
//       transitionsBuilder: (context, animation, anotherAnimation, child) {
//         animation = CurvedAnimation(
//             curve: Curves.fastLinearToSlowEaseIn,
//             parent: animation,
//             reverseCurve: Curves.fastOutSlowIn);
//         return Align(
//           alignment: Alignment.center,
//           child: SizeTransition(
//             axis: Axis.horizontal,
//             sizeFactor: animation,
//             axisAlignment: 0,
//             child: route,
//           ),
//         );
//       },
//     );
//   }
//
//   static PageRouteBuilder<dynamic> sizeTransition4({
//     required Widget route,
//     Duration? transitionDuration,
//   }) {
//     return PageRouteBuilder(
//       pageBuilder: (context, animation, anotherAnimation) => route,
//       transitionDuration: const Duration(milliseconds: 1000),
//       reverseTransitionDuration: const Duration(milliseconds: 200),
//       transitionsBuilder: (context, animation, anotherAnimation, child) {
//         animation = CurvedAnimation(
//             curve: Curves.fastLinearToSlowEaseIn,
//             parent: animation,
//             reverseCurve: Curves.fastOutSlowIn);
//         return Align(
//           alignment: Alignment.centerLeft,
//           child: SizeTransition(
//             axis: Axis.horizontal,
//             sizeFactor: animation,
//             axisAlignment: 0,
//             child: route,
//           ),
//         );
//       },
//     );
//   }
//
//   static PageRouteBuilder<dynamic> sizeTransition5({
//     required Widget route,
//     Duration? transitionDuration,
//   }) {
//     return PageRouteBuilder(
//       pageBuilder: (context, animation, anotherAnimation) => route,
//       transitionDuration: const Duration(milliseconds: 1000),
//       reverseTransitionDuration: const Duration(milliseconds: 200),
//       transitionsBuilder: (context, animation, anotherAnimation, child) {
//         animation = CurvedAnimation(
//             curve: Curves.fastLinearToSlowEaseIn,
//             parent: animation,
//             reverseCurve: Curves.fastOutSlowIn);
//         return Align(
//           alignment: Alignment.centerRight,
//           child: SizeTransition(
//             axis: Axis.horizontal,
//             sizeFactor: animation,
//             axisAlignment: 0,
//             child: route,
//           ),
//         );
//       },
//     );
//   }
// }
