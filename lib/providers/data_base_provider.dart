import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sap_app/models/product_item.dart';

class DataBaseNotifier extends StateNotifier<dynamic> {
  DataBaseNotifier() : super([]);


 

  
}

final databaseProvider =
    StateNotifierProvider<DataBaseNotifier, dynamic>(
        (ref) => DataBaseNotifier());
