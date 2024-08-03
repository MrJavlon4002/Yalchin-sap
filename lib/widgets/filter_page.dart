import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sap_app/data/categories.dart';
import 'package:sap_app/providers/brand_provider.dart';
import 'package:sap_app/providers/model_provider.dart';
import 'package:sap_app/providers/product_provider.dart';
import 'package:sap_app/widgets/filter_category_page.dart';

class FilterPage extends ConsumerStatefulWidget {
  const FilterPage({super.key});

  @override
  ConsumerState<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends ConsumerState<FilterPage> {
  // var brands = [];
  // var models = [];
  final List<String> ModelItems = [];
  final List<String> BrandItems = [];
  @override
  void initState() {
    // TODO: implement initState
    ref.read(modelsProvider.notifier).loadModelList();
    ref.read(brandsProvider.notifier).loadBrandList();
    super.initState();
  }

  var _groupBrandValue;
  var _groupModelValue;

  List<String> _filteredCategories = [];

  void _modelItemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        ModelItems.add(itemValue);
      } else {
        ModelItems.remove(itemValue);
      }
    });
  }

  void _brandItemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        BrandItems.add(itemValue);
      } else {
        BrandItems.remove(itemValue);
      }
    });
  }

  void _filterProductList() async {
    final groceryList = ref.watch(productsProvider);

    final filteredList = await ref
        .read(productsProvider.notifier)
        .filterItems(ModelItems, BrandItems, _filteredCategories, groceryList);
    print("filteredList: " + filteredList.toString());
    Navigator.pop(context, filteredList);
  }

  void _getFilteredCategoryNames() async {
    final res = await Navigator.of(context).push<List<String>>(
        MaterialPageRoute(builder: (context) => FilterCategoryPage()));
    print("res(fitlerPage):"+res.toString());
    if (res != null) {
      setState(() {
        _filteredCategories = res;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final brands = ref.watch(brandsProvider);
    final models = ref.watch(modelsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        title: Text("Filterlang"),
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: () {
              _getFilteredCategoryNames();
            },
            leading: Icon(Icons.category),
            title: Text("Kategoriya bo'yicha -> "),
            trailing: Icon(Icons.arrow_forward),
          ),
          ExpansionTile(

            leading: Icon(Icons.copyright_outlined),
            title: Text("Brand bo'yicha -> "),
            // trailing: Icon(Icons.arrow_forward),
            children: [
              if (brands.isNotEmpty)
                ...brands.entries.first.value.map((e) => CheckboxListTile(
                      value: BrandItems.contains(e),
                      title: Text(e),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (isChecked) => _brandItemChange(e, isChecked!),
                    )),
            ],
          ),
          ExpansionTile(
            // onTap: () {
            //   Navigator.of(context).push(MaterialPageRoute(builder: (context)=>FilterCategoryPage()));
            // },
            leading: Icon(Icons.move_down_outlined),
            title: Text("Model bo'yicha -> "),
            // trailing: Icon(Icons.arrow_forward),
            children: [
              if (models.isNotEmpty)
                ...models.entries.first.value.map((e) => CheckboxListTile(
                      value: ModelItems.contains(e),
                      title: Text(e),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (isChecked) => _modelItemChange(e, isChecked!),
                    )),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                 style: ElevatedButton.styleFrom(
                  // backgroundColor: Colors.white,
                 ),
                  onPressed: () {
                    _filterProductList();
                  },
                  child: Text("Ko'rsatish", style: TextStyle(color: Colors.blue),))
            ],
          )
        ],
      ),
    );
  }
}
