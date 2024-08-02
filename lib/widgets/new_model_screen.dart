import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sap_app/providers/model_provider.dart';

import '../data/app_keys.dart';

class NewModelScreen extends ConsumerStatefulWidget {
  const NewModelScreen({super.key});

  @override
  ConsumerState<NewModelScreen> createState() => _NewModelScreenState();
}

class _NewModelScreenState extends ConsumerState<NewModelScreen> {
  var _enteredModel;

  var _modelController = TextEditingController();
  Map<String, List<String>> models = {};

  // final _formKey = GlobalKey<FormFieldState>();
  // final _formKey = AppKeys().formLoginKeys[3];

  // final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    ref.read(modelsProvider.notifier).loadModelList();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // _formKey.currentState!.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _removeModel(String itemName) async {
    try {
      final response = ref.read(modelsProvider.notifier).removeItem(itemName);

      setState(() {
        models = ref.watch(modelsProvider);
      });

      if (response.toString() != 'false') {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.blue,
            content: Text(
              "Serverdan model nomi o'chirildi!",
              style: TextStyle(fontSize: 16),
            ),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Model serverdan o'chirilmadi",
              style: TextStyle(fontSize: 16),
            ),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            e.toString(),
            style: TextStyle(fontSize: 16),
          ),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _saveModel() async {
    if (_modelController.text == null ||
        _modelController.text.isEmpty ||
        models.entries.first.value.any((element) =>
            element.toUpperCase() ==
            _modelController.text.trim().toUpperCase()) ||
        _modelController.text.trim().length <= 1 ||
        _modelController.text.trim().length > 200) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Model nomi 1 va 200 belgi oralig'idagi yangi nom bo'lishi kerak ",
            style: TextStyle(fontSize: 16),
          ),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      try {
        final response = ref
            .read(modelsProvider.notifier)
            .addModel(_modelController.text.trim());
        setState(() {
          models = ref.watch(modelsProvider);
        });
        if (response.toString() != 'false') {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.blue,
              content: Text(
                "Model serverga qo'yildi",
                style: TextStyle(fontSize: 16),
              ),
              duration: Duration(seconds: 1),
            ),
          );
          _modelController.text = "";
        } else {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                "Serverga qo'shilmadi!",
                style: TextStyle(fontSize: 16),
              ),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              e.toString(),
              style: TextStyle(fontSize: 16),
            ),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    models = ref.watch(modelsProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Text("Yangi model turini kiritish"),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: ListView(
          children: [
            TextField(
              maxLength: 200,
              controller: _modelController,
              decoration: const InputDecoration(
                label: Text('Model nomi'),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  _saveModel();
                },
                child: Text("yaratish")),
            // Text("data"),
            if (models.isNotEmpty)
              ...models.entries.first.value.map((e) {
                return Dismissible(

                    // confirmDismiss: (direction) {

                    //   return Future(() => false);
                    // },
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    onDismissed: (direction) {
                      _removeModel(e);
                    },
                    key: UniqueKey(),
                    child: ListTile(
                      title: Text(e),
                    ));
              }),
          ],
        ),
      ),
    );
  }
}
