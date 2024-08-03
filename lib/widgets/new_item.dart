import 'dart:convert';

// import 'dart:html';
import 'dart:io';

import 'package:currency_symbols/currency_symbols.dart';

// import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

// import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

// import './pickers/hsv_picker.dart';
// import './pickers/material_picker.dart';
// import './pickers/block_picker.dart';

import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:sap_app/data/currencies.dart';
import 'package:sap_app/providers/brand_provider.dart';
import 'package:sap_app/providers/category_provider.dart';
import 'package:sap_app/providers/model_provider.dart';
import 'package:sap_app/providers/product_provider.dart';
import 'package:sap_app/widgets/grocery_list.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

import 'package:http/http.dart' as http;
import 'package:sap_app/models/product_item.dart';

import 'package:sap_app/models/category.dart';
// import 'package:sap_app/models/grocery_item.dart';

import '../data/categories.dart';

class NewItem extends ConsumerStatefulWidget {
  const NewItem({super.key});

  @override
  ConsumerState<NewItem> createState() => _NewItemState();
}

class _NewItemState extends ConsumerState<NewItem> {
  final _formKey = GlobalKey<FormState>();
  XFile? pickedFile;
  final ImagePicker _picker = ImagePicker();


  Map<String, Map<String, List<String>>> _categoriesMap = {};

  Map<String, List<String>> _models = {};
  Map<String, List<String>> _brands = {};

  late String _imageUrl;

  // final storage = FirebaseStorage.instance;

  var _enteredName = '';
  var _enteredDescription = '';
  var _enteredPrice = 1;
  var _enteredQuantity = 1;
  String _selectedCategory = "";
  var _enteredModel = '';
  var _enteredBrand = '';
  var _submitTime = '';
  var _selectedCurrency = currencies[0];

  var _isSending = false;
  var _enteredBoxCount = 1;

  Color _pickedColor = Color.fromARGB(255, 0, 0, 0);
  Color currentColor = Color(0xff443a49);

  Color selectedColor = Colors.amber;

  @override
  void initState() {
    // TODO: implement initState
    _imageUrl = '';
    // _setSettings();
    ref.read(brandsProvider.notifier).loadBrandList();
    ref.read(modelsProvider.notifier).loadModelList();
    // Provider.of()
    // _selectedCategory = _categoriesMap.keys.toList()[0];
    super.initState();
  }


