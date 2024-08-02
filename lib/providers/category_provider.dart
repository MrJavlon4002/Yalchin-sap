import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../data/app_keys.dart';

class CategoryNotify
    extends StateNotifier<Map<String, Map<String, List<String>>>> {
  CategoryNotify() : super({});

  Future<List<String>> getHeadNames() async {
    List<String> headNames = [];

    state.forEach((key, value) {
      headNames.add(key);
    });

    return headNames;
  }

  Map<String, bool> getSwitchMap()  {
    Map<String, bool> switchMap = {};

    print("inside of switchMap: " + state.toString());

    Map<String, Map<String, List<String>>> loadedCategoryItems =
        Map<String, Map<String, List<String>>>.from(state);

    loadedCategoryItems.forEach((key, value) {
      switchMap[key.toUpperCase()] = false;

      (value as Map).entries.forEach((el) {
        switchMap[el.key.toString().toUpperCase()] = false;
      });
    });

    return switchMap;
  }

  Map<String, bool> getTurkumMap() {
    Map<String, bool> turkumMap = {};

    state.forEach((key, value) {
      turkumMap[key.toUpperCase()] = false;
    });

    return turkumMap;
  }

  Map<String, bool> getCategoryMap() {
    Map<String, bool> categoryMap = {};

    state.forEach((key, value) {
      // Map<String, List<String>> subListMap = {};

      (value as Map).entries.forEach((el) {
        // switchMap[el.key.toString().toUpperCase()] = false;
        if (el.key.toString().toUpperCase() != "NULL") {
          categoryMap[el.key.toString().toUpperCase()] = false;
        }
      });
    });

    return categoryMap;
  }

  Map<String, bool> getSubCategoryMap() {
    Map<String, bool> subCategoryMap = {};

    state.forEach((key, value) {
      // Map<String, List<String>> subListMap = {};

      (value as Map).entries.forEach((el) {
        List<String> lawCats =
            (el.value as List).map((e) => (e as String).toUpperCase()).toList();
        // subListMap[(el.key as String).toUpperCase()] = lawCats;

        lawCats.forEach((element) {
          if (element.toUpperCase() != "NULL") {
            subCategoryMap[element.toUpperCase()] = false;
          }
        });
      });
    });

    return subCategoryMap;
  }

  List<String> getAllCategoryNames() {
    List<String> allCategoryNames = [];

    state.forEach((key, value) {
      allCategoryNames.add(key.toUpperCase());

      (value as Map).entries.forEach((el) {
        allCategoryNames.add(el.key.toString().toUpperCase());

        List<String> lawCats =
            (el.value as List).map((e) => (e as String).toUpperCase()).toList();

        allCategoryNames.addAll(lawCats);
      });
    });

    return allCategoryNames;
  }

  Future<Map<String, String>> getIdAndHeadCategories() async {
    Map<String, String> IdAndHeadCategories = {};

    final url = Uri.https(
        project_rtdb, 'category-list.json');
    Map<String, Map<String, List<String>>> loadedCategoryItems = {};

    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        return IdAndHeadCategories;
      }

      if (response.body == 'null') {
        return IdAndHeadCategories;
      }

      final Map<String, dynamic> listData =
          json.decode(utf8.decode(response.bodyBytes));
      // print("response: " + response.body);

      // print("inside of provider: " + listData.toString());

      listData.forEach((key, value) {
        // Map<String, List<String>> subListMap = {};

        IdAndHeadCategories[key as String] = ((value as Map).entries.first.key as String);

        ((value as Map).entries.first.value as Map).entries.forEach((el) {
          List<String> lawCats = (el.value as List)
              .map((e) => (e as String).toUpperCase())
              .toList();
          // subListMap[(el.key as String).toUpperCase()] = lawCats;
        });



        // loadedCategoryItems[((value as Map).entries.first.key as String)
        //     .toUpperCase()] = subListMap;
      });

      // state = loadedCategoryItems;
      // return
    } catch (err) {
      print(err);

      // return false;
    }

    // state = loadedCategoryItems;
    // return loadedCategoryItems;

    return IdAndHeadCategories;
  }

  Future loadAllCategories() async {
    final url = Uri.https(
        project_rtdb, 'category-list.json');
    Map<String, Map<String, List<String>>> loadedCategoryItems = {};

    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        return false;
      }

      if (response.body == 'null') {
        return false;
      }

      final Map<String, dynamic> listData =
          json.decode(utf8.decode(response.bodyBytes));
      print("response: " + response.body);

      print("inside of provider: " + listData.toString());

      listData.forEach((key, value) {
        Map<String, List<String>> subListMap = {};

        ((value as Map).entries.first.value as Map).entries.forEach((el) {
          List<String> lawCats = (el.value as List)
              .map((e) => (e as String).toUpperCase())
              .toList();
          subListMap[(el.key as String).toUpperCase()] = lawCats;
        });

        loadedCategoryItems[((value as Map).entries.first.key as String)
            .toUpperCase()] = subListMap;
      });

      state = loadedCategoryItems;
      // return
    } catch (err) {
      print(err);

      // return false;
    }

    state = loadedCategoryItems;
    return loadedCategoryItems;
  }

  Future saveCategoryCategoryLevel(
    String id,
    String parentCat,
    String text,
  ) async {
    final url = Uri.https(project_rtdb,
        'category-list/${id}.json');

    bool justWriteMode = false;

    state.forEach((key, value) {
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
      map = Map<String, List<String>>.from(state[parentCat]!);
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
      } else {
        // switchMap[text.toUpperCase()] = false;
        // setState(() {
        //   loadedCategoryItems[parentCat] = map;
        // });
      }
    } catch (e) {
      print("ERROR: " + e.toString());

      return false;
    }
  }

  Future saveSubCategoryLevel(String id, bool subCathasnothing,
      String grandParentCat, String parentCat, String text) async {
    // bool justWriteMode = false;
    final url = Uri.https(project_rtdb,
        'category-list/${id}.json');
    Map<String, List<String>> map = {};

    print("HasSubCatNothing: " + subCathasnothing.toString());

    if (subCathasnothing) {
      map = Map<String, List<String>>.from(state[grandParentCat]!);
      map[parentCat] = [text.toUpperCase()];
    } else {
      map = Map<String, List<String>>.from(state[grandParentCat]!);
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
      } else {
        // switchMap[text.toUpperCase()] = false;
        // setState(() {
        //   loadedCategoryItems[grandParentCat] = map;
        // });
      }
    } catch (e) {
      print("ERROR: " + e.toString());
    }

    return true;
  }

  Future saveTurkumLevel(
    String text,
  ) async {
    Map<String, Map<String, List<String>>> loadedCategoryItems =
        Map<String, Map<String, List<String>>>.from(state);

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
      state = loadedCategoryItems;
      // switchMap[text.toUpperCase()] = false;
      // setState(() {
      //   loadedCategoryItems[text.toUpperCase()] = {
      //     "NULL": ["NULL"]
      //   };

      //   IdAndHeadCategories[resData["name"]] = text.toUpperCase();
      // });
    } catch (e) {
      print("TURKUM LEVEL ERROR: " + e.toString());
    }
  }

  // }

  Future<bool> removeCategoryItem(
      String name, Map<String, String> IdAndHeadCategories) async {
    String upperName = name.toUpperCase();
    print("=====================================");
    print(upperName);
    String id = "";
    String parentCat = "";

    Map<String, Map<String, List<String>>> loadedCategoryItems =
        Map<String, Map<String, List<String>>>.from(state);

    if (_findIfTurkumLevel(upperName)) {
      id = _getIdOfTurkum(upperName, IdAndHeadCategories);
      print(id);
      Map<String, List<String>> map =
          Map<String, List<String>>.from(state[upperName]!);

      loadedCategoryItems.remove(upperName);

      try {
        final url = Uri.https('yalchinpro-default-rtdb.firebaseio.com/',
            'category-list/${id}.json');

        final response = await http.delete(url);

        if (response.statusCode >= 400) {
          // ScaffoldMessenger.of(context).clearSnackBars();
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //     content: Text(
          //         "Error: Nosozlik yuz berdi serverdan kategoriya o'chirilmadi!"),
          //     duration: Duration(seconds: 1),
          //   ),
          // );

          loadedCategoryItems[upperName] = map;
          state = loadedCategoryItems;

          return false;
        } else {
          state = loadedCategoryItems;

          return true;
        }
      } catch (e) {
        // ScaffoldMessenger.of(context).clearSnackBars();
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text(
        //         "Error: Nosozlik yuz berdi serverdan kategoriya o'chirilmadi!"),
        //     duration: Duration(seconds: 1),
        //   ),
        // );

        // print("ERROR: NETWORK ERROR");
        return false;
      }

      // loadedCategoryItems.remove(upperName);

      // toBeDeleted = upperName;
    } else if (_findIfCategoryLevel(upperName) != "-1") {
      id = _getIdOfTurkum(_findIfCategoryLevel(upperName), IdAndHeadCategories);
      String turkumCat = "";
      loadedCategoryItems.forEach(
        (key, value) {
          if (value.containsKey(upperName)) {
            turkumCat = key;
          }
        },
      );
      print("turkumCat: " + turkumCat);

      print(id);
      Map<String, List<String>> map =
          Map<String, List<String>>.from(loadedCategoryItems[turkumCat]!);

      if (map.length == 1) {
        loadedCategoryItems[turkumCat]!.addAll({
          "NULL": ["NULL"]
        });
      }

      // setState(() {
      // loadedCategoryItems.remove(upperName);
      loadedCategoryItems[turkumCat]!.remove(upperName);
      // });

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
              turkumCat: loadedCategoryItems[turkumCat],
            },
          ),
        );

        if (response.statusCode >= 400) {
          // ScaffoldMessenger.of(context).clearSnackBars();
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //     content: Text(
          //         "Error: Nosozlik yuz berdi serverdan kategoriya o'chirilmadi!"),
          //     duration: Duration(seconds: 1),
          //   ),
          // );

          // Optional: Show error message
          // setState(() {
          loadedCategoryItems[turkumCat] = map;
          // _ProductItems.insert(index, item);
          // });
          state = loadedCategoryItems;
          return false;
        } else {
          state = loadedCategoryItems;
          return true;
        }
      } catch (e) {
        // ScaffoldMessenger.of(context).clearSnackBars();
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text(
        //         "Error: Nosozlik yuz berdi serverdan kategoriya o'chirilmadi!"),
        //     duration: Duration(seconds: 1),
        //   ),
        // );

        print("ERROR: NETWORK ERROR");
        return false;
      }

      // toBeDeleted = upperName;
    } else if (_findIfSubCategoryLevel(upperName).length == 2) {
      id = _getIdOfTurkum(
          _findIfSubCategoryLevel(upperName)[0], IdAndHeadCategories);

      String turkumCat = _findIfSubCategoryLevel(upperName)[0];

      parentCat = _findIfSubCategoryLevel(upperName)[1];

      print(id);

      Map<String, List<String>> map =
          Map<String, List<String>>.from(loadedCategoryItems[turkumCat]!);
      List<String> list =
          List<String>.from(loadedCategoryItems[turkumCat]![parentCat]!);
      int ind = list.indexOf(upperName);

      if (list.length == 1) {
        // list.add("NULL");
        loadedCategoryItems[turkumCat]![parentCat]!.add("NULL");
      }

      // setState(() {
      // loadedCategoryItems.remove(upperName);
      loadedCategoryItems[turkumCat]![parentCat]!.remove(upperName);
      // });

      try {
        final url = Uri.https(
            project_rtdb,
            'category-list/${id}.json');

        // final response = await http.patch(url);

        final response = await http.patch(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(
            {
              turkumCat: loadedCategoryItems[turkumCat],
            },
          ),
        );

        if (response.statusCode >= 400) {
          // ScaffoldMessenger.of(context).clearSnackBars();
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //     content: Text(
          //         "Error: Nosozlik yuz berdi serverdan kategoriya o'chirilmadi!"),
          //     duration: Duration(seconds: 1),
          //   ),
          // );

          // Optional: Show error message
          // setState(() {
          loadedCategoryItems[turkumCat]![parentCat] = list;
          // _ProductItems.insert(index, item);
          // });
          state = loadedCategoryItems;
          return false;
        }
      } catch (e) {
        // ScaffoldMessenger.of(context).clearSnackBars();
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text(
        //         "Error: Nosozlik yuz berdi serverdan kategoriya o'chirilmadi!"),
        //     duration: Duration(seconds: 1),
        //   ),
        // );

        print("ERROR: NETWORK ERROR");

        return false;
      }
    }

    return true;
  }

  bool _findIfTurkumLevel(String name) {
    bool res = false;
    state.forEach((key, value) {
      if (key == name.toUpperCase()) {
        res = true;
      }
    });

    return res;
  }

  String _findIfCategoryLevel(String name) {
    String res = "-1";

    state.forEach((key, value) {
      for (var el in value.entries) {
        if (el.key == name.toUpperCase()) res = key;
      }
    });

    return res;
  }

  List<String> _findIfSubCategoryLevel(String name) {
    List<String> list = [];

    state.forEach((key, value) {
      for (var el in value.entries) {
        if (el.value.contains(name.toUpperCase())) list.addAll([key, el.key]);
      }
    });

    return list;
  }

  String _getIdOfTurkum(String name, Map<String, String> IdAndHeadCategories) {
    String res = "";
    IdAndHeadCategories.forEach((key, value) {
      if (value == name.toUpperCase()) res = key;
    });

    return res;
  }
}

final categoriesProvider = StateNotifierProvider<CategoryNotify,
    Map<String, Map<String, List<String>>>>((ref) => CategoryNotify());
