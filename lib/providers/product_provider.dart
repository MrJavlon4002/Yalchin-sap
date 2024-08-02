import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

// import 'package:flutter_provider/flutter_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sap_app/models/user.dart';
import 'package:sap_app/models/product_item.dart';
import 'package:sap_app/widgets/loginPage.dart';

import '../data/app_keys.dart';

// import '../data/categories.dart';

class ProductNotifier extends StateNotifier<List<ProductItem>> {
  ProductNotifier() : super([]);

  Future uploadFile(XFile? file) async {
    String _imageUrl;
    // final path = 'images/${pickedFile!.name}';
    // final file = File(pickedFile!.path!);

    // final ref = FirebaseStorage.instance.ref().child(path);
    // ref.putFile(file);

    if (file == null) return false;

    Reference reference = FirebaseStorage.instance.ref();

    Reference referenceDirImages = reference.child("images");

    Reference referenceToUpload = referenceDirImages.child(file.name);

    try {
      await referenceToUpload.putFile(File(file.path));

      _imageUrl = await referenceToUpload.getDownloadURL();
    } catch (error) {
      print(error);
      return false;
    }

    return _imageUrl;
  }

  Future<List<ProductItem>> loadItems() async {
    final url = Uri.https(
        project_rtdb, 'shopping-list.json');

    try {
      final response = await http.get(url);

      print(response.statusCode);
      if (response.statusCode >= 400) {
        // setState(() {
        //   _error = "Failed to fetch data. Please try again later.";
        // });
        return [];
      }
      // print("responseBody: "+response.body.toString());
      if (response.body == 'null') {
        // setState(() {
        //   _isLoading = false;
        // });
        return [];
      }

      final Map<String, dynamic> listData =
          json.decode(utf8.decode(response.bodyBytes));

      print(listData);
      final List<ProductItem> loadedItems = [];
      // var categories = categoriesGlobal;
      

      for (final item in listData.entries) {
        // final category = categories.firstWhere(
        //     (element) => element == item.value['category'] as String);

        // print(item.value['factionList'].runtimeType);d
        // var factionListL = item.value['factionList'];
        // print(factionListL);
        // print("listData:"+item.toString());
        // print(loadedItems);
        loadedItems.add(
          ProductItem(
            id: item.key,
            name: item.value['name'] as String,
            description: item.value['description'] as String,
            price: item.value['price'],
            boxCount: item.value['boxCount'],
            currency: item.value['currency'],
            quantity: item.value["quantity"],
            model: item.value["model"].toString(),
            brand: item.value["brand"].toString(),
            submitTime: item.value['submitTime'],
            color: Color(int.parse(item.value['color'].toString())),
            imageUrl: item.value["imageUrl"] as String,
            factionList: (item.value['factionList'] as List)
                .map((e) => e as String)
                .toList(),
            category: item.value["category"].toString(),
          ),
        );
      }
      print(loadedItems);
      state = loadedItems;
    } catch (error) {
      // print(loadedItems);

      print("Error:" + error.toString());
      print("Something  wrong with loadItems function inside of products provider");
      return [];
    }

    print(state);

    return state;
  }

  Future<bool> removeItem(ProductItem item) async {
    // final index = state.indexOf(item);

    List<ProductItem> productList = state;

    productList =
        productList.where((element) => element.id != item.id).toList();

    try {
      final url = Uri.https(project_rtdb,
          'shopping-list/${item.id}.json');

      final response = await http.delete(url);

      if (response.statusCode >= 400) {
        // Optional: Show error message
        // setState(() {
        productList = [...productList, item];

        return false;
        // });
      }
    } catch (e) {
      print("Error: " + e.toString());
      return false;
    }

    state = productList;
    return true;
  }