  Future<void> _selectImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 30);
    setState(() {
      pickedFile = file;
    });
  }

  void _clearImage() {
    setState(() {
      pickedFile = null;
    });
  }

  void _setSettings() async {
    ref.read(categoriesProvider.notifier).loadAllCategories();
    // _categoriesMap = await ref.watch(categoriesProvider);
    // _selectedCategory = _categoriesMap.keys.toList()[0];
  }

  // Future _selectImage() async {
  //   // final result = await FilePicker.platform.pickFiles();
  //   ImagePicker imagePicker = ImagePicker();
  //
  //   XFile? file = await imagePicker.pickImage(
  //       source: ImageSource.gallery, imageQuality: 30);
  //
  //   setState(() {
  //     pickedFile = file;
  //   });
  // }

  Future<Database> _getDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    final db = await sql.openDatabase(
      path.join(dbPath, 'mahsulotlar.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE mahsulotlar(id TEXT PRIMARY KEY, name TEXT, image TEXT)');
      },
      version: 1,
    );

    return db;
  }

  Future showPicker() {
    // raise the [showDialog] widget

    return showDialog(
      builder: (context) => AlertDialog(
        title: const Text('Rang tanlang!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _pickedColor,
            onColorChanged: changeColor,
          ),
          // Use Material color picker:
          //
          // child: MaterialPicker(
          //   _pickedColor: _pickedColor,
          //   onColorChanged: changeColor,
          // ),
          //
          // Use Block color picker:
          //
          // child: BlockPicker(
          //   _pickedColor: currentColor,
          //   onColorChanged: changeColor,
          // ),
          //
          // child: MultipleChoiceBlockPicker(
          //   _pickedColors: currentColor,
          //   onColorsChanged: changeColors,
          // ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Tanladim'),
            onPressed: () {
              setState(() => currentColor = _pickedColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      context: context,
    );
  }

  // create some values

// ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() => _pickedColor = color);
  }

  void loadDb() async {
    final db = await _getDatabase();
    final data = await db.query('mahsulotlar');
    data.map((row) {
      ProductItem(
        id: row['id'] as String,
        name: row['name'] as String,
        currency: row['currency'] as String,
        boxCount: row['boxCount'] as int,
        description: row['description'] as String,
        price: row['price'] as int,
        category: row['category'] as String,
        quantity: row['quantity'] as int,
        model: row['model'] as String,
        brand: row['brand'] as String,
        submitTime: row["submitTime"] as String,
        color: Color(row['color'] as int),
        factionList: [],
        imageUrl: row['imageUrl'] as String,
      );
    });
  }

  void _saveItem() async {
    int testingColorValue = _pickedColor.value;
    String testingColorString = _pickedColor.toString();

    Color newColor = new Color(testingColorValue);
    print(testingColorValue);
    print(newColor.toString());

    if (_formKey.currentState!.validate()) {
      _isSending = true;

      _formKey.currentState!.save();

      ref.read(modelsProvider.notifier).addModel(_enteredModel);
      ref.read(brandsProvider.notifier).addBrand(_enteredBrand);
      // if (_enteredModel.isEmpty) {
      //   _enteredModel = _models.entries.first.value[0];
      // }
      // if (_enteredBrand.isEmpty) {
      //   _enteredBrand = _models.entries.first.value[0];
      // }
      if (_selectedCategory.isEmpty) {
        _selectedCategory = "TANLANMAGAN";
      }

      ref.read(productsProvider.notifier).saveItem(
            pickedFile: pickedFile,
            enteredName: _enteredName,
            enteredDescription: _enteredDescription,
            enteredModel: _enteredModel,
            enteredBrand: _enteredBrand,
            enteredBoxCount: _enteredBoxCount,
            enteredPrice: _enteredPrice,
            pickedColor: _pickedColor,
            enteredQuantity: _enteredQuantity,
            submitTime: _submitTime,
            enteredCurrency: _selectedCurrency,
            selectedCategory: _selectedCategory,
          );
      // final url = Uri.https('shoppinglist-e99e0-default-rtdb.firebaseio.com',
      //     'shopping-list.json');

      // ref.read(productsProvider.notifier).saveItem(
      //       enteredBoxCount: _enteredBoxCount,
      //       enteredBrand: _enteredBrand,
      //       enteredDescription: _enteredDescription,
      //       enteredModel: _enteredModel,
      //       enteredName: _enteredName,
      //       enteredPrice: _enteredPrice,
      //       enteredQuantity: _enteredQuantity,
      //       pickedColor: _pickedColor,
      //       pickedFile: pickedFile,
      //       selectedCategory: _selectedCategory,
      //       enteredCurrency: _selectedCurrency,
      //       submitTime: DateTime.now().toString(),
      //     );

      print(_imageUrl);

      setState(() {
        _isSending = false;
      });
      // Color _pickedColor = new Color(0xff443a49);

      // await _getImageUrl();

      if (!context.mounted) {
        return;
      }

      setState(() {
        _isSending = false;
      });

      ref.watch(productsProvider);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => GroceryList()));

      // final appDir = await syspaths.getApplicationDocumentsDirectory();
      // final db = await _getDatabase();
      // db.insert('mahsulotlar', {
      //   'id': resData['name'],
      //   'name': _enteredName,
      //   'category': _selectedCategory,
      //   'description': _enteredDescription,
      //   'quantity': _enteredQuantity,
      //   'boxCount': _enteredBoxCount,
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(productsProvider);
    _brands = ref.watch(brandsProvider);
    _models = ref.watch(modelsProvider);
    _categoriesMap = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        title: const Text("Yangi mahsulot qo'shish"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                maxLength: 200,
                decoration: const InputDecoration(
                  label: Text('Mahsulot nomi'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 200) {
                    return "Mahsulot nomi 1 va 200 belgi oralig'ida bo'lishi kerak";
                  }
                  return null;
                },
                onSaved: (value) {
                  // if (value==null){
                  //   return "";
                  // }
                  _enteredName = value!;
                  print(_enteredName);
                },
              ),
              TextFormField(
                maxLength: 500,

                decoration: const InputDecoration(
                  label: Text('Mahsulot haqida ta\'rif (ixtiyoriy)'),
                ),
                // validator: (value) {
                //   if (value == null ||
                //       value.isEmpty ||
                //       value.trim().length <= 1 ||
                //       value.trim().length > 100) {
                //     return "Must be between 1 and 100 characters.";
                //   }
                //   return null;
                // },
                onSaved: (value) {
                  // if (value==null){
                  //   return "";
                  // }

                  _enteredDescription = value!;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      maxLength: 200,
                      decoration: const InputDecoration(
                        label: Text('Brand nomi'),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.trim().length <= 1 ||
                            value.trim().length > 200) {
                          return "Brand nomi 1 va 200 belgi oralig'ida bo'lishi kerak";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        // if (value==null){
                        //   return "";
                        // }
                        _enteredBrand = value!;
                        print(_enteredName);
                      },
                    ),
                  ),

                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextFormField(
                      maxLength: 200,
                      decoration: const InputDecoration(
                        label: Text('Model nomi'),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.trim().length <= 1 ||
                            value.trim().length > 200) {
                          return "Model nomi 1 va 200 belgi oralig'ida bo'lishi kerak";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        // if (value==null){
                        //   return "";
                        // }
                        _enteredModel = value!;
                        print(_enteredName);
                      },
                    ),
                  ),

                  //   Expanded(
                  //     child: DropdownButtonFormField(
                  //         // key: _formKey,
                  //         // onSaved:(newValue) {

                  //         // },
                  //         value: _brands.isNotEmpty
                  //             ? _brands.entries.first.value[0]
                  //             : "Mavjud emas",
                  //         items: [
                  //           if (_brands.isNotEmpty)
                  //             for (final brand in _brands.entries.first.value)
                  //               DropdownMenuItem(
                  //                   value: brand,
                  //                   child: Row(children: [
                  //                     Container(
                  //                       width: 16,
                  //                       height: 16,
                  //                       // color: Colors.indigoAccent,
                  //                       // child: Text(brand.value.title),
                  //                       child: Icon(
                  //                         Icons.copyright_outlined,
                  //                         size: 16,
                  //                       ),
                  //                     ),
                  //                     const SizedBox(
                  //                       width: 6,
                  //                     ),
                  //                     Text(brand)
                  //                   ])),
                  //         ],
                  //         onChanged: (value) {
                  //           setState(() {
                  //             if (value!.isEmpty) {
                  //               _enteredBrand = _brands.entries.first.value[0];
                  //             } else {
                  //               _enteredBrand = value;
                  //             }
                  //           });
                  //         }),
                  //   ),
                  //   SizedBox(
                  //     width: 10,
                  //   ),
                  //   Expanded(
                  //     child: DropdownButtonFormField(
                  //         value: _models.isNotEmpty
                  //             ? _models.entries.first.value[0]
                  //             : "Mavjud emas",
                  //         items: [
                  //           if (_models.isNotEmpty)
                  //             for (final model in _models.entries.first.value)
                  //               DropdownMenuItem(
                  //                   value: model,
                  //                   child: Row(children: [
                  //                     Container(
                  //                       width: 16,
                  //                       height: 16,
                  //                       // color: Colors.indigoAccent,,
                  //                       child: Icon(
                  //                         Icons.move_down_outlined,
                  //                         size: 16,
                  //                       ),
                  //                       // child: Text(model.value.title),
                  //                     ),
                  //                     const SizedBox(
                  //                       width: 6,
                  //                     ),
                  //                     Text(model)
                  //                   ])),
                  //         ],
                  //         onChanged: (value) {
                  //           setState(() {
                  //             if (value!.isEmpty) {
                  //               _enteredModel = _models.entries.first.value[0];
                  //             } else {
                  //               _enteredModel = value;
                  //             }
                  //           });
                  //         }
                  //         ),
                  //   ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Miqdori'),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: '1',
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return "To'gri son kiriting";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField(
                        isExpanded: true,
                        // key: _formKey,
                        value: _categoriesMap.keys.toList()[_categoriesMap.keys
                            .toList()
                            .indexOf("TANLANMAGAN")],
                        items: [
                          if (_categoriesMap.isNotEmpty)
                            for (final category in _categoriesMap.keys)
                              DropdownMenuItem(
                                  value: category,
                                  child: Row(children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      // color: Colors.indigoAccent,
                                      child: Icon(
                                        Icons.category,
                                        size: 16,
                                      ),
                                      // child: Text(category.value.title),
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    FittedBox(
                                      child: Text(
                                        category,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                  ])),
                        ],
                        onChanged: (value) {
                          setState(() {
                            if (value == null || value.isEmpty) {
                              _selectedCategory =
                                  _categoriesMap.keys.toList()[0];
                            } else {
                              _selectedCategory = value;
                            }
                          });
                        }),
                  ),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Nechta qutida(karobka)?'),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: '1',
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return "To'gri son kiriting";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredBoxCount = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: TextFormField(
                      onTap: () {},
                      decoration: const InputDecoration(
                        label: Text('Mahsulot narxi '),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: '0',
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! < 0) {
                          return "To'gri son kiriting";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredPrice = int.parse(value!);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                      isExpanded: true,
                        value: _selectedCurrency,
                        items: [
                          for (final currency in currencies)
                            DropdownMenuItem(
                                value: currency,
                                child: Row(children: [
                                  Text(
                                    cSymbol(currency),
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  FittedBox(
                                      fit: BoxFit.contain,
                                      child: Text(currency))
                                ])),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCurrency = value!;
                          });
                        }),
                  ),
                  // TextButton(
                  //   onPressed: _isSending ? null : _selectImage,
                  //   child: const Text("Rasm tanlash"),
                  // ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          // backgroundColor: _pickedColor,
                          ),
                      onPressed: () {
                        showPicker();
                      },
                      child: Text(
                        "Rang tanlash",
                        style: TextStyle(color: Colors.black),
                      )),
                  SizedBox(
                    width: 20,
                  ),
                  ClipOval(
                    child: Container(
                      width: 30,
                      height: 30,
                      color: _pickedColor,
                    ),
                  )
                  // ElevatedButton(
                  //   onPressed: _isSending ? null : _saveItem,
                  //   child: _isSending
                  //       ? const SizedBox(
                  //           height: 16,
                  //           width: 16,
                  //           child: CircularProgressIndicator(),
                  //         )
                  //       : const Text("Qo'shish"),
                  // ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              // Container(
              //   child: pickedFile != null
              //       ? Container(
              //           height: 300,
              //           child: Center(
              //             // child: Text(pickedFile!.name),
              //             child: Image.file(
              //               File(pickedFile!.path),
              //               width: double.infinity,
              //               fit: BoxFit.contain,
              //             ),
              //           ),
              //         )
              //       : Container(
              //           decoration: BoxDecoration(
              //             border: Border.all(
              //               width: 2,
              //             ),
              //           ),
              //           child: Padding(
              //             padding: const EdgeInsets.all(40.0),
              //             child: Center(child: Text("Rasm tanlang")),
              //           ),
              //         ),
              // ),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: pickedFile == null
                      ? InkWell(
                    onTap: _selectImage,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.cloud_upload_rounded, size: 50),
                        SizedBox(height: 10),
                        Text('Rasmni yuklang', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  )
                      : Stack(
                    children: [
                      Image.file(
                        File(pickedFile!.path),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.clear, color: Colors.red),
                            onPressed: _clearImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // if ()

              SizedBox(
                height: 20,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                          },
                    child: const Text("Tozalash"),
                  ),
                  MaterialButton(
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    onPressed: _isSending ? null : _saveItem,

                    child: _isSending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text(
                            "Qo'shish",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
