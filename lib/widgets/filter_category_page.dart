import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../data/app_keys.dart';

class FilterCategoryPage extends StatefulWidget {
  // final productList;

  const FilterCategoryPage({super.key});

  @override
  State<FilterCategoryPage> createState() => _FilterCategoryPageState();
}

class _FilterCategoryPageState extends State<FilterCategoryPage> {
  bool _barchaSwitch = false;

  Map<String, Map<String, List<String>>> _loadedCategoryItems = {};
  Map<String, bool> _switchMap = {};
  List<String> _allCategoryNames = [];

  Map<String, bool> _turkumMap = {};
  Map<String, bool> _categoryMap = {};
  Map<String, bool> _subCategoryMap = {};

  Color _selectOnColor = Colors.amber;
  Color _selectOffColor = Colors.indigo;
  String barchaTurkumlar = "Barcha Turkumlar";

  int count = 0;

  @override
  void initState() {
    // TODO: implement initState
    _loadAllCategories();
    super.initState();
  }

  void _loadAllCategories() async {
    final url = Uri.https(
        project_rtdb, 'category-list.json');

    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          // _error = "Failed to fetch data. Please try again later.";
        });
        // return;
      }

      if (response.body == 'null') {
        setState(() {
          // _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData =
          json.decode(utf8.decode(response.bodyBytes));
      print("response: " + response.body);
      Map<String, Map<String, List<String>>> loadedCategoryItems = {};

      // Map<String, String> IdAndHeadCategories = {};

      Map<String, bool> switchMap = {};

      Map<String, bool> turkumMap = {};
      Map<String, bool> categoryMap = {};
      Map<String, bool> subCategoryMap = {};

      List<String> allCategoryNames = [];

      print(listData);

      listData.forEach((key, value) {
        // IdAndHeadCategories[key] = (value as Map).entries.first.key as String;
        switchMap[((value as Map).entries.first.key as String).toUpperCase()] =
            false;
        allCategoryNames
            .add(((value as Map).entries.first.key as String).toUpperCase());

        turkumMap[((value as Map).entries.first.key as String).toUpperCase()] =
            false;
        // print(((value as Map).entries.first.value as Map).entries);
        Map<String, List<String>> subListMap = {};

        ((value as Map).entries.first.value as Map).entries.forEach((el) {
          switchMap[el.key.toString().toUpperCase()] = false;
          if (el.key.toString().toUpperCase() != "NULL") {
            categoryMap[el.key.toString().toUpperCase()] = false;
          }

          allCategoryNames.add(el.key.toString().toUpperCase());

          List<String> lawCats = (el.value as List)
              .map((e) => (e as String).toUpperCase())
              .toList();
          subListMap[(el.key as String).toUpperCase()] = lawCats;

          lawCats.forEach((element) {
            if (element.toUpperCase() != "NULL") {
              subCategoryMap[element.toUpperCase()] = false;
            }
          });

          allCategoryNames.addAll(lawCats);
        });

        loadedCategoryItems[((value as Map).entries.first.key as String)
            .toUpperCase()] = subListMap;
      });

      // print(IdAndHeadCategories);
      print("loadedCategoryItems: " + loadedCategoryItems.toString());

      allCategoryNames
          .removeWhere((element) => element.toString().toUpperCase() == "NULL");
      allCategoryNames = allCategoryNames.map((e) => e.toUpperCase()).toList();

      print("allcategoryNames" + allCategoryNames.toString());

      for (var el in _switchMap.entries) {
        if (el.key.toString().toUpperCase() == "NULL")
          _switchMap.remove(el.key);
      }

      print("switchMap: " + turkumMap.toString());
      print("categoryMap: " + categoryMap.toString());
      print("subCategoryMap: " + subCategoryMap.toString());
      // print(turkumMap);
      // print(categoryMap);
      // print(subCategoryMap);

      setState(() {
        // _IdAndHeadCategories = IdAndHeadCategories;
        _loadedCategoryItems = loadedCategoryItems;
        _switchMap = switchMap;
        _allCategoryNames = allCategoryNames;
        _turkumMap = turkumMap;
        _categoryMap = categoryMap;
        _subCategoryMap = subCategoryMap;
        print("inside of loadedAllCategoryItems function");
      });

      // final List<ProductItem> loadedItems = [];
    } catch (err) {
      print(err);
    }
  }

  void _filterCategoryEnd() async {
    List<String> filteredCategories = [];

    _turkumMap.forEach((key, value) {
      if (value) {
        print(value.toString()+key);
        filteredCategories.add(key);
      }
    });
    _categoryMap.forEach((key, value) {
      if (value) {
        print(value.toString()+key);

        filteredCategories.add(key);
      }
    });
    _subCategoryMap.forEach((key, value) {
      if (value) {
        print(value.toString()+key);

        filteredCategories.add(key);
      }
    });

    Navigator.pop(context, filteredCategories);
  }

  @override
  Widget build(BuildContext context) {
    count += 1;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        title: Text("Turkumlar"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Row(
              children: [
                Text(barchaTurkumlar.toUpperCase()),
                TextButton(
                  onPressed: () {
                    _selectCategory(barchaTurkumlar);
                  },
                  child: Icon(
                    ((_turkumMap.containsValue(true)))
                        ? Icons.check_box_outline_blank_rounded
                        : Icons.check_box_outlined,
                    color: _barchaSwitch ? _selectOnColor : _selectOffColor,
                  ),
                  style: TextButton.styleFrom(minimumSize: Size(10, 20)),
                ),
              ],
            ),
          ),
          ..._loadedCategoryItems.entries.map((headCat) {
            if (headCat.value.containsKey("NULL")) {
              return Column(
                children: [
                  ((!_turkumMap.containsValue(true)) ||
                          _turkumMap[headCat.key]!)
                      ? ListTile(
                          title: Row(
                            children: [
                              Text(headCat.key.toUpperCase()),
                              TextButton(
                                onPressed: () {
                                  _selectCategory(headCat.key);
                                },
                                style: TextButton.styleFrom(
                                    minimumSize: Size(10, 20)),
                                child: Icon(
                                  ((!_turkumMap.containsValue(true)) ||
                                          !_turkumMap[headCat.key]!)
                                      ? Icons.check_box_outline_blank_outlined
                                      : Icons.check_box_outlined,
                                  color: _switchMap[headCat.key.toUpperCase()]!
                                      ? _selectOnColor
                                      : _selectOffColor,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                ],
              );
            } else {
              return ((!_turkumMap.containsValue(true)) ||
                      _turkumMap[headCat.key]!)
                  ? ExpansionTile(
                      backgroundColor: Color.fromARGB(255, 86, 218, 255),
                      collapsedBackgroundColor:
                          Color.fromARGB(255, 82, 174, 255),
                      title: Column(
                        children: [
                          Container(
                            child: Row(
                              children: [
                                Text(
                                  headCat.key.toUpperCase(),
                                  maxLines: 2,
                                ),
                                TextButton(
                                  onPressed: () {
                                    _selectCategory(headCat.key);
                                  },
                                  style: TextButton.styleFrom(
                                      minimumSize: Size(10, 20)),
                                  child: Icon(
                                    ((!_turkumMap.containsValue(true)) ||
                                            !_turkumMap[headCat.key]!)
                                        ? Icons.check_box_outline_blank_outlined
                                        : Icons.check_box_outlined,
                                    color:
                                        _switchMap[headCat.key.toUpperCase()]!
                                            ? _selectOnColor
                                            : _selectOffColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // trailing: Text("next"),

                      children: [
                        ...headCat.value.entries.map((sub) {
                          if (sub.value.length == 1 &&
                              sub.value[0].toLowerCase() == "null") {
                            return ((!_categoryMap.containsValue(true)) ||
                                    _categoryMap[sub.key]!)
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, top: 15, bottom: 15),
                                    child: Column(
                                      children: [
                                        Container(
                                          // padding: EdgeInsets.only(left: 20),
                                          child: Row(
                                            children: [
                                              Text(sub.key),
                                              TextButton(
                                                onPressed: () {
                                                  _selectCategory(sub.key);
                                                },
                                                style: TextButton.styleFrom(
                                                    minimumSize: Size(10, 20)),
                                                child: Icon(
                                                  ((!_categoryMap.containsValue(
                                                              true)) ||
                                                          !_categoryMap[
                                                              sub.key]!)
                                                      ? Icons
                                                          .check_box_outline_blank_rounded
                                                      : Icons
                                                          .check_box_outlined,
                                                  color: _switchMap[sub.key
                                                          .toUpperCase()]!
                                                      ? _selectOnColor
                                                      : _selectOffColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container();
                          } else {
                            return ExpansionTile(
                              title: Column(
                                children: [
                                  Container(
                                      child: Row(
                                    children: [
                                      Text(sub.key),
                                      TextButton(
                                        onPressed: () {
                                          _selectCategory(sub.key);
                                        },
                                        style: TextButton.styleFrom(
                                            minimumSize: Size(10, 20)),
                                        child: Icon(
                                          ((!_categoryMap
                                                      .containsValue(true)) ||
                                                  !_categoryMap[sub.key]!)
                                              ? Icons
                                                  .check_box_outline_blank_rounded
                                              : Icons.check_box_outlined,
                                          color:
                                              _switchMap[sub.key.toUpperCase()]!
                                                  ? _selectOnColor
                                                  : _selectOffColor,
                                        ),
                                      ),
                                    ],
                                  )),
                                ],
                              ),
                              backgroundColor:
                                  Color.fromARGB(255, 155, 242, 255),
                              children: [
                                for (String cat in sub.value)
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 16, top: 5, bottom: 5),
                                    child: Container(
                                      child: ((!_subCategoryMap
                                                  .containsValue(true)) ||
                                              _subCategoryMap[cat]!)
                                          ? Row(
                                              children: [
                                                // ListTile(title: Text(cat),),
                                                Text(cat),
                                                TextButton(
                                                    onPressed: () {
                                                      _selectCategory(cat);
                                                    },
                                                    child: (!_subCategoryMap
                                                                .containsValue(
                                                                    true) ||
                                                            !_subCategoryMap[
                                                                cat]!)
                                                        ? Icon(Icons
                                                            .check_box_outline_blank_rounded)
                                                        : Icon(
                                                            Icons
                                                                .check_box_outlined,
                                                          ))
                                              ],
                                            )
                                          : SizedBox(),
                                    ),
                                  )
                              ],
                            );
                          }
                        }),
                      ],
                    )
                  : Container();
            }
          }),
          SizedBox(
            height: 20,
          ),
          Row(
            // crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                    onPressed: () {
                      _filterCategoryEnd();
                    },
                    child: Text("Filterlash", style: TextStyle(color: Colors.white),)),
              ),
            ],
          )
        ],
      ),
      // bottomNavigationBar: BottomNavigationBar(items: [
      //   BottomNavigationBarItem(
      //     icon: Icon(Icons.clear),
      //     label: ("Tozalash"),

      //   ),
      //   BottomNavigationBarItem(
      //     icon: Icon(Icons.filter_list_outlined),
      //     label: ("Filterlash"),

      //   ),
      // ]),
    );
  }

  void _selectCategory(String name) {
    String str = name.toUpperCase();

    if (_turkumMap.containsKey(name)) {
      for (var cat in _turkumMap.entries) {
        if (cat.key == str)
          _turkumMap[str] = !_turkumMap[str]!;
        else
          _turkumMap[cat.key] = false;
      }

      if (!_turkumMap.containsValue(true)) {
        _categoryMap.forEach((key, value) {
          _categoryMap[key] = false;
        });
        _subCategoryMap.forEach((key, value) {
          _subCategoryMap[key] = false;
        });
      }
    } else if (_categoryMap.containsKey(str)) {
      for (var cat in _categoryMap.entries) {
        if (cat.key == str)
          _categoryMap[str] = !_categoryMap[str]!;
        else
          _categoryMap[cat.key] = false;
      }

      if (!_categoryMap.containsValue(true)) {
        _subCategoryMap.forEach((key, value) {
          _subCategoryMap[key] = false;
        });
      }
    } else if (_subCategoryMap.containsKey(str)) {
      for (var cat in _subCategoryMap.entries) {
        if (cat.key == str)
          _subCategoryMap[str] = !_subCategoryMap[str]!;
        else
          _subCategoryMap[cat.key] = false;
      }
    }

    setState(() {
      _turkumMap = _turkumMap;
      _categoryMap = _categoryMap;
      _subCategoryMap = _subCategoryMap;
    });
  }
}
