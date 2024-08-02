import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:sap_app/providers/category_provider.dart';
import 'package:sqflite/utils/utils.dart';

import '../data/app_keys.dart';

class NewCategory extends ConsumerStatefulWidget {
  const NewCategory({super.key});

  @override
  ConsumerState<NewCategory> createState() => _NewCategoryState();
}

class _NewCategoryState extends ConsumerState<NewCategory> {
  Map<String, Map<String, List<String>>> _loadedCategoryItems = {};
  Map<String, String> _IdAndHeadCategories = {};
  Map<String, bool> _switchMap = {};
  List<String> _allCategoryNames = [];

  final categoryController = TextEditingController();

  Color _selectOnColor = Colors.amber;
  Color _selectOffColor = Colors.indigo;

  bool _barchaSwitch = false;
  String barchaTurkumlar = "BARCHA TURKUMLAR";

  bool inputTurkumLevel = false;
  bool inputCategoryLevel = false;
  bool inputSubCategoryLevel = false;

  bool _customTileExpanded = false;

  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    // _loadedAllCategories();
    ref.read(categoriesProvider.notifier).loadAllCategories();
    // _IdAndHeadCategories =
    //     ref.read(categoriesProvider.notifier).getIdAndHeadCategories();
    // _switchMap = ref.read(categoriesProvider.notifier).getSwitchMap();
    // _allCategoryNames =
    //     ref.read(categoriesProvider.notifier).getAllCategoryNames();
    _loadBase();

    // print("===========================================================");
    // print(_IdAndHeadCategories);
    // print(_switchMap);
    // print(_allCategoryNames);

