// import 'package:firebase_auth/firebase_auth.dart';

import '../models/user.dart';

class Auth {
  // final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // User? get currentUser => _firebaseAuth.currentUser;

  // Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  static User? logedInUser;

  // Future<void> signInWithEmailAndPassword({
  //   required String email,
  //   required String password,
  // }) async {
    

  //   logedInUser = (await _firebaseAuth.signInWithEmailAndPassword(
  //     email: email,
  //     password: password,
  //   )).user;
  // }

  // Future<void> createUserEmailAndPassword({
  //   required String email,
  //   required String password,
  // }) async {
  //   await _firebaseAuth.createUserWithEmailAndPassword(
  //     email: email,
  //     password: password,
  //   );
  // }

  // Future<void> signOut() async {
  //   await _firebaseAuth.signOut();
  // }

  void signOut(){
    logedInUser = null;
  }

  void signIn(User user){
    logedInUser = user;
    
  }
}