  Future<List<ProductItem>> filterItems(
      List<String> models,
      List<String> brands,
      List<String> categories,
      List<ProductItem> groceryList) async {
    List<ProductItem> filteredItems = [];

    state.forEach((item) {
      if (categories.contains(item.category) ||
          item.factionList!.any((element) => categories.contains(element)))
        filteredItems.add(item);
    });

    if (categories.isEmpty) filteredItems.addAll(state);

    if (brands.isNotEmpty) {
      filteredItems =
          filteredItems.where((item) => brands.contains(item.brand)).toList();
    }
    if (models.isNotEmpty) {
      filteredItems =
          filteredItems.where((item) => models.contains(item.model)).toList();
    }
    print("product_provider insider: " + filteredItems.toString());
    return filteredItems;
  }

  Future<ProductItem> saveItem(
      {required XFile? pickedFile,
      required String enteredName,
      required String enteredDescription,
      required String enteredModel,
      required String enteredBrand,
      required int enteredBoxCount,
      required int enteredPrice,
      required Color pickedColor,
      required int enteredQuantity,
      required String submitTime,
      required String enteredCurrency,
      // required String imageUrl,
      required String selectedCategory}) async {

    

    int testingColorValue = pickedColor.value;
    String testingColorString = pickedColor.toString();

    String imageUrl = '';

    Color newColor = new Color(testingColorValue);
    print(testingColorValue);
    print(newColor.toString());
    

    final url = Uri.https(
        project_rtdb, 'shopping-list.json');

    if (imageUrl.isNotEmpty || pickedFile!=null) {
      imageUrl = await uploadFile(pickedFile);
    }

    print(imageUrl);

    // Color pickedColor = new Color(0xff443a49);

    // await getImageUrl();

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(
        {
          'name': enteredName,
          'description': enteredDescription,
          'quantity': enteredQuantity,
          'price': enteredPrice,
          'model': enteredModel,
          'brand': enteredBrand,
          'submitTime': submitTime,
          'color': pickedColor.value,
          'category': selectedCategory.isEmpty ? "TANLANMAGAN" : selectedCategory,
          'factionList': [selectedCategory.isEmpty ? "TANLANMAGAN" : selectedCategory],
          'boxCount': enteredBoxCount,
          'currency': enteredCurrency,
          'imageUrl': imageUrl,
        },
      ),
    );

    print("response: (SaveItem)"+response.body.toString());

    final Map<String, dynamic> resData = json.decode(response.body);
    print("id: "+resData["name"].toString());
    ProductItem item = ProductItem(
      id: resData['name'],
      currency: enteredCurrency,
      boxCount: enteredBoxCount,
      name: enteredName,
      description: enteredDescription,
      price: enteredPrice,
      quantity: enteredQuantity,
      // boxCount: enteredBoxCount,
      factionList: [selectedCategory],
      model: enteredModel,
      brand: enteredBrand,
      submitTime: submitTime,
      color: pickedColor,
      category: selectedCategory,
      imageUrl: imageUrl,
    );
    print(resData);

    state = [...state, item];

    return item;
  }

  Future<dynamic> modifyItem(
    ProductItem item,
  ) async {
    List<ProductItem> productList = state;

    // String imageUrl = '';

    try {
      // if (pickedFile != null) {
      //   imageUrl = await uploadFile(pickedFile);
      // }

      productList = productList.where((el) => el.id != item.id).toList();

      final url = Uri.https(project_rtdb,
          'shopping-list/${item.id}.json');

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(
          {
            'name': item.name,
            'description': item.description,
            'quantity': item.quantity,
            'price': item.price,
            'model': item.model,
            'brand': item.brand,
            'submitTime': item.submitTime,
            'color': item.color.value,
            'category': item.category,
            'factionList': [item.category],
            'boxCount': item.boxCount,
            'currency': item.currency,
            'imageUrl': item.imageUrl,
          },
        ),
      );

      if (response.statusCode >= 400){
        print("not updated!");

      }
    } catch (e) {
      
      return null;
    }
    productList.add(item);

    // item.imageUrl = imageUrl;
    state = productList;

    return item;
  }
}

final productsProvider =
    StateNotifierProvider<ProductNotifier, List<ProductItem>>(
        (ref) => ProductNotifier());
