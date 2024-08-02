import 'dart:convert';
// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart' as http;
import 'package:sap_app/models/category.dart';
import 'package:get/get.dart';

class CategoryCreateScreen extends StatefulWidget {
  const CategoryCreateScreen({super.key});

  @override
  State<CategoryCreateScreen> createState() => _CategoryCreateScreenState();
}

class _CategoryCreateScreenState extends State<CategoryCreateScreen> {
  Map<Category, Map<Category, List<Category>>> _categoryMap = {};
  Map<String, List<String>> _loadedCategoryMap = {};
  Map<Category, bool> _switchMap = {};

  bool colorSwitch = false;
  bool barcharTurkumColorSwitch = false;
  bool _isLoading = true;

  final String barchaTurkumlar = "Barcha Turkumlar";

  // bool inputSwitchTopLevel = false;
  bool inputTurkumLevel = false;
  bool inputCategoryLevel = false;
  bool inputSubCategoryLevel = false;

  Color optionOnColor = Colors.amber;
  Color optionOffColor = Colors.indigo;

  final categoryController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    categoryController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    _loadAllCategories();
    _isLoading = false;
    super.initState();
  }

  void _loadAllCategories() async {
    final url = Uri.https(
        'shoppinglist-e99e0-default-rtdb.firebaseio.com', 'category-list.json');

    try {
      final response = await http.get(url);
      // print(response.body);

      if (response.statusCode >= 400) {
        setState(() {
          // _error = "Failed to fetch data. Please try again later.";
        });
        // return;
      }

      if (response.body == 'null') {
        setState(() {
          // __isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData =
          json.decode(utf8.decode(response.bodyBytes));

      // print(listData.entries);
      // print(listData.entries);
      // print("=====================================");
      // print((listData.entries.first.value as Map).keys);

      listData.entries.forEach((entry) {
        // print(entry.value as List);
      });

      final List<Category> loadedCategoryItems = [];
      final List<Category> headNames = [];
      late Map<Category, Map<Category, List<Category>>> categoryMap = {};
      late Map<Category, bool> switchMap = {};
      Map<String, List<String>> loadedCategoryMap = {};

      for (final category in listData.entries) {
        final String headName = (category.value as Map).entries.first.key;
        final String headId = (category.key as String);
        // print("headId: " + headId);

        final List<String> list =
            ((category.value as Map).entries.first.value as List)
                .map((e) => e as String)
                .where((e)=> !e.contains("nothing")).toList();
        loadedCategoryMap[headName] = list;
        Category categoryItem;
        // List<Category> listOfCategory = [];
        for (final subCategory in list) {
          // print(category.key + ": " + subCategory);

          categoryItem = Category(
            id: category.key,
            name: subCategory,
          );
          loadedCategoryItems.add(categoryItem);
          // listOfCategory.add(categoryItem);
        }

        switchMap.addAll({Category(id: headId, name: headName): false});
        headNames.add(Category(id: headId, name: headName));
      }

      print(loadedCategoryItems);

      for (Category headName in headNames) {
        List<Category> mixedlist = loadedCategoryItems
            .where((el) =>
                el.name.toLowerCase().contains(headName.subName.toLowerCase()))
            .toList();

        mixedlist.forEach((el) {
          switchMap[el] = false;
        });

        // switchMap[Category(id: "0", name: barchaTurkumlar.toUpperCase())] =
        //     false;
        
        List<Category> firstborns =
            mixedlist.where((element) => element.size == 2).toList();
        List<Category> secondborns =
            mixedlist.where((element) => element.size == 3).toList();

        Map<Category, List<Category>> secondMap = {};
        // Map<String, List<String>> secondMapAsIs = {};

        firstborns.forEach((cat) {
          var map = secondMap[cat] = secondborns
              .where((el) =>
                  el.name.toLowerCase().contains(cat.subName.toLowerCase()))
              .toList();

          // secondMapAsIs[cat.subName] = map.map((e) => e.subName).toList();
          // secondMapAsIs[cat.subName] = secondborns.where((el) => el.name.toLowerCase().contains(cat.subName.toLowerCase())).toList();
        });

        

        // categoryMap[headName] = secondMap.length==_loadedCategoryMap[headName.name.toLowerCase()]!.length ? secondMap : {};
        categoryMap[headName] = secondMap;
        // loadedCategoryMap[headName.subName] = secondMapAsIs;

      }



      setState(() {
        _categoryMap = categoryMap;
        _switchMap = switchMap;
        _loadedCategoryMap = loadedCategoryMap;
      });

      print(_loadedCategoryMap);

      // print(categoryMap);
      // print(switchMap);
    } catch (error) {
      setState(() {
        // _error = "Something went wrong!";
      });
    }
  }

  void _saveCategoryItem() async {
    print("_saveCategoryItem===============");
    print(categoryController.text);
    print("_saveCategoryItem===============");

    String error = "";
    String text = categoryController.text;

    if (text.isNotEmpty &&
        text.length >= 1 &&
        text.length <= 200 &&
        !text.contains(":") &&
        (barcharTurkumColorSwitch || _switchMap.containsValue(true))) {
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

      print(confirmation);

      if (barcharTurkumColorSwitch) {
        final url = Uri.https('shoppinglist-e99e0-default-rtdb.firebaseio.com',
            'category-list.json');

        print("barchaTurkumlar -> ");

        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(
            {
              text.toUpperCase(): ["nothing"],
            },
          ),
        );

        print("response: "+response.body);

        // final Map<String, dynamic> resData = json.decode(response.body);

        if (!context.mounted) {
          return;
        }
      } else {

        Category? cat;

        _switchMap.forEach((key, value) {
          if (value) cat = key;
        });

        _categoryMap.forEach((key, value) {
          if (key.name == cat!.name) {
            inputCategoryLevel = true;
          }
          // if (key.value == cat!.name){
            
          // }
        });


        String id = cat!.id;

        if (inputCategoryLevel) {

          final url = Uri.https(
              'shoppinglist-e99e0-default-rtdb.firebaseio.com',
              'category-list/${id}.json');
          final response = await http.patch(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(
              {
                cat!.subName: [..._loadedCategoryMap[cat!.subName]!, text.toUpperCase()+":"+cat!.subName],
              },
            ),
          );
          print("response: ${response.body}");
        }
        

        print(cat!.subName);
        print(cat!.name);
      }

      // final url = Uri.https('shoppinglist-e99e0-default-rtdb.firebaseio.com',
      //     'category-list/${id}.json');

      // if (response.statusCode >= 400) {
      //   ScaffoldMessenger.of(context).clearSnackBars();
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text("Error: Item is not deleted from server!"),
      //       duration: Duration(seconds: 1),
      //     ),
      //   );

      //   // Optional: Show error message
      //   setState(() {
      //     // _ProductItems.insert(index, item);
      //   });
      // }

      return;
    }

    if (text.isEmpty) {
      error = "Hech narsa kiritilmadi kategoriya nomi sifatida!";
    } else if (text.length < 1 || text.length > 200) {
      error =
          "Kategoriya nomi 1 dan  200 tagacha bo'lgan belgilardan tashkil topishi kerak!";
    } else if (text.contains(":")) {
      error = " : kabi belgilarni ishlatishni iloji yo'q!";
    } else if (!barcharTurkumColorSwitch && !_switchMap.containsValue(true)) {
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

    print("inside of _saveCategoryItem");
    // final url = Uri.https(
    //     'shoppinglist-e99e0-default-rtdb.firebaseio.com', 'category-list.json');

    // final response = await http.post(
    //   url,
    //   headers: {
    //     'Content-Type': 'application/json',
    //   },
    //   body: json.encode(
    //     {
    //       _categoryMap.entries.first.key: _categoryMap.entries.first.value,
    //     },
    //   ),
    // );

    // print(response.body);
    // final Map<String, dynamic> resData = json.decode(response.body);
  }

  void _removeCategoryItem() async {
    // final index = _ProductItems.indexOf(item);
    String id = "-NhlAgFfT7TF3acuCZWn";

    setState(() {
      // _ProductItems.remove(item);
    });

    final url = Uri.https('shoppinglist-e99e0-default-rtdb.firebaseio.com',
        'category-list/${id}.json');

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(
        {
          "ELEKTRONIKA": [
            "GO'ZALLIK UCHUN TEXNIKA:MAISHIY TEXNIKA",
            "IQLIM TEXNIKASI:MAISHIY TEXNIKA",
            "VENTILYATORLAR:MAISHIY TEXNIKA: IQLIM TEXNIKASI"
          ],
        },
      ),
    );

    if (response.statusCode >= 400) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: Item is not deleted from server!"),
          duration: Duration(seconds: 1),
        ),
      );

      // Optional: Show error message
      setState(() {
        // _ProductItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Container();
    if (!_isLoading) {
      content = SingleChildScrollView(
        padding: EdgeInsets.only(left: 20),
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                  onPressed: _saveCategoryItem, child: Text("save category")),
              TextButton(
                  onPressed: _loadAllCategories, child: Text("load category")),
              TextButton(
                  onPressed: _removeCategoryItem,
                  child: Text("patch category")),

              // ExpansionPanelList(

              //   children: [
              //     ExpansionPanel(
              //       headerBuilder: (context, open){

              //         return Text("data");
              //       },
              //     body: Text("Data")),
              //   ],
              // ),
              Row(
                children: [
                  Text(
                    barchaTurkumlar.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  TextButton(
                    onPressed: () {
                      _selectToAdd(Category(
                          id: "0", name: barchaTurkumlar.toUpperCase()));
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: barcharTurkumColorSwitch
                          ? optionOnColor
                          : optionOffColor,
                      minimumSize: Size(10, 30),
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              // if (inputSwitchTopLevel) TextField(),
              // ListView(
              //   children: [
              //     ExpansionTile(

              //       title: Text(barchaTurkumlar),
              //       children: [Text("data"), Text("data"), Text("data")],
              //     ),
              //   ],
              // ),

              ..._categoryMap.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      // crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(),
                          onPressed: () {},
                          child: Text(
                            "${entry.key.subName}",
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        TextButton(
                          onPressed: () {
                            _selectToAdd(entry.key);
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: _getValue(entry.key)
                                ? optionOnColor
                                : optionOffColor,
                            minimumSize: Size(10, 30),
                          ),
                          child: Icon(
                            Icons.add,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red,
                            minimumSize: Size(10, 30),
                          ),
                          child: Icon(
                            Icons.delete,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    ...entry.value.entries.map((sub) {
                      return sub.value.length == 0
                          ? Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.indigo),
                                    ),
                                    child: Text(
                                      sub.key.subName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                TextButton(
                                  onPressed: () {
                                    _selectToAdd(sub.key);
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: _getValue(sub.key)
                                        ? optionOnColor
                                        : optionOffColor,
                                    minimumSize: Size(10, 30),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    minimumSize: Size(10, 30),
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            )
                          : Container(
                              // decoration: BoxDecoration(
                              //   border: Border.all(
                              //     color: Colors.indigo
                              //   )
                              // ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.indigo,
                                            ),
                                          ),
                                          child: Text(
                                            sub.key.subName,
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 4, 139, 250),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _selectToAdd(sub.key);
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor: _getValue(sub.key)
                                              ? optionOnColor
                                              : optionOffColor,
                                          minimumSize: Size(10, 30),
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      TextButton(
                                        onPressed: () {},
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          minimumSize: Size(10, 30),
                                        ),
                                        child: Icon(
                                          Icons.delete,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  for (final el in sub.value)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8,
                                          bottom: 8,
                                          left: 60,
                                          right: 0),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            // color: Colors.amber,

                                            decoration: BoxDecoration(
                                                border: Border.all(
                                              color: Colors.indigo,
                                            )),
                                            child: Text(
                                              el.subName,
                                              style: TextStyle(),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          // GestureDetector(),
                                          // Container(
                                          //   color: Colors.indigo,
                                          //     child: IconButton(
                                          //   onPressed: () {},
                                          //   icon: Icon(Icons.delete),
                                          // )),
                                          TextButton(
                                            onPressed: () {},
                                            style: TextButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              minimumSize: Size(10, 30),
                                            ),
                                            child: const Icon(
                                              Icons.delete,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            );
                    }),

                    // Text(entry.value.entries);
                  ],
                );
              })
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        // backgroundColor: Colors.grey,
        title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
              child: TextField(
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
          )),
        ),
      ),
      body: content,
    );
  }

  bool _getValue(Category cat) {
    String str = cat.subName;

    if (barchaTurkumlar == str) return true;
    bool result = false;

    _switchMap.forEach((key, value) {
      if (key.subName == str && value) result = true;
    });

    return result;
  }

  void _selectToAdd(Category cat) {
    String str = cat.subName;
    if (str == barchaTurkumlar.toUpperCase()) {
      barcharTurkumColorSwitch = !barcharTurkumColorSwitch;
    } else if (barcharTurkumColorSwitch) {
      barcharTurkumColorSwitch = false;
    }
    // {

    //   setState(() {
    //     _switchMap[str.toUpperCase()]==false;
    //   });
    //   return;
    // } else if ((str==barchaTurkumlar && barcharTurkumColorSwitch)){
    //   setState(() {
    //     barcharTurkumColorSwitch==false;
    //   });
    //   return;
    // }

    _switchMap.forEach((key, value) {
      if (key.subName == str) {
        _switchMap[key] = !_getValue(key);
      } else {
        _switchMap[key] = false;
      }
    });

    // barcharTurkumColorSwitch = false;

    setState(() {
      // if (str == barchaTurkumlar) barcharTurkumColorSwitch = !barcharTurkumColorSwitch;
      _switchMap[cat] = _getValue(cat);
    });
  }
}
