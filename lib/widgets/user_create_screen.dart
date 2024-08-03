// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sap_app/providers/user_provider.dart';

import '../models/user.dart';
import 'auth.dart';

class UserCreateScreen extends ConsumerStatefulWidget {
  const UserCreateScreen({super.key});

  @override
  ConsumerState<UserCreateScreen> createState() => _UserCreateScreenState();
}

class _UserCreateScreenState extends ConsumerState<UserCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  var _isSending = false;
  var __isLoading = false;
  var _enteredLogin;
  var _enteredParol;
  var _isChecked = false;

  var usersList = [];

  @override
  void initState() {
    // TODO: implement initState
    ref.read(usersProvider.notifier).loadedAllUsers();
    // print("Loged In User: " + Auth.logedInUser.toString());
    super.initState();
  }

  String? errorMessage = "";

  void _deleteUser(String login, String password, bool isAdmin) async {
    try {
      bool isDone = await ref.read(usersProvider.notifier).deleteUser(login);
      // print(ref.read(usersProvider));
      if (isDone) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.blue,
            content: Text(
              "User o'chirildi!",
              style: TextStyle(fontSize: 16),
            ),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "User o'chirilmadi!",
              style: TextStyle(fontSize: 16),
            ),
            duration: Duration(seconds: 1),
          ),
        );
        print("User ochirilmadi!");
        setState(() {
          ref.read(usersProvider.notifier).addUser(login, password, isAdmin);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Nosozlik yuz berdi!",
            style: TextStyle(fontSize: 16),
          ),
          duration: Duration(seconds: 1),
        ),
      );
      print("ERROR: " + e.toString());
    }
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _isSending = true;
      setState(() {
        _isSending = true;
      });
      _formKey.currentState!.save();

      if (_isChecked)
        print("Yangi Admin accounti yaratildi!");
      else {
        print("Yangi Oddiy Employee accounti yaratildi!");
      }

      try {
        bool isExisted =
            ref.read(usersProvider.notifier).checkLogin(_enteredLogin);

        if (isExisted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                "Bunday login bilan user yaratilgan!",
                style: TextStyle(fontSize: 16),
              ),
              duration: Duration(seconds: 1),
            ),
          );
          // print(isExisted);
        } else {
          ref
              .read(usersProvider.notifier)
              .addUser(_enteredLogin, _enteredParol, _isChecked);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              errorMessage!,
              style: TextStyle(fontSize: 16),
            ),
            duration: Duration(seconds: 1),
          ),
        );
        ref.read(usersProvider);
      }

      // final url = Uri.https('shoppinglist-e99e0-default-rtdb.firebaseio.com',
      //     'shopping-list.json');

      setState(() {
        _isSending = false;
      });
    }
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    // setState(() {
    //   ref.watch(usersProvider.notifier).loadedAllUsers();
    // });
    usersList = ref.watch(usersProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Text("Yangi User qo'shish"),
      ),
      body: ListView(
        padding: EdgeInsets.all((MediaQuery.of(context).size.width / 100) * 5),
        children: [
          Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    maxLength: 50,
                    decoration: const InputDecoration(
                      label: Text('Loginni kirting'),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length > 50 ||
                          value.trim().length < 5) {
                        return "Login belgilar soni 5 tadan 50 tagacha bo'lishi kerak!";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      // if (value==null){
                      //   return "";
                      // }
                      _enteredLogin = value!;
                    },
                  ),
                  TextFormField(
                    maxLength: 50,
                    decoration: const InputDecoration(
                      label: Text('Parolni kiriting'),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length > 50 ||
                          value.trim().length < 6) {
                        return "Parolni belgilar soni 6 tadan 50 tagacha bo'lishi kerak!";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      // if (value==null){
                      //   return "";
                      // }
                      _enteredParol = value!;
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Admin qilaman",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Checkbox(
                            checkColor: Colors.white,
                            fillColor:
                                MaterialStateProperty.resolveWith(getColor),
                            value: _isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                _isChecked = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: _isSending
                                ? null
                                : () {
                                    _formKey.currentState!.reset();
                                  },
                            child: const Text("Tozalash"),
                          ),
                          ElevatedButton(
                            onPressed: _isSending ? null : _saveItem,
                            child: _isSending
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(),
                                  )
                                : const Text("Qo'shish"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              )),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            height: 2,
            color: Colors.black,
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Column(
          children: [
            const Text(
              "Yaratilgan userlar ro'yxati: ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
            const Divider(
              height: 2,
              color: Colors.black,
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Text(
                  "Admin/Ishchi -> ",
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(
                  Icons.supervisor_account_outlined,
                  color: Colors.red,
                ),
                Text(
                  "/",
                  style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Icon(
                  Icons.account_circle_outlined,
                  color: Colors.blue,
                ),
              ],
            ),
            ListTile(
              leading: Text(
                "Loginlar: ",
                style: TextStyle(fontSize: 16),
              ),
              trailing: Text(
                "Parollar: ",
                style: TextStyle(fontSize: 16),
              ),
            )
          ],
            ),
          ),
          ...usersList.map((e) {
            User? currentUser= Auth.logedInUser as User?;
            print(currentUser);
            
            return currentUser?.login==e.login ? SizedBox() :   Container(
              child: Column(
                children: [
                  Divider(
                    height: 2,
                    color: Colors.black,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Dismissible(
                      key: ValueKey(e.login),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        _deleteUser(e.login, e.password, e.isAdmin);
                      },
                      
                      background: Container(
                        alignment: Alignment.centerRight,
                        color: Colors.red,
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      child: ListTile(
                        title: Text(e.login),
                        leading: e.isAdmin
                            ? Icon(
                                Icons.supervisor_account_outlined,
                                color: Colors.red,
                              )
                            : Icon(
                                Icons.account_circle_outlined,
                                color: Colors.blue,
                              ),
                        trailing: Text(e.password),
                      )),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
