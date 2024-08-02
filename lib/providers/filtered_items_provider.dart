import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sap_app/models/product_item.dart';

class FilterNotify extends StateNotifier<List<ProductItem>> {
  FilterNotify() : super([]);


  void filterCategory(Map<String, bool> turkumMap, Map<String, bool> categoryMap, Map<String, bool> subCategoryMap){
    
  }

  void filterModel(List<String> models){

  }

  void filterBrand(List<String> brands){
    // state.clear();
  }

  void clearState(){
    state.clear();
  }


  
}

final filteredItemsProvider =
    StateNotifierProvider<FilterNotify, List<ProductItem>>(
        (ref) => FilterNotify());
