

import 'dart:collection';

// LinkedList list = LinkedList();

List<String> categories = [
  "ELEKTRONIKA", "MAISHIY TEXNIKA"
];

List<String> electronics =[ 
  "SMARTFONLAR", "NOUTBUKLAR", "KOMPYUTER AKSSESSUARLARI"
];

List<String> models = [
  "Iphone 14", "Asus 2232", "Intel 13480H",
];

List<String> brands = [
  "Apple", "IBM", "Artel", "Intel",
];

List<List<String>> sub_categories = [
  electronics,
];

Map<String, List<String>> map = {
  categories[0] : sub_categories[0],
};