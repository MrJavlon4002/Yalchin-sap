import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sap_app/models/product_item.dart';
import 'package:sap_app/providers/product_provider.dart';

class LoadFromExcelScreen extends ConsumerStatefulWidget {
  const LoadFromExcelScreen({super.key});

  @override
  ConsumerState<LoadFromExcelScreen> createState() =>
      _LoadFromExcelScreenState();
}

class _LoadFromExcelScreenState extends ConsumerState<LoadFromExcelScreen> {
  String? filePath;
  List<List<dynamic>> _data = [];
  File? _pickedFile;
  List<File> selectedImages = [];

  Future getImages() async {
    ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickMultiImage(
        imageQuality: 30, // To set quality of images
        maxHeight: 1000, // To set maxheight of images that you want in your app
        maxWidth: 1000); // To set maxheight of images that you want in your app
    List<XFile> xfilePick = pickedFile;

    // if atleast 1 images is selected it will add
    // all images in selectedImages
    // variable so that we can easily show them in UI
    if (xfilePick.isNotEmpty) {
      for (var i = 0; i < xfilePick.length; i++) {
        selectedImages.add(File(xfilePick[i].path));
      }

      for (var img in selectedImages) {
        print(img.path);
      }

      setState(
        () {},
      );
    } else {
      // If no image is selected it will show a
      // snackbar saying nothing is selected
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Nothing is selected')));
    }
  }

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      PlatformFile file = result.files.first;

      final input = File(file.path!).openRead();
      final fields = await input
          .transform(utf8.decoder)
          .transform(CsvToListConverter())
          .toList();

      // final modifiedFields = fields.map(
      //   (e) {
      //     final el = List<dynamic>.from(e);
      //     return el.map((v) => v as String).toList();
      //   },
      // ).toList();

      setState(() {
        _data = fields.sublist(1);
      });

      await getImages();
      int count = 1;
      // _data[]
      for (var row in _data) {
        // if (count == 1) continue;
        print("======================");
        String imageName = row[4].toString();
        String path = "";
        XFile? file;
        selectedImages.forEach(
          (img) {
            // print("${img.path.split("/").last.toUpperCase()} - ${(imageName+".jpg").toUpperCase()} ");
            if (img.path.split("/").last.toUpperCase() ==
                ("scaled_" + imageName + ".jpg").toUpperCase()) {
              path = img.path.toString();
              print(img.path);
              file = XFile(img.path);
            }
          },
        );
        print(
            "name: ${(row[0].toString())} + ${(row[1].toString())} \n brand: ${row[0].toString()} \n model: ${row[1]} \n price: ${int.tryParse(row[2].toString()) != null ? row[2] : 1} \n category: ${row[3]} \n imageName: ${path}");
        print("======================");
        print("XFile: ${file != null ? file!.name.toString() : "false"}");

        
        Future.delayed(const Duration(milliseconds: 1000), () {
// Here you can write your code
          print(count);
        
        });
        final res = await ref.read(productsProvider.notifier).saveItem(
            pickedFile: file,
            enteredName: "${(row[0].toString())}  ${(row[1].toString())}",
            enteredDescription: "",
            enteredModel: row[1].toString(),
            enteredBrand: row[0].toString(),
            enteredBoxCount: 1,
            enteredPrice: int.tryParse(row[2].toString()) != null
                ? int.parse(row[2].toString())
                : 1,
            pickedColor: Colors.white,
            enteredQuantity: 1,
            submitTime: DateTime.now().toString(),
            enteredCurrency: "UZS",
            selectedCategory: "");
        print(res);
        count += 1;
        // print(count);
      }

      // fields.forEach(
      //   (el) {
      //     print(el);
      //   },
      // );

      // print(fields);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlue,
          title: Text("CSV dan ma'lumotlarni olish"),
        ),
        body: ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: _data.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemBuilder: (_, index) {
            // _data.skip(index);
            return Card(
              margin: const EdgeInsets.all(3),
              color: index == 0 ? Colors.amber : Colors.white,
              child: ListTile(
                leading: Text(
                  _data[index][0] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: index == 0 ? 18 : 15,
                      fontWeight:
                          index == 0 ? FontWeight.bold : FontWeight.normal,
                      color: index == 0 ? Colors.red : Colors.black),
                ),
                title: Text(
                  _data[index][1].toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: index == 0 ? 18 : 15,
                      fontWeight:
                          index == 0 ? FontWeight.bold : FontWeight.normal,
                      color: index == 0 ? Colors.red : Colors.black),
                ),
                trailing: Text(
                  _data[index][4].toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: index == 0 ? 18 : 15,
                      fontWeight:
                          index == 0 ? FontWeight.bold : FontWeight.normal,
                      color: index == 0 ? Colors.red : Colors.black),
                ),
              ),
            );
          },
        ),

        floatingActionButton: FloatingActionButton(onPressed: (){
          _pickFile();
        }, child: Icon(Icons.upload_file),),
        // );
        );
  }
}
