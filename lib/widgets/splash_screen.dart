// import 'package:assignment_skeleton/ui/home_screen.dart';
import 'package:flutter/material.dart';

import 'loginPage.dart';
// import 'package:sap_app/widgets/archieve/loginPage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);


  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController controller;
  @override
  void initState(){

    this.controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
      setState(() {});
    });


    _navigateToHome();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  _navigateToHome()async{
    await Future.delayed(Duration(milliseconds: 3000), (){});
    controller.stop();
    // dispose();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> LoginScreen(),
    ));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.bottomCenter,
        // color: Colors.orange,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/splash_screen_full.jpg"),
            fit: BoxFit.contain,
          ),
        ),
        child:  Container(
          margin: EdgeInsets.only(bottom: 40),
          child: CircularProgressIndicator(
            value: controller.value,
            color: Colors.red,
            // semanticsLabel: 'Circular progress indicator',
          ),
        ),
      ),
    );
  }
}

