// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:sap_app/home_screen.dart';
import 'package:sap_app/widgets/archieve/loginPage.dart';
import 'package:sap_app/widgets/splash_screen.dart';
import 'firebase_options.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if (kIsWeb)

  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // useMaterial3: true,
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.lightBlue,
        iconTheme: IconThemeData(color: Colors.lightBlue),
        textTheme: TextTheme(
          headlineMedium: TextStyle(color: Colors.white)
        )
      ),
      home: SplashScreen(),
    );
  }
}
