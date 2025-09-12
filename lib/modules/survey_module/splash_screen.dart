import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:upgrader/upgrader.dart';

import '../../../../services/local_database.dart';
import 'package:flutter/material.dart';

import '../../widgets/backgroundCircles.dart';




class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const String KEYLOGIN = "Login";
  Animation<double>? animation1;
  LocalDatabase localDatabase = LocalDatabase();
  @override
  void initState() {
    super.initState();

    checkSignInStatus();
  }

  Future<void> checkSignInStatus() async {
    if (localDatabase.loginStatus == "LoggedIn") {

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(localDatabase.role == 2){
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false,);

        }if(localDatabase.role == 1){
          Navigator.pushNamedAndRemoveUntil(context, '/adminDashboard', (route) => false,);

        }
      });
    } else {

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false,);
        }
      });

    }


  }


  @override

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: BackgroundCircles(
        child: ZoomIn(
          delay: const Duration(seconds: 1),
          curve: Curves.linear,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                 "assets/images/cg.png",
                  height: size.height * 0.2,
                ),
                 Text(
                   'Hostel Inspection',
                 style: GoogleFonts.lato( fontSize: 17,
                   wordSpacing: 2,
                   fontWeight: FontWeight.w600,),
                )
              ],
            ),
          ),
        ),
      ),

    );
  }
}
