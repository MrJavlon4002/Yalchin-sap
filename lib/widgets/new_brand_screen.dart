import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:sap_app/data/app_keys.dart';
import 'package:sap_app/providers/brand_provider.dart';

class NewBrandScreen extends ConsumerStatefulWidget {
  const NewBrandScreen({super.key});

  @override
  ConsumerState<NewBrandScreen> createState() => _NewBrandScreenState();
}

class _NewBrandScreenState extends ConsumerState<NewBrandScreen> {
  var _enteredBrand;
  var _brandController = TextEditingController();
  // final _formKey = GlobalKey<FormFieldState>();
  Map<String, List<String>> brands = {};
  @override
  void initState() {
    // TODO: implement initState
    ref.read(brandsProvider.notifier).loadBrandList();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _brandController.dispose();
    super.dispose();
  }

  void _removeBrand(String itemName) async {
    try {
      ref.read(brandsProvider.notifier).removeItem(itemName);
      setState(() {
        brands = ref.watch(brandsProvider);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            e.toString(),
            style: TextStyle(fontSize: 16),
          ),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _saveBrand() async {
    if (_brandController.text == null ||
        _brandController.text.isEmpty ||
        brands.entries.first.value.any((element) =>
            element.toUpperCase() ==
            _brandController.text.trim().toUpperCase()) ||
        _brandController.text.trim().length <= 1 ||
        _brandController.text.trim().length > 200) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Brend nomi 1 va 200 belgi oralig'idagi yangi nom bo'lishi kerak",
            style: TextStyle(fontSize: 16),
          ),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      try {
        setState(() {
          ref
              .read(brandsProvider.notifier)
              .addBrand(_brandController.text.trim());
          setState(() {
            brands = ref.watch(brandsProvider);
          });
        });
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.blue,
            content: Text(
              "Brand saqlandi",
              style: TextStyle(fontSize: 16),
            ),
            duration: Duration(seconds: 1),
          ),
        );
        _brandController.text = "";
      } catch (e) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              e.toString(),
              style: TextStyle(fontSize: 16),
            ),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }

    // return null;
  }

  @override
  Widget build(BuildContext context) {
    brands = ref.watch(brandsProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text("Yangi brand turini kiritish"),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: ListView(
          children: [
            TextField(
              maxLength: 200,
              controller: _brandController,
              decoration: const InputDecoration(
                label: Text('brand nomi'),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  _saveBrand();
                },
                child: Text("yaratish")),
            // Text("data"),
            if (brands.isNotEmpty)
              ...brands.entries.first.value.map((e) {
                return Dismissible(

                    // confirmDismiss: (direction) {

                    //   return Future(() => false);
                    // },
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    onDismissed: (direction) {
                      _removeBrand(e);
                    },
                    key: UniqueKey(),
                    child: ListTile(
                      title: Text(e),
                    ));
              }),
          ],
        ),
      ),
    );
  }
}
