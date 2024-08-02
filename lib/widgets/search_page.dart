import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sap_app/models/product_item.dart';
import 'package:sap_app/widgets/filter_category_page.dart';
import 'package:sap_app/widgets/grocery_item_card.dart';
import 'package:sap_app/widgets/product_detail.dart';

import 'filter_page.dart';

class SearchPage extends StatefulWidget {
  final List<ProductItem> productList;

  const SearchPage({required this.productList});

  @override
  State<SearchPage> createState() {
    // TODO: implement createState
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  List<ProductItem> resultList = [];
  final searchController = TextEditingController();

  void _showFilteredList() async {
    List<ProductItem>? res = await Navigator.of(context)
        .push<List<ProductItem>>(
            MaterialPageRoute(builder: (context) => FilterPage()));

    if (res != null || res!.isEmpty) {
      setState(() {
        resultList = res;
      });
    }
  }

  void _searchForKeywords(String keyword) {
    setState(() {
      resultList = widget.productList.where((e) {
        return e.name.toLowerCase().contains(keyword.toLowerCase()) ||
            e.model.toLowerCase().contains(keyword.toLowerCase()) ||
            e.brand.toLowerCase().contains(keyword.toLowerCase());
      }).toList();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Widget content = resultList.isEmpty
        ? Container()
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              padding: EdgeInsets.symmetric(vertical: 10),
              itemCount: resultList.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    MediaQuery.of(context).size.width >= 550 ? 3 : 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio:
                    MediaQuery.of(context).size.width >= 550 ? 0.7 : 0.5,
              ),
              itemBuilder: (context, index) {
                print(resultList[index]);
                ProductItem product_item = resultList[index];

                return GroceryItemCard(product_item: product_item);
              },
            ),
          );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
              child: TextField(
            onChanged: (value) {
              _searchForKeywords(value);
            },
            controller: searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  searchController.text = "";
                },
              ),
              hintText: "Search...",
              border: InputBorder.none,
            ),
          )),
        ),
        actions: [
          IconButton(
              onPressed: () {
                _showFilteredList();
              },
              icon: Icon(Icons.filter_alt_outlined)),
          // Icon(Icons.filter_alt_outlined),
        ],
      ),
      body: content,
    );
  }
}