    // _IdAndHeadCategories = ref.read(categoriesProvider.notifier).getIdAndHeadCategories() as Map<String, String>;
    // _IdAndHeadCategories = ref.read(categoriesProvider.notifier).getIdAndHeadCategories() as Map<String, String>;
    print("inside of initState");
  }

  // @override
  // void didChangeDependencies() {
  //   // TODO: implement didChangeDependencies
  //   super.didChangeDependencies();
  //   ref.read(categoriesProvider.notifier).loadAllCategories();
  //   _loadBase();
  // }

  void _loadBase() async {
    Map<String, Map<String, List<String>>> loadedCategoryItems = {};

    Map<String, String> IdAndHeadCategories = {};

    Map<String, bool> switchMap = {};

    List<String> allCategoryNames = [];

    // await ref.read(categoriesProvider.notifier).loadAllCategories();
    // loadedCategoryItems = ref.read(categoriesProvider.notifier).state;

    IdAndHeadCategories =
        await ref.read(categoriesProvider.notifier).getIdAndHeadCategories();
    switchMap = ref.read(categoriesProvider.notifier).getSwitchMap();
    loadedCategoryItems = await ref.watch(categoriesProvider);
    allCategoryNames =
        ref.read(categoriesProvider.notifier).getAllCategoryNames();
    print(ref.read(categoriesProvider));
    setState(() {
      _loadedCategoryItems = loadedCategoryItems;
      _IdAndHeadCategories = IdAndHeadCategories;
      _switchMap = switchMap;
      _allCategoryNames = allCategoryNames;
    });

    print("===========================================================");
    print(_IdAndHeadCategories);
    print(_switchMap);
    print(_allCategoryNames);
    print(loadedCategoryItems);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    categoryController.dispose();
    super.dispose();
  }

  void _loadedAllCategories() async {
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

      Map<String, Map<String, List<String>>> loadedCategoryItems = {};

      Map<String, String> IdAndHeadCategories = {};

      Map<String, bool> switchMap = {};

      List<String> allCategoryNames = [];

      print(listData);

      listData.forEach((key, value) {
        IdAndHeadCategories[key] = (value as Map).entries.first.key as String;
        switchMap[((value as Map).entries.first.key as String).toUpperCase()] =
            false;
        allCategoryNames
            .add(((value as Map).entries.first.key as String).toUpperCase());
        // print(((value as Map).entries.first.value as Map).entries);
        Map<String, List<String>> subListMap = {};

        ((value as Map).entries.first.value as Map).entries.forEach((el) {
          switchMap[el.key.toString().toUpperCase()] = false;
          allCategoryNames.add(el.key.toString().toUpperCase());

          List<String> lawCats = (el.value as List)
              .map((e) => (e as String).toUpperCase())
              .toList();
          subListMap[(el.key as String).toUpperCase()] = lawCats;
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

      print(switchMap);

      setState(() {
        _IdAndHeadCategories = IdAndHeadCategories;
        _loadedCategoryItems = loadedCategoryItems;
        _switchMap = switchMap;
        _allCategoryNames = allCategoryNames;
        print("inside of loadedAllCategoryItems function");
      });

      // final List<ProductItem> loadedItems = [];
    } catch (err) {
      print(err);
    }
  }

  void _saveCategoryItem() async {
    String text = categoryController.text;
    print("inside of _saveCategoryItem function");
    String error = "";
    // String text = categoryController.text;

    if (text.isNotEmpty &&
        !_allCategoryNames.contains(text.toUpperCase()) &&
        text.length >= 1 &&
        text.length <= 200 &&
        !text.contains(":") &&
        (_barchaSwitch || _switchMap.containsValue(true))) {
      bool confirmation = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Kategoriya qo'shishni tasdiqlash:"),
              // content: Text(""),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Text(
                      "Ha",
                      style: TextStyle(fontSize: 16),
                    )),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text(
                      "Yo'q",
                      style: TextStyle(fontSize: 16),
                    )),
              ],
            );
          });

      print("confirmation: " + confirmation.toString());

      String parentCat = "";
      String grandParentCat = "";
      bool subCathasnothing = false;

      categoryController.text = "";
      _switchMap.forEach((key, value) {
        if (value) parentCat = key.toUpperCase();
      });

      outer:
      for (var el in _loadedCategoryItems.entries) {
        if (el.key.toUpperCase() == parentCat) {
          inputCategoryLevel = true;
          break;
        }

        for (var cat in el.value.entries) {
          if (cat.key.toUpperCase() == parentCat) {
            inputSubCategoryLevel = true;
            grandParentCat = el.key.toUpperCase();
            subCathasnothing =
                cat.value.contains("NULL") || cat.value.contains("null");
            break outer;
          }
        }
      }
      print("Parent: " + parentCat.toString());
      print("GrandParentCategoryName: " + grandParentCat);

      String id = "";

      _IdAndHeadCategories.entries.forEach((el) {
        if (el.value.toUpperCase() == parentCat ||
            el.value.toUpperCase() == grandParentCat) {
          id = el.key;
        }
      });

      if (parentCat.isEmpty && grandParentCat.isEmpty) {
        print("Turkum LEvel changing");

        final url = Uri.https(project_rtdb,
            'category-list/.json');

        try {
          final response = await http.post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(
              {
                text.toUpperCase(): {
                  "NULL": ["NULL"]
                },
              },
            ),
          );

          print("RESPONSE.BODY: " + response.body);

          final Map<String, dynamic> resData = json.decode(response.body);
          _switchMap[text.toUpperCase()] = false;
          setState(() {
            _loadedCategoryItems[text.toUpperCase()] = {
              "NULL": ["NULL"]
            };
            _IdAndHeadCategories[resData["name"]] = text.toUpperCase();
          });
        } catch (e) {
          print("TURKUM LEVEL ERROR: " + e.toString());
        }
      } else if (inputCategoryLevel) {
        inputCategoryLevel = false;

        final url = Uri.https(project_rtdb,
            'category-list/${id}.json');

        bool justWriteMode = false;

        _loadedCategoryItems.forEach((key, value) {
          if (parentCat == key) {
            justWriteMode =
                value.entries.first.key.toString().toUpperCase() == "NULL";
          }
        });

        Map<String, List<String>> map = {};
        if (justWriteMode) {
          map = {
            text.toUpperCase(): ["NULL"]
          };
        } else {
          map =
              Map<String, List<String>>.from(_loadedCategoryItems[parentCat]!);
          map.addAll({
            text.toUpperCase(): ["NULL"]
          });
        }

        try {
          final response = await http.patch(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(
              {
                parentCat: map,
              },
            ),
          );

          print("RESPONSE.BODY :" + response.body);
          print("Status COde: " + response.statusCode.toString());
          if (response.statusCode >= 400) {
            print("Error-connection");

            // _loadedCategoryItems.entries.forEach((element) {
            //   if (parentCat == element.key) {
            //     element.value
            //         .removeWhere((key, value) => text.toUpperCase() == key);
            //   }
            // });
            // setState(() {
            //   _loadedCategoryItems = _loadedCategoryItems;
            //   print(_loadedCategoryItems);
            // });
          } else {
            _switchMap[text.toUpperCase()] = false;
            setState(() {
              _loadedCategoryItems[parentCat] = map;
            });
          }
        } catch (e) {
          print("ERROR: " + e.toString());
        }
      } else if (inputSubCategoryLevel) {
        // bool justWriteMode = false;
        final url = Uri.https(project_rtdb,
            'category-list/${id}.json');
        Map<String, List<String>> map = {};

        print("HasSubCatNothing: " + subCathasnothing.toString());

        if (subCathasnothing) {
          map = Map<String, List<String>>.from(
              _loadedCategoryItems[grandParentCat]!);
          map[parentCat] = [text.toUpperCase()];
        } else {
          map = Map<String, List<String>>.from(
              _loadedCategoryItems[grandParentCat]!);
          map[parentCat] = [...map[parentCat]!, text.toUpperCase()];
        }

        try {
          final response = await http.patch(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(
              {
                grandParentCat: map,
              },
            ),
          );

          print("RESPONSE.BODY :" + response.body);
          print("Status COde: " + response.statusCode.toString());
          if (response.statusCode >= 400) {
            print("Error-connection");

            // _loadedCategoryItems.entries.forEach((element) {
            //   if (parentCat == element.key) {
            //     element.value
            //         .removeWhere((key, value) => text.toUpperCase() == key);
            //   }
            // });
            // setState(() {
            //   _loadedCategoryItems = _loadedCategoryItems;
            //   print(_loadedCategoryItems);
            // });
          } else {
            _switchMap[text.toUpperCase()] = false;
            setState(() {
              _loadedCategoryItems[grandParentCat] = map;
            });
          }
        } catch (e) {
          print("ERROR: " + e.toString());
        }
      }

      return;
    }

    if (_allCategoryNames.contains(text.toUpperCase())) {
      error = "Bunday kategoriya nomi kiritilgan!";
    } else if (text.isEmpty) {
      error = "Hech narsa kiritilmadi kategoriya nomi sifatida!";
    } else if (text.length < 1 || text.length > 200) {
      error =
          "Kategoriya nomi 1 dan  200 tagacha bo'lgan belgilardan tashkil topishi kerak!";
    } else if (text.contains(":")) {
      error = " : kabi belgilarni ishlatishni iloji yo'q!";
    } else if (!_barchaSwitch && !_switchMap.containsValue(true)) {
      error = "Kategoriya tanlanmagan!";
    } else
      error = "Nosozlik yuz berdi!";

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          error,
          style: TextStyle(fontSize: 16),
        ),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _removeCategoryItem(String name) async {
    String upperName = name.toUpperCase();
    print("=====================================");
    print(upperName);
    String id = "";
    String parentCat = "";

    if (_findIfTurkumLevel(upperName)) {
      id = _getIdOfTurkum(upperName);
      print(id);
      Map<String, List<String>> map =
          Map<String, List<String>>.from(_loadedCategoryItems[upperName]!);

      setState(() {
        _loadedCategoryItems.remove(upperName);
      });

      try {
        final url = Uri.https(project_rtdb,
            'category-list/${id}.json');

        final response = await http.delete(url);

        if (response.statusCode >= 400) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "Error: Nosozlik yuz berdi serverdan kategoriya o'chirilmadi!"),
              duration: Duration(seconds: 1),
            ),
          );

          // Optional: Show error message
          setState(() {
            _loadedCategoryItems[upperName] = map;
            // _ProductItems.insert(index, item);
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Error: Nosozlik yuz berdi serverdan kategoriya o'chirilmadi!"),
            duration: Duration(seconds: 1),
          ),
        );

        print("ERROR: NETWORK ERROR");
      }

      // _loadedCategoryItems.remove(upperName);

      // toBeDeleted = upperName;
    } else if (_findIfCategoryLevel(upperName) != "-1") {
      id = _getIdOfTurkum(_findIfCategoryLevel(upperName));
      String turkumCat = "";
      _loadedCategoryItems.forEach(
        (key, value) {
          if (value.containsKey(upperName)) {
            turkumCat = key;
          }
        },
      );
      print("turkumCat: " + turkumCat);

      print(id);
      Map<String, List<String>> map =
          Map<String, List<String>>.from(_loadedCategoryItems[turkumCat]!);

      if (map.length == 1) {
        _loadedCategoryItems[turkumCat]!.addAll({
          "NULL": ["NULL"]
        });
      }

      setState(() {
        // _loadedCategoryItems.remove(upperName);
        _loadedCategoryItems[turkumCat]!.remove(upperName);
      });

      try {
        final url = Uri.https(project_rtdb,
            'category-list/${id}.json');

        // final response = await http.patch(url);

        final response = await http.patch(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(
            {
              turkumCat: _loadedCategoryItems[turkumCat],
            },
          ),
        );

        if (response.statusCode >= 400) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "Error: Nosozlik yuz berdi serverdan kategoriya o'chirilmadi!"),
              duration: Duration(seconds: 1),
            ),
          );

          // Optional: Show error message
          setState(() {
            _loadedCategoryItems[turkumCat] = map;
            // _ProductItems.insert(index, item);
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Error: Nosozlik yuz berdi serverdan kategoriya o'chirilmadi!"),
            duration: Duration(seconds: 1),
          ),
        );

        print("ERROR: NETWORK ERROR");
      }

      // toBeDeleted = upperName;
    } else if (_findIfSubCategoryLevel(upperName).length == 2) {
      id = _getIdOfTurkum(_findIfSubCategoryLevel(upperName)[0]);

      String turkumCat = _findIfSubCategoryLevel(upperName)[0];

      parentCat = _findIfSubCategoryLevel(upperName)[1];

      print(id);

      Map<String, List<String>> map =
          Map<String, List<String>>.from(_loadedCategoryItems[turkumCat]!);
      List<String> list =
          List<String>.from(_loadedCategoryItems[turkumCat]![parentCat]!);
      int ind = list.indexOf(upperName);

      if (list.length == 1) {
        // list.add("NULL");
        _loadedCategoryItems[turkumCat]![parentCat]!.add("NULL");
      }

      setState(() {
        // _loadedCategoryItems.remove(upperName);
        _loadedCategoryItems[turkumCat]![parentCat]!.remove(upperName);
      });

      try {
        final url = Uri.https(
            'shoppinglist-e99e0-default-rtdb12.firebaseio.com',
            'category-list/${id}.json');

        // final response = await http.patch(url);

        final response = await http.patch(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(
            {
              turkumCat: _loadedCategoryItems[turkumCat],
            },
          ),
        );

        if (response.statusCode >= 400) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "Error: Nosozlik yuz berdi serverdan kategoriya o'chirilmadi!"),
              duration: Duration(seconds: 1),
            ),
          );

          // Optional: Show error message
          setState(() {
            _loadedCategoryItems[turkumCat]![parentCat] = list;
            // _ProductItems.insert(index, item);
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Error: Nosozlik yuz berdi serverdan kategoriya o'chirilmadi!"),
            duration: Duration(seconds: 1),
          ),
        );

        print("ERROR: NETWORK ERROR");
      }
    }

    print(name);
    print("=====================================");
  }

  bool _findIfTurkumLevel(String name) {
    bool res = false;
    _loadedCategoryItems.forEach((key, value) {
      if (key == name.toUpperCase()) {
        res = true;
      }
    });

    return res;
  }

  String _findIfCategoryLevel(String name) {
    String res = "-1";

    _loadedCategoryItems.forEach((key, value) {
      for (var el in value.entries) {
        if (el.key == name.toUpperCase()) res = key;
      }
    });

    return res;
  }

  List<String> _findIfSubCategoryLevel(String name) {
    List<String> list = [];

    _loadedCategoryItems.forEach((key, value) {
      for (var el in value.entries) {
        if (el.value.contains(name.toUpperCase())) list.addAll([key, el.key]);
      }
    });

    return list;
  }

  String _getIdOfTurkum(String name) {
    String res = "";
    _IdAndHeadCategories.forEach((key, value) {
      if (value == name.toUpperCase()) res = key;
    });

    return res;
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Container();

    // _loadBase();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text("Yangi kategoriya yaratish"),
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
                    Icons.add_box,
                    color: _barchaSwitch ? _selectOnColor : _selectOffColor,
                  ),
                  style: TextButton.styleFrom(minimumSize: Size(10, 20)),
                ),
              ],
            ),
          ),
          if (_barchaSwitch)
            TextField(
              autofocus: true,
              showCursor: true,
              // mouseCursor: MaterialStateMouseCursor.clickable,
              // maxLines: 2,
              // expands: true,
              // cursorHeight: 4,
              style: TextStyle(
                fontSize: 16,
              ),
              onChanged: (value) {
                setState(() {
                  // resultList = widget.productList
                  //     .where((e) => e.name
                  //         .toLowerCase()
                  //         .contains(value.toLowerCase()))
                  //      .toList();
                });
              },
              onTap: () {},
              controller: categoryController,

              decoration: InputDecoration(
                // helperMaxLines: 3,
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),

                contentPadding: EdgeInsets.all(8),
                prefixIcon: IconButton(
                  icon: Icon(Icons.check),
                  onPressed: _saveCategoryItem,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    categoryController.text = "";
                  },
                ),
                hintText: "Kategoriya nomi...",
                border: OutlineInputBorder(),
              ),
            ),
          ..._loadedCategoryItems.entries.map((headCat) {
            if (headCat.key.toUpperCase()=="TANLANMAGAN") {

              return Container();
            }
            else if (headCat.value.containsKey("NULL")) {
              return Column(
                children: [
                  Dismissible(
                    key: ValueKey(headCat.key),
                    onDismissed: (direction) {
                      _removeCategoryItem(headCat.key);
                    },
                    child: ListTile(
                      title: Row(
                        children: [
                          Text(headCat.key.toUpperCase()),
                          TextButton(
                            onPressed: () {
                              _selectCategory(headCat.key);
                            },
                            child: Icon(
                              Icons.add_box,
                              color: _switchMap[headCat.key.toUpperCase()]!
                                  ? _selectOnColor
                                  : _selectOffColor,
                            ),
                            style:
                                TextButton.styleFrom(minimumSize: Size(10, 20)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_switchMap[headCat.key.toUpperCase()]!)
                    TextField(
                      autofocus: true,
                      showCursor: true,
                      // mouseCursor: MaterialStateMouseCursor.clickable,
                      // maxLines: 2,
                      // expands: true,
                      // cursorHeight: 4,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      onChanged: (value) {
                        setState(() {
                          // resultList = widget.productList
                          //     .where((e) => e.name
                          //         .toLowerCase()
                          //         .contains(value.toLowerCase()))
                          //      .toList();
                        });
                      },
                      onTap: () {},
                      controller: categoryController,

                      decoration: InputDecoration(
                        // helperMaxLines: 3,
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),

                        contentPadding: EdgeInsets.all(8),
                        prefixIcon: IconButton(
                          icon: Icon(Icons.check),
                          onPressed: _saveCategoryItem,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            categoryController.text = "";
                          },
                        ),
                        hintText: "Kategoriya nomi...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                ],
              );
            } else {
              return ExpansionTile(
                backgroundColor: Color.fromARGB(255, 86, 218, 255),
                collapsedBackgroundColor: Color.fromARGB(255, 82, 174, 255),
                title: Column(
                  children: [
                    Dismissible(
                      key: ValueKey(headCat.key),
                      onDismissed: (direction) {
                        _removeCategoryItem(headCat.key);
                      },
                      child: Container(
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
                              child: Icon(
                                Icons.add_box,
                                color: _switchMap[headCat.key.toUpperCase()]!
                                    ? _selectOnColor
                                    : _selectOffColor,
                              ),
                              style: TextButton.styleFrom(
                                  minimumSize: Size(10, 20)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_switchMap[headCat.key.toUpperCase()]!)
                      TextField(
                        autofocus: true,
                        showCursor: true,
                        // mouseCursor: MaterialStateMouseCursor.clickable,
                        // maxLines: 2,
                        // expands: true,
                        // cursorHeight: 4,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                        onChanged: (value) {
                          setState(() {
                            // resultList = widget.productList
                            //     .where((e) => e.name
                            //         .toLowerCase()
                            //         .contains(value.toLowerCase()))
                            //      .toList();
                          });
                        },
                        onTap: () {},
                        controller: categoryController,

                        decoration: InputDecoration(
                          // helperMaxLines: 3,
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),

                          contentPadding: EdgeInsets.all(8),
                          prefixIcon: IconButton(
                            icon: Icon(Icons.check),
                            onPressed: _saveCategoryItem,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              categoryController.text = "";
                            },
                          ),
                          hintText: "Kategoriya nomi...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                  ],
                ),
                // trailing: Text("next"),

                children: [
                  ...headCat.value.entries.map((sub) {
                    if (sub.value.length == 1 &&
                        sub.value[0].toLowerCase() == "null") {
                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 16, top: 15, bottom: 15),
                        child: Column(
                          children: [
                            Dismissible(
                              key: ValueKey(sub.key),
                              onDismissed: (direction) {
                                _removeCategoryItem(sub.key);
                              },
                              child: Container(
                                // padding: EdgeInsets.only(left: 20),
                                child: Row(
                                  children: [
                                    Text(sub.key),
                                    TextButton(
                                      onPressed: () {
                                        _selectCategory(sub.key);
                                      },
                                      child: Icon(
                                        Icons.add_box,
                                        color:
                                            _switchMap[sub.key.toUpperCase()]!
                                                ? _selectOnColor
                                                : _selectOffColor,
                                      ),
                                      style: TextButton.styleFrom(
                                          minimumSize: Size(10, 20)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_switchMap[sub.key.toUpperCase()]!)
                              TextField(
                                autofocus: true,
                                showCursor: true,
                                // mouseCursor: MaterialStateMouseCursor.clickable,
                                // maxLines: 2,
                                // expands: true,
                                // cursorHeight: 4,
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    // resultList = widget.productList
                                    //     .where((e) => e.name
                                    //         .toLowerCase()
                                    //         .contains(value.toLowerCase()))
                                    //      .toList();
                                  });
                                },
                                onTap: () {},
                                controller: categoryController,

                                decoration: InputDecoration(
                                  // helperMaxLines: 3,
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey)),

                                  contentPadding: EdgeInsets.all(8),
                                  prefixIcon: IconButton(
                                    icon: Icon(Icons.check),
                                    onPressed: _saveCategoryItem,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      categoryController.text = "";
                                    },
                                  ),
                                  hintText: "Kategoriya nomi...",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                          ],
                        ),
                      );
                    } else {
                      return ExpansionTile(
                        title: Column(
                          children: [
                            Dismissible(
                              key: ValueKey(sub.key),
                              onDismissed: (direction) {
                                _removeCategoryItem(sub.key);
                              },
                              child: Container(
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
                                      Icons.add_box,
                                      color: _switchMap[sub.key.toUpperCase()]!
                                          ? _selectOnColor
                                          : _selectOffColor,
                                    ),
                                  ),
                                  // TextButton(
                                  //   onPressed: () {
                                  //     _removeCategoryItem(sub.key);
                                  //   },
                                  //   child: Icon(
                                  //     Icons.delete,
                                  //     color: Colors.red,
                                  //   ),
                                  //   style: TextButton.styleFrom(
                                  //     minimumSize: Size(10, 20),
                                  //     // color: Colors.red,
                                  //   ),
                                  // ),
                                ],
                              )),
                            ),
                            if (_switchMap[sub.key.toUpperCase()]!)
                              TextField(
                                autofocus: true,
                                showCursor: true,
                                // mouseCursor: MaterialStateMouseCursor.clickable,
                                // maxLines: 2,
                                // expands: true,
                                // cursorHeight: 4,
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    // resultList = widget.productList
                                    //     .where((e) => e.name
                                    //         .toLowerCase()
                                    //         .contains(value.toLowerCase()))
                                    //      .toList();
                                  });
                                },
                                onTap: () {},
                                controller: categoryController,

                                decoration: InputDecoration(
                                  // helperMaxLines: 3,
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey)),

                                  contentPadding: EdgeInsets.all(8),
                                  prefixIcon: IconButton(
                                    icon: Icon(Icons.check),
                                    onPressed: _saveCategoryItem,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.clear),
                                    onPressed: () {
                                      categoryController.text = "";
                                    },
                                  ),
                                  hintText: "Kategoriya nomi...",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                          ],
                        ),
                        backgroundColor: Color.fromARGB(255, 155, 242, 255),
                        children: [
                          for (String cat in sub.value)
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 16, top: 15, bottom: 15),
                              child: Dismissible(
                                onDismissed: (direction) {
                                  _removeCategoryItem(cat);
                                },
                                key: ValueKey(cat),
                                child: Container(
                                  child: Row(
                                    children: [
                                      Text(cat),
                                    ],
                                  ),
                                ),
                              ),
                            )
                        ],
                      );
                    }
                  }),
                ],
              );
            }
          }),
        ],
      ),
    );
  }

  void _selectCategory(String name) {
    if (name.toUpperCase() == barchaTurkumlar.toUpperCase()) {
      _switchMap.entries.forEach((el) {
        _switchMap[el.key] = false;
      });

      setState(() {
        _barchaSwitch = !_barchaSwitch;
      });
      return;
    } else if (_barchaSwitch) {
      _barchaSwitch = false;
    }

    _switchMap.forEach((key, value) {
      if (key == name.toUpperCase()) {
        _switchMap[key] = !value;
      } else
        _switchMap[key] = false;
    });

    setState(() {
      _switchMap[name.toUpperCase()] = _switchMap[name.toUpperCase()]!;
    });
  }
}

