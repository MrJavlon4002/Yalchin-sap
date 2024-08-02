import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sap_app/data/app_keys.dart';

class BrandNotify extends StateNotifier<Map<String, List<String>>> {
  BrandNotify() : super({});

  Future loadBrandList() async {
    final url = Uri.https(
        project_rtdb, 'brand-list.json');
    String id;
    final List<String> loadedItems = [];

    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        // setState(() {
        //   _error = "Failed to fetch data. Please try again later.";
        // });
        return false;
      }

      if (response.body == 'null') {
        // setState(() {
        //   _isLoading = false;
        // });
        return false;
      }

      final Map<String, dynamic> listData =
          json.decode(utf8.decode(response.bodyBytes));

      id = listData.entries.first.key;
      for (final item in listData.entries.first.value) {
        if (item.toString().toUpperCase() != "NULL") {
          loadedItems.add(item);
        }
      }

      state = {id: loadedItems};
    } catch (error) {
      return false;
    }
    return {id: loadedItems};
  }

  Future<bool> addBrand(String enteredBrand) async {
    final url = Uri.https(project_rtdb,
        'brand-list.json');
    String id;
    final List<String> loadedItems = [];

    try {
      // final response = await http.patch(url);
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            state.entries.first.key: [
              ...state.entries.first.value,
              enteredBrand, "NULL"
            ],
          },
        ),
      );

      if (response.statusCode >= 400) {
        // setState(() {
        //   _error = "Failed to fetch data. Please try again later.";
        // });
        return false;
      }

      if (response.body == 'null') {
        // setState(() {
        //   _isLoading = false;
        // });
        return false;
      }

      // final Map<String, dynamic> listData =
      //     json.decode(utf8.decode(response.bodyBytes));

      // id = listData.entries.first.key;
      // for (final item in listData.entries.first.value) {
      //   loadedItems.add(item);
      // }
      state = {
        state.entries.first.key: [...state.entries.first.value, enteredBrand]
      };
      // state = {id: loadedItems};
    } catch (error) {
      state = {
        state.entries.first.key: [
          ...state.entries.first.value.where((el) => el != enteredBrand)
        ]
      };

      return false;
    }
    return true;
  }

  Future<bool> removeItem(enteredBrand) async {
    final url = Uri.https(project_rtdb,
        'brand-list.json');
    String id;
    final List<String> loadedItems = [];

    try {
      // final response = await http.patch(url);
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            state.entries.first.key: [
              ...state.entries.first.value.where((el) => el != enteredBrand), "NULL"
            ],
          },
        ),
      );

      if (response.statusCode >= 400) {
        // setState(() {
        //   _error = "Failed to fetch data. Please try again later.";
        // });
        return false;
      }

      if (response.body == 'null') {
        // setState(() {
        //   _isLoading = false;
        // });
        return false;
      }

      // final Map<String, dynamic> listData =
      //     json.decode(utf8.decode(response.bodyBytes));

      // id = listData.entries.first.key;
      // for (final item in listData.entries.first.value) {
      //   loadedItems.add(item);
      // }
      state = {
        state.entries.first.key: [
          ...state.entries.first.value.where((el) => el != enteredBrand)
        ]
      };
      // state = {id: loadedItems};
    } catch (error) {
      state = {
        state.entries.first.key: [...state.entries.first.value, enteredBrand]
      };

      return false;
    }
    return true;
  }
}

final brandsProvider =
    StateNotifierProvider<BrandNotify, Map<String, List<String>>>(
        (ref) => BrandNotify());
