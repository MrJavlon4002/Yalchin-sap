import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sap_app/providers/user_provider.dart';
import 'package:sap_app/widgets/archieve/loginPage.dart';

import 'loginPage.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  String? _errorMessage;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool _isSubmitting = false; // To control the submission state

  void _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      final username = _usernameController.text;
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;

      if (password != confirmPassword) {
        setState(() {
          _errorMessage = 'Parollar bir xil emas';
        });
        return;
      }

      // Check if the username already exists
      bool userExists = ref.read(usersProvider.notifier).checkLogin(username);
      if (userExists) {
        setState(() {
          _errorMessage = '"Bunday login bilan user yaratilgan!"';
        });
        return;
      }

      setState(() {
        _isSubmitting = true;
        _errorMessage = null; // Clear any previous error message
      });

      // Register the new user
      bool success = await ref.read(usersProvider.notifier).addUser(username, password, false);

      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        // Show success message
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Bajarildi'),
            content: Text('Siz muvofaqiyatli ro\'yxatdan o\'tdingiz!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the success dialog
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                      LoginScreen()), (Route<dynamic> route) => false);// Navigate to login page
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Handle registration failure
        setState(() {
          _errorMessage = 'Xato ketdi. Iltimos qaytadan urunib ko\'ring';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        // title: Text('Register'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              // padding: EdgeInsets.fromLTRB(15, 110, 0, 0),
              child: const Text("Registratsiya",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: 'Username'),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length > 50 ||
                          value.trim().length < 5) {
                        return "Login belgilar soni 5 tadan 50 tagacha bo'lishi kerak!";
                      }
                      return null;
                    },
                    // onSaved: (value) {
                    //   // if (value==null){
                    //   //   return "";
                    //   // }
                    //   _enteredLogin = value!;
                    // },
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Parol',
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                        icon: Icon(isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                    ),
                    obscureText: isPasswordVisible,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length > 50 ||
                          value.trim().length < 6) {
                        return "Parolni belgilar soni 6 tadan 50 tagacha bo'lishi kerak!";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.done,
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Parolni tasdiqlash',
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isConfirmPasswordVisible =
                            !isConfirmPasswordVisible;
                          });
                        },
                        icon: Icon(isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                    ),
                    obscureText: isConfirmPasswordVisible,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length > 50 ||
                          value.trim().length < 6) {
                        return "Parolni belgilar soni 6 tadan 50 tagacha bo'lishi kerak!";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  SizedBox(height: 20),
                  Container(
                    height: 40,
                    child: Material(
                      borderRadius: BorderRadius.circular(20),
                      shadowColor: Colors.greenAccent,
                      color: Colors.black,
                      elevation: 7,
                      child: InkWell(
                        onTap: _isSubmitting ? null : _register,
                        child: Center(
                          child: _isSubmitting
                              ? CircularProgressIndicator()
                              : Text('Registratsiya',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat')),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
