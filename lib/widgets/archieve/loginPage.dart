// import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:firebase_auth_project/auth.dart';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter/src/widgets/placeholder.dart';
// import 'package:get/get.dart';
// import 'package:sap_app/widgets/grocery_list.dart';
//
// import '../auth.dart';
//
// // import 'signup.dart';
//
// // final FirebaseAuth _auth = FirebaseAuth.instance;
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _loginController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//
//   // final User? user = Auth().currentUser;
//
//   // String? errorMessage = "";
//   // bool isLogin = true;
//
//   // Future<void> signOut() async {
//   //   await Auth().signOut();
//   // }
//
//   int _success = 1;
//   String _userEmail = "";
//
//   // Future<void> createUserWithLoginAndPassword() async {
//   //   try {
//   //     await Auth().createUserEmailAndPassword(
//   //         email: (_enteredLogin + "@gmail.com").toString(),
//   //         password: _enteredParol);
//
//
//   //     setState(() {
//   //       1 == 1;
//   //     });
//   //   } on FirebaseAuthException catch (e) {
//   //     setState(() {
//   //       errorMessage = e.message;
//
//   //       ScaffoldMessenger.of(context).clearSnackBars();
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(
//   //           backgroundColor: Colors.red,
//   //           content: Text(
//   //             errorMessage!,
//   //             style tStyle(fontSize: 16),
//   //           ),
//   //           duration: Duration(seconds: 1),
//   //         ),
//   //       );
//   //     });
//   //   } finally {
//   //     errorMessage = "";
//   //   }
//
//   //   setState(() {});
//   // }
//
//   // void signInWithEmailAndPassword() async {
//   //   signOut();
//   //   try {
//   //     await Auth().signInWithEmailAndPassword(
//   //         email: _loginController.text + "@gmail.com",
//   //         password: _passwordController.text);
//
//   //     errorMessage = "";
//   //     print(
//   //         "AuthStateChanges:" + Auth().authStateChanges.isBroadcast.toString());
//   //     Navigator.of(context).pushReplacement(
//   //         MaterialPageRoute(builder: (context) => GroceryList()));
//   //   } on FirebaseAuthException catch (e) {
//   //     print(
//   //         "AuthStateChanges:" + Auth().authStateChanges.isBroadcast.toString());
//   //     setState(() {
//   //       errorMessage = e.message;
//
//   //       ScaffoldMessenger.of(context).clearSnackBars();
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(
//   //           backgroundColor: Colors.red,
//   //           content: Text(
//   //             errorMessage!,
//   //             style: TextStyle(fontSize: 16),
//   //           ),
//   //           duration: Duration(seconds: 1),
//   //         ),
//   //       );
//   //     });
//   //   }
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Container(
//           child: Stack(
//             children: <Widget>[
//               Container(
//                 padding: EdgeInsets.fromLTRB(15, 110, 0, 0),
//                 child: const Text("Kirish",
//                     style:
//                         TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
//               )
//             ],
//           ),
//         ),
//         Container(
//           padding: EdgeInsets.only(top: 35, left: 20, right: 30),
//           child: Column(
//             children: <Widget>[
//               TextField(
//                 controller: _loginController,
//                 decoration: InputDecoration(
//                     labelText: 'Login',
//                     labelStyle: TextStyle(
//                         fontFamily: 'Montserrat',
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey),
//                     focusedBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: Colors.green),
//                     )),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//               TextField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(
//                     labelText: 'Parol',
//                     labelStyle: TextStyle(
//                         fontFamily: 'Montserrat',
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey),
//                     focusedBorder: UnderlineInputBorder(
//                       borderSide: BorderSide(color: Colors.green),
//                     )),
//                 obscureText: true,
//               ),
//               SizedBox(
//                 height: 5.0,
//               ),
//               Container(
//                   alignment: Alignment.center,
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Text(
//                     _success == 1
//                         ? ''
//                         : (_success == 2
//                             ? 'Successfully signed in ' + _userEmail
//                             : 'Sign in failed'),
//                     style: TextStyle(color: Colors.red),
//                   )),
//               SizedBox(
//                 height: 40,
//               ),
//               Container(
//                 height: 40,
//                 child: Material(
//                   borderRadius: BorderRadius.circular(20),
//                   shadowColor: Colors.greenAccent,
//                   color: Colors.black,
//                   elevation: 7,
//                   child: TextButton(
//                       onPressed: () async {
//                         // signInWithEmailAndPassword();
//                       },
//                       child: Center(
//                           child: Text('LOGIN',
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                   fontFamily: 'Montserrat')))),
//                 ),
//               ),
//               SizedBox(
//                 height: 15,
//               ),
//             ],
//           ),
//         )
//       ],
//     ));
//   }
// }
