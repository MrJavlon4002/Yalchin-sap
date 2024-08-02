import 'dart:convert';
// import 'dart:js_util';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter/rendering.dart';

import 'package:http/http.dart' as http;
import 'package:sap_app/models/product_item.dart';
import 'package:sap_app/data/categories.dart';
import 'package:sap_app/providers/category_provider.dart';
import 'package:sap_app/providers/product_provider.dart';
import 'package:sap_app/widgets/drawer_screen.dart';
import 'package:sap_app/widgets/grocery_item_card.dart';
// import 'package:sap_app/widgets/archieve/category_creating_sreen.dart';
import 'package:sap_app/widgets/new_category.dart';
import 'package:sap_app/widgets/product_detail.dart';

// import 'package:sap_app/models/grocery_item.dart';
import 'package:sap_app/widgets/new_item.dart';
import 'package:sap_app/widgets/search_page.dart';
import 'package:sap_app/widgets/single_category_view.dart';

class GroceryList extends ConsumerStatefulWidget {
  const GroceryList({super.key});

  @override
  ConsumerState<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends ConsumerState<GroceryList> {
  List<ProductItem> _ProductItems = [];
  var _isLoading = true;
  var _isListMode = false;
  var response;
  String? _error;

  @override
  void initState() {
    super.initState();

    // ref.read(productsProvider.notifier).loadItems();
    // print("productList" + ref.read(productsProvider).toString());
    ref.read(categoriesProvider.notifier).loadAllCategories();
    _loadItems();
    // if (response.toString()!='false'){
    //   // _ProductItems = response;
    // }

    // _ProductItems = ref.read(productsProvider.notifier).state;
    // _loadItems();
  }

  void _loadItems() async {
    // final url = Uri.https(
    //     'shoppinglist-e99e0-default-rtdb.firebaseio.com', 'shopping-list.json');
    try {
      List<ProductItem> productItems =
          await ref.read(productsProvider.notifier).loadItems();
      // final response = await http.get(url);
      // if (response.statusCode >= 400) {
      //   setState(() {
      //     _error = "Failed to fetch data. Please try again later.";
      //   });
      //   // return;
      // }

      if (productItems.isNotEmpty) {
        setState(() {
          _ProductItems = productItems;
        });
      }

      // if (response.body == 'null') {
      //   setState(() {
      //     // _isLoading = false;
      //   });
      //   return;
      // }

      // setState(() {
      //   _ProductItems = loadedItems;
      //   _isLoading = false;
      // });
    } catch (error) {
      print("ERROR: " + error.toString());
      setState(() {
        _error = "Something went wrong!";
      });
    }
  }

  void _addItem() async {
    print(ref.read(productsProvider));

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => NewItem()));
    // _loadItems();
  }

  void _removeItem(ProductItem item) async {
    final index = _ProductItems.indexOf(item);

    setState(() {
      _ProductItems.remove(item);
    });

    try {
      ref.read(productsProvider.notifier).removeItem(item);
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: Serverdan mahsulot o'chmadi!"),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (_ProductItems.isEmpty) ref.read(productsProvider.notifier).loadItems();
    _ProductItems = ref.watch(productsProvider);
    Widget content = const Center(
      child: Text("Hech qanday mahsulot yo'q."),
    );

    // if (_isLoading) {
    //   content = const Center(
    //     child: CircularProgressIndicator(),
    //   );
    // }

    if (_ProductItems.isNotEmpty) {
      content = _isListMode
          ? ListView.builder(
              itemCount: _ProductItems.length,
              itemBuilder: (ctx, index) => Dismissible(
                onDismissed: (direction) {
                  _removeItem(_ProductItems[index]);
                },
                key: ValueKey(_ProductItems[index].id),
                child: ListTile(
                  title: Text(_ProductItems[index].name),
                  leading: Container(
                    height: 24,
                    width: 24,
                    color: Colors.indigoAccent,
                  ),
                  trailing: Text(
                    _ProductItems[index].quantity.toString(),
                  ),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 8,
                left: 10,
                right: 10,
              ),
              child: GridView.builder(
                padding: EdgeInsets.symmetric(vertical: 10),
                itemCount: _ProductItems.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      MediaQuery.of(context).size.width >= 550 ? 3 : 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio:
                      MediaQuery.of(context).size.width >= 550 ? 0.7 : 0.5,
                ),
                itemBuilder: (context, index) {
                  print(_ProductItems[index]);
                  ProductItem product_item = _ProductItems[index];

                  return GroceryItemCard(product_item: product_item);
                },
              ),
            );
    }

    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }

    return Scaffold(
      
        // backgroundColor: Color.fromARGB(255, 217, 217, 217),
        drawer: DrawerScreen(),
        appBar: AppBar(
          backgroundColor: Colors.lightBlue,
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text("Hammasi"),
          actions: [
            // IconButton(onPressed: _addItem, icon: const Icon(Icons.add)),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SearchPage(
                          productList: _ProductItems,
                        )));
              },
              icon: Icon(Icons.search,),
            ),
            // IconButton(
            //   onPressed: () {
            //     Navigator.of(context).push(
            //         MaterialPageRoute(builder: (context) => NewCategory()));
            //   },
            //   icon: Icon(Icons.category),
            // ),
          ],
        ),
        body: Column(
          children: [
            Text("Mahsulotlar soni " + _ProductItems.length.toString()),
            // SingleCategoryView(),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _pullRefresh,
                child: content,
              ),
            ),
          ],
        ));
  }

  Future<void> _pullRefresh() async {
    List<ProductItem> products =
        await ref.read(productsProvider.notifier).loadItems();
    // final products = ref.watch(productsProvider);

    print("Updated list of products: " + products.toString());

    if ((products.isNotEmpty)) {
      // _ProductItems = [];
      setState(() {
        
        // _ProductItems = await ref.watch(productsProvider);
        _ProductItems = products;
      });
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Serverdan yuklashda xatolik!"),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
}