class ExpansionTileExample extends StatefulWidget {
  const ExpansionTileExample({super.key});

  @override
  State<ExpansionTileExample> createState() => _ExpansionTileExampleState();
}

class _ExpansionTileExampleState extends State<ExpansionTileExample> {
  bool _customTileExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        const ExpansionTile(
          title: Text('ExpansionTile 1'),
          subtitle: Text('Trailing expansion arrow icon'),
          children: <Widget>[
            ListTile(title: Text('This is tile number 1')),
          ],
        ),
        ExpansionTile(
          title: const Text('ExpansionTile 2'),
          subtitle: const Text('Custom expansion arrow icon'),
          trailing: Icon(
            _customTileExpanded
                ? Icons.arrow_drop_down_circle
                : Icons.arrow_drop_down,
          ),
          children: <Widget>[
            ListTile(title: Text('This is tile number 2')),
            ExpansionTile(
              title: Text('ExpansionTile 2'),
              children: <Widget>[
                ListTile(title: Text('This is tile number 2')),
                ExpansionTile(
                  backgroundColor: Colors.amber,
                  onExpansionChanged: (value) {
                    print(value);
                  },
                  title: ListTile(
                    title: Text('This is tile number 2'),
                    trailing: TextButton(
                      onPressed: () {},
                      // onHover: (value) {},
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        minimumSize: Size(10, 30),

                        // maximumSize: Size(20, 30),
                      ),
                    ),
                  ),
                  children: <Widget>[
                    ListTile(
                      title: Text('This is tile number 2'),
                      trailing: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.check),
                      ),
                    ),
                    // ExpansionTile(title: const Text('ExpansionTile 2')),
                  ],
                ),
              ],
            ),
          ],
          onExpansionChanged: (bool expanded) {
            setState(() {
              _customTileExpanded = expanded;
            });
          },
        ),
        const ExpansionTile(
          title: Text('ExpansionTile 3'),
          subtitle: Text('Leading expansion arrow icon'),
          controlAffinity: ListTileControlAffinity.leading,
          children: <Widget>[
            ListTile(title: Text('This is tile number 3')),
          ],
        ),
      ],
    );
  }
}
