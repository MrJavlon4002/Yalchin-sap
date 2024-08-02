// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_auth_project/auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sap_app/providers/category_provider.dart';
// import 'package:get/get.dart';
import 'package:sap_app/providers/user_provider.dart';
import 'package:sap_app/widgets/auth.dart';
import 'package:sap_app/widgets/grocery_list.dart';

import '../models/user.dart';
import '../providers/product_provider.dart';

import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;

// import 'signup.dart';

// final FirebaseAuth _auth = FirebaseAuth.instance;
List<String> categoriesGlobal = ["TANLANMAGAN"];

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Database? _db;
  List<User> _existingUsers = [];

  @override
  void initState() {
    // TODO: implement initState
    _existingUsers.clear();
    ref.read(productsProvider.notifier).loadItems();

    // print(ref.read(usersProvider));
    super.initState();
    loadDb();
  }

  String? errorMessage = "";
  bool isLogin = true;
  bool _isWithStoredAccount = false;
  String _existedUserLogin = "";

  int _success = 1;
  String _userEmail = "";

  Future<Database> _getDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    final db = await sql.openDatabase(
      path.join(dbPath, 'sap_app.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE users(id TEXT PRIMARY KEY, login TEXT, password TEXT, isAdmin BIT)');
      },
      version: 1,
    );

    return db;
  }

  Future<void> showStoredAccounts() async {
    String? _groupValue = null;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(
              vertical: 0,
              horizontal: (MediaQuery.of(context).size.width * 5) / 100),
          // <-- SEE HERE
          actionsAlignment: MainAxisAlignment.center,
          title: const Text('Login:'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                ..._existingUsers.map(
                  (e) {
                    return ListTile(
                      onTap: () {
                        setState(() {
                          _existedUserLogin = e.login + ":" + e.password;
                          _isWithStoredAccount = true;
                        });
                        Navigator.of(context).pop();
                      },
                      leading: Icon(
                        e.isAdmin
                            ? Icons.supervisor_account_outlined
                            : Icons.account_circle_outlined,
                        color: e.isAdmin ? Colors.red : Colors.blue,
                      ),
                      title: Text(e.login),
                      trailing: Text(e.password),
                    );
                  },
                )
                // ListTile(leading: Text(_existingUsers),)
              ],
            ),
          ),

          actions: <Widget>[
            TextButton(
              child: Icon(
                Icons.cancel_outlined,
                color: Colors.red,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isWithStoredAccount = false;
                });
              },
            ),

            // TextButton(
            //   child: Icon(Icons.check, color: Colors.blue,),
            //   onPressed: () {
            //     Navigator.of(context).pop();
            //     setState(() {
            //       _isWithStoredAccount = true;
            //       _existedUserLogin = _groupValue!;
            //       // _loginController.text =

            //     });
            //   },
            // ),
          ],
        );
      },
    );
  }

  void loadDb() async {
    await ref.read(usersProvider.notifier).loadedAllUsers();

    final db = await _getDatabase();
    final data = await db.query('users');
    print("========================");
    print(data.toString());

    setState(() {
      _db = db;
    });
    // db.delete("users", where: "login = ?", whereArgs: ["admin8"]);
    List<Map<String, dynamic>> listOfUsers = await db.query("users");
    print("----------------------------------");
    _existingUsers = [];
    List<User> existingUsers = [];

    for (var el in listOfUsers) {
      existingUsers.add(User(
          id: el['id'] as String,
          isAdmin: (el['isAdmin'] as int) == 1 ? true : false,
          login: el["login"] as String,
          password: el["password"] as String));

      print(el.values);
    }
    print("----------------------------------");

    print(_existingUsers);

    existingUsers = existingUsers.where((el) {
      return ref
          .read(usersProvider.notifier)
          .checkIfExist(el.login, el.password);
    }).toList();

    setState(() {
      _existingUsers = existingUsers;
    });

    if (_existingUsers.isNotEmpty) {
      await showStoredAccounts();
    }

    if (_isWithStoredAccount) {
      setState(() {
        _loginController.text = _existedUserLogin.split(":")[0];
        _passwordController.text = _existedUserLogin.split(":")[1];
      });
      // signInWithLoginAndPassword();
    }
    // data.map((row) {
    //   ProductItem(
    //     id: row['id'] as String,
    //     name: row['name'] as String,
    //     currency: row['currency'] as String,
    //     boxCount: row['boxCount'] as int,
    //     description: row['description'] as String,
    //     price: row['price'] as int,
    //     category: row['category'] as String,
    //     quantity: row['quantity'] as int,
    //     model: row['model'] as String,
    //     brand: row['brand'] as String,
    //     submitTime: row["submitTime"] as String,
    //     color: Color(row['color'] as int),
    //     factionList: [],
    //     imageUrl: row['imageUrl'] as String,
    //   );
    // });
  }

  Future<int> addEntryToDB(User user) async {
    int id = -1;

    _existingUsers.forEach((us) {
      if (us.login == user.login) return;
    });

    try {
      int id = await _db!.insert("users", {
        "id": user.id,
        "login": user.login,
        "password": user.password,
        "isAdmin": user.isAdmin
      });
    } catch (e) {
      print("LoginPageRelatedError: " + id.toString());
      return -1;
    }

    print(id);

    return id;
  }

  void signInWithLoginAndPassword() async {
    print("hello");
    try {
      bool isExisted = ref
          .read(usersProvider.notifier)
          .checkIfExist(_loginController.text, _passwordController.text);
      print(ref.read(usersProvider));
      print("IsExisted: " + isExisted.toString());

      categoriesGlobal =
          await ref.read(categoriesProvider.notifier).getHeadNames();

      if (isExisted) {
        ref.read(usersProvider.notifier).signIn(_loginController.text);
        Auth.logedInUser = ref
            .read(usersProvider)
            .firstWhere((element) => element.login == _loginController.text);
        int res = await addEntryToDB(Auth.logedInUser!);
        if (res != -1) {
          print("Success");
        }

        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => GroceryList()));
      } else {
        setState(() {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                "Login yoki password nato'g'ri",
                style: TextStyle(fontSize: 16),
              ),
              duration: Duration(seconds: 1),
            ),
          );
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        print(errorMessage);

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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ref.watch(usersProvider);
    return Scaffold(
        body: ListView(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          child: Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(15, 110, 0, 0),
                child: const Text("Kirish",
                    style:
                        TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 35, left: 20, right: 30),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _loginController,
                decoration: const InputDecoration(
                    labelText: 'Login',
                    labelStyle: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    )),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                    labelText: 'Parol',
                    labelStyle: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    )),
                obscureText: true,
              ),
              const SizedBox(
                height: 5.0,
              ),
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _success == 1
                        ? ''
                        : (_success == 2
                            ? 'Successfully signed in ' + _userEmail
                            : 'Sign in failed'),
                    style: TextStyle(color: Colors.red),
                  )),
              SizedBox(
                height: 40,
              ),
              Container(
                height: 40,
                child: Material(
                  borderRadius: BorderRadius.circular(20),
                  shadowColor: Colors.greenAccent,
                  color: Colors.black,
                  elevation: 7,
                  child: InkWell(
                      onTap: () async {
                        print("pressed");
                        signInWithLoginAndPassword();
                      },
                      child: Center(
                          child: Text('LOGIN',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat')))),
                ),
              ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        )
      ],
    ));
  }
}
