import 'dart:ui';

import 'package:flutter/foundation.dart';

class ProductItem {
  ProductItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.category,
    required this.model,
    required this.brand,
    required this.color,
    required this.currency,
    required this.submitTime,
    required this.imageUrl,
    required this.boxCount,
    this.factionList,
  });

  String id;
  String name;
  String? description;
  int price;
  int quantity;
  String currency;
  int boxCount;
  String model;
  String category;
  String brand;
  Color color;
  String submitTime;
  String imageUrl;

  List<String>? factionList = [];

  @override
  String toString() {
    // TODO: implement toString
    // this.toString()
    return "{id: ${id} , name: ${name}, description: ${description},price: ${price},quantity: ${quantity},currency: ${currency},boxCount: ${boxCount},model: ${model},category: ${category},brand: ${brand},color: ${color},submitTime: ${submitTime},imageUrl: ${imageUrl},}";
  }

  // String get price => this.price;
}
