import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:newsroom/HomeScreen.dart';
import 'package:newsroom/loginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // Simulate a delay, replace with actual logic to check the token
    await Future.delayed(Duration(seconds: 2));

    if (token != null) {
      // User is logged in, navigate to NewsRoom
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Homescreen()),
      );
    } else {
      // User is not logged in, navigate to LoginPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Image(
              image: AssetImage('assets/images/logo.png'), // Replace with your image path
              width: 250,
            ),
             SizedBox(height: 14.h,),
             Padding(
               padding:  EdgeInsets.symmetric(horizontal: 20.w),
               child: Text(
                'All types of news from all trusted sources for all type of people',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.normal),
                 textAlign: TextAlign.center,
                           ),
             ),
          ],
        ),
      ),
    );
  }
}