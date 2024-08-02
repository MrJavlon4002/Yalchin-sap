import 'dart:io';

import 'package:currency_symbols/currency_symbols.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sap_app/models/product_item.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../data/currencies.dart';
import '../providers/brand_provider.dart';
import '../providers/category_provider.dart';
import '../providers/model_provider.dart';
import '../providers/product_provider.dart';

class EditItemScreen extends ConsumerStatefulWidget {
  EditItemScreen({super.key, required this.productItem});

  ProductItem productItem;

  @override
  ConsumerState<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends ConsumerState<EditItemScreen> {
  var _enteredName = "";
  var _enteredDescription = '';
  var _enteredPrice = 1;
  var _enteredQuantity = 1;
  String _selectedCategory = "";
  var _enteredModel = '';
  var _enteredBrand = '';
  var _submitTime = '';
  var _selectedCurrency = currencies[0];
  // var _selectedCurrency = ;

  var _isSending = false;
  var _enteredBoxCount = 1;

  late String _imageUrl;
  Color _defaultColor = Color.fromARGB(255, 0, 0, 0);
  Color _pickedColor = Color.fromARGB(255, 0, 0, 0);
  Color currentColor = Color(0xff443a49);

  Color selectedColor = Colors.amber;

  final _formKey = GlobalKey<FormState>();
  XFile? pickedFile;
  File? _compressedImage;

  Map<String, Map<String, List<String>>> _categoriesMap = {};

  Map<String, List<String>> _models = {};
  Map<String, List<String>> _brands = {};

  void changeColor(Color color) {
    setState(() => _pickedColor = color);
  }

  Future _selectImage() async {
    // final result = await FilePicker.platform.pickFiles();
    ImagePicker imagePicker = ImagePicker();

    XFile? file = await imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 30);

    setState(() {
      pickedFile = file;
    });
  }

  // Future<XFile?> compressFile({required XFile? file}) async {
  //   XFile? result;
  //   if (file != null) {
  //     final filePath = file.path;
  //     final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
  //     final splitted = filePath.substring(0, (lastIndex));
  //     final outPath = '${splitted}_out${filePath.substring(lastIndex)}';
  //     result = await FlutterImageCompress.compressAndGetFile(
  //       file.path,
  //       outPath,
  //       quality: 80,
  //     );
  //   }

  //   // Create output file path
  //   // eg:- "Volume/VM/abcd_out.jpeg"
  //   return result;
  // }

  Future uploadFile(XFile? file) async {
    String _imageUrl;

    // final img = await compressFile(file: pickedFile);

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

  void _modifyItem() async {
    setState(() {
      _isSending = true;
    });

    _formKey.currentState!.save();

    if (pickedFile != null) {
      _imageUrl = await uploadFile(pickedFile);
    }
    print("imageUrl: " + _imageUrl);

    ProductItem item = ProductItem(
        id: widget.productItem.id,
        name: _enteredName.isNotEmpty ? _enteredName : widget.productItem.name,
        description: _enteredDescription.isNotEmpty
            ? _enteredDescription
            : widget.productItem.name,
        price: _enteredPrice != 1 ? _enteredPrice : widget.productItem.price,
        quantity: _enteredQuantity != 1
            ? _enteredQuantity
            : widget.productItem.quantity,
        category: _selectedCategory.isNotEmpty
            ? _selectedCategory
            : widget.productItem.category,
        model:
            _enteredModel.isNotEmpty ? _enteredModel : widget.productItem.model,
        brand:
            _enteredBrand.isNotEmpty ? _enteredBrand : widget.productItem.brand,
        color: compare(_defaultColor, _pickedColor) ||
                compare(_pickedColor, widget.productItem.color)
            ? widget.productItem.color
            : _pickedColor,
        currency: _selectedCurrency == widget.productItem.currency
            ? _selectedCurrency
            : widget.productItem.currency,
        submitTime: DateTime.now().toString(),
        imageUrl:
            _imageUrl.isNotEmpty ? _imageUrl : widget.productItem.imageUrl,
        boxCount: _enteredBoxCount != 1
            ? _enteredBoxCount
            : widget.productItem.boxCount,
        factionList: [
          _selectedCategory.isNotEmpty
              ? _selectedCategory
              : widget.productItem.category
        ]);

    print(item);
    try {
      var res = await ref.read(productsProvider.notifier).modifyItem(item);

      if (res == null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error: mahsulot serverda o'zgartirilmadi!"),
            duration: Duration(seconds: 1),
          ),
        );
        // SnackBar(content: SnackBarAction(label: label, onPressed: onPressed))
      }
      // if (!context.mounted) {
      //   return;
      // }
      setState(() {
        _isSending = false;
      });

      if (res==null) return;
      
      Navigator.of(context).pop(item);
    } catch (e) {
      setState(() {
        _isSending = false;
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: mahsulot serverda o'zgartirilmadi!"),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  bool compare(Color color1, Color color2) {
    return color1.red == color2.red &&
        color1.green == color2.green &&
        color1.blue == color2.blue;
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

  @override
  void initState() {
    // TODO: implement initState
    _imageUrl = '';
    // _setSettings();
    ref.read(brandsProvider.notifier).loadBrandList();
    ref.read(modelsProvider.notifier).loadModelList();
    super.initState();
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
        title: Text("Mahsulotni o'zgartirish"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: widget.productItem.name,
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
                initialValue: widget.productItem.description,
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
                      initialValue: widget.productItem.brand,
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
                      initialValue: widget.productItem.model,
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
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Miqdori'),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: widget.productItem.quantity.toString(),
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
                    child: DropdownButtonFormField(
                        // key: _formKey,
                        value: _categoriesMap.keys.toList()[0],
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
                                    Text(category)
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
                        label: Text('karobka soni: ?'),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: widget.productItem.boxCount.toString(),
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
                      decoration: const InputDecoration(
                        label: Text('Mahsulot narxi '),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: widget.productItem.price.toString(),
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
                                  Text(currency)
                                ])),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCurrency = value!;
                          });
                        }),
                  ),
                  TextButton(
                    onPressed: _isSending ? null : _selectImage,
                    child: const Text("Rasm tanlash"),
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          // backgroundColor: _pickedColor,
                          ),
                      onPressed: () {
                        showPicker();
                      },
                      child: Text("Rang tanlash")),
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
              Container(
                child: pickedFile != null
                    ? Container(
                        height: 300,
                        child: Center(
                          // child: Text(pickedFile!.name),
                          child: Image.file(
                            File(pickedFile!.path),
                            width: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Center(child: Text("Rasm tanlang")),
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
                  ElevatedButton(
                    onPressed: _isSending ? null : _modifyItem,
                    child: _isSending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text("O'zgartirish"),
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
