import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../data/app_keys.dart';

class ModelNotifier extends StateNotifier<Map<String, List<String>>> {
  ModelNotifier() : super({});

  Future loadModelList() async {
    final url = Uri.https(
        project_rtdb, 'model-list.json');
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

  Future<bool> addModel(String enteredModel) async {
    final url = Uri.https(
        project_rtdb, 'model-list.json');
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
              enteredModel,
              "NULL"
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
        state.entries.first.key: [...state.entries.first.value, enteredModel]
      };
      // state = {id: loadedItems};
    } catch (error) {
      state = {
        state.entries.first.key: [
          ...state.entries.first.value.where((el) => el != enteredModel)
        ]
      };

      return false;
    }
    return true;
  }

  Future<bool> removeItem(enteredModel) async {
    final url = Uri.https(
        project_rtdb, 'model-list.json');
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
              ...state.entries.first.value.where((el) => el != enteredModel),
              "NULL"
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
          ...state.entries.first.value.where((el) => el != enteredModel)
        ]
      };
      // state = {id: loadedItems};
    } catch (error) {
      state = {
        state.entries.first.key: [...state.entries.first.value, enteredModel]
      };

      return false;
    }
    return true;
  }
}

final modelsProvider =
    StateNotifierProvider<ModelNotifier, Map<String, List<String>>>(
        (ref) => ModelNotifier());
