import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sap_app/providers/brand_provider.dart';
import 'package:sap_app/providers/category_provider.dart';
import 'package:sap_app/providers/model_provider.dart';
import 'package:sap_app/providers/product_provider.dart';
import 'package:sap_app/widgets/load_from_excel_screen.dart';
import 'package:sap_app/widgets/new_brand_screen.dart';
import 'package:sap_app/widgets/new_model_screen.dart';
// import 'package:sap_app/widgets/archieve/loginPage.dart';
import 'package:sap_app/widgets/user_create_screen.dart';

import 'auth.dart';
import 'loginPage.dart';
import 'new_category.dart';
import 'new_item.dart';

class DrawerScreen extends ConsumerStatefulWidget {
  const DrawerScreen({super.key});

  @override
  ConsumerState<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends ConsumerState<DrawerScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    ref.read(modelsProvider.notifier).loadModelList();
    ref.read(brandsProvider.notifier).loadBrandList();
    ref.read(categoriesProvider.notifier).loadAllCategories();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(productsProvider);
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  (Auth.logedInUser!.isAdmin) ? "Admin Panel".toUpperCase() : "User Menu".toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue,
                  ),
                ),
              ),
            ),
            if (Auth.logedInUser!.isAdmin) Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 1, color: Color.fromARGB(255, 176, 176, 176)),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => UserCreateScreen()));
                    },
                    child: ListTile(
                      title: Text(
                        "User Yaratish",
                        style: TextStyle(fontSize: 16),
                      ),
                      leading: Icon(Icons.supervisor_account_outlined,  color: Colors.lightBlue,),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 1, color: Color.fromARGB(255, 176, 176, 176)),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => NewCategory()));
                    },
                    child: ListTile(
                        title: Text(
                          "Kategoriya yaratish",
                          style: TextStyle(fontSize: 16),
                        ),
                        leading: Icon(Icons.category_outlined,  color: Colors.lightBlue,)),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 1, color: Color.fromARGB(255, 176, 176, 176)),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => NewBrandScreen()));
                    },
                    child: const ListTile(
                      title: Text(
                        "Brand yaratish",
                        style: TextStyle(fontSize: 16),
                      ),
                      leading: Icon(Icons.copyright_outlined, color: Colors.lightBlue,),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 1, color: Color.fromARGB(255, 176, 176, 176)),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => NewModelScreen()));
                    },
                    child: const ListTile(
                      title: Text(
                        "Model yaratish",
                        style: TextStyle(fontSize: 16),
                      ),
                      leading: Icon(Icons.mode_outlined,  color: Colors.lightBlue,),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 1, color: Color.fromARGB(255, 176, 176, 176)),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => NewItem()));
                      // Navigator.of(context).pop();
                    },
                    child: ListTile(
                      title: Text(
                        "Mahsulot qo'shish",
                        style: TextStyle(fontSize: 16),
                      ),
                      leading: Icon(Icons.add,  color: Colors.lightBlue,),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 1, color: Color.fromARGB(255, 176, 176, 176)),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => LoadFromExcelScreen()));
                      // Navigator.of(context).pop();
                    },
                    child: ListTile(
                      title: Text(
                        "CSV dan import qilish",
                        style: TextStyle(fontSize: 16),
                      ),
                      leading: Icon(Icons.table_view_rounded,  color: Colors.lightBlue,),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                    width: 1, color: Color.fromARGB(255, 176, 176, 176)),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
                child: ListTile(
                  leading: Icon(Icons.exit_to_app,  color: Colors.lightBlue,),
                  title: Text(
                    "Accountdan chiqish",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
