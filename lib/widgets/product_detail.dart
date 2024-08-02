import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sap_app/models/product_item.dart';
import 'package:readmore/readmore.dart';
import 'package:sap_app/providers/product_provider.dart';
import 'package:sap_app/widgets/edit_item_screen.dart';
import 'package:sap_app/widgets/grocery_item_card.dart';
import 'package:sap_app/widgets/grocery_list.dart';
import 'package:sap_app/widgets/relative_item_card.dart';
import 'package:sap_app/widgets/single_category_view.dart';

import '../providers/category_provider.dart';
import 'auth.dart';
// import 'package:fluttercookie/bottom_bar.dart';

class ProductDetail extends ConsumerStatefulWidget {
  // const ProductDetail({super.key});
  ProductItem productItem;
  ProductDetail({required this.productItem});

  @override
  ConsumerState<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends ConsumerState<ProductDetail> {
  List<ProductItem> _relativeList = [];
  // widget.productItem =
  var _isEdited = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    createRelativeList();
    ref.read(categoriesProvider.notifier).loadAllCategories();
    _isEdited = false;
  }

  void createRelativeList() async {
    _relativeList = await ref
        .read(productsProvider.notifier)
        .filterItems([], [], [widget.productItem.category], []);
    print(_relativeList);
  }

  void _getEditedItem() async {
    ProductItem? item =
        await Navigator.of(context).push<ProductItem>(MaterialPageRoute(
            builder: (context) => EditItemScreen(
                  productItem: widget.productItem,
                )));

    if (item != null) {
      print("product_detail: " + item.toString());
      setState(() {
        widget.productItem = item;
        _isEdited = true;
      });
    }
  }

  void _removeItem() async {
    try {
      await ref.read(productsProvider.notifier).removeItem(widget.productItem);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => GroceryList()));
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Mahsulotni serverdan o'chirishda xatolik!: ${e.toString()}",
        ),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        // backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: Color.fromARGB(255, 255, 255, 255)),
          onPressed: () {
            Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (context) {
              return GroceryList();
            }));
          },
        ),
        title: Text('Batafsil ma\'lumot',
            style: TextStyle(
                fontFamily: 'Varela', fontSize: 20.0, color: Colors.white)),
        actions: <Widget>[
          (Auth.logedInUser!.isAdmin)
              ? IconButton(
                  icon: Icon(Icons.edit_outlined,
                      color: Color.fromARGB(255, 255, 255, 255)),
                  onPressed: () {
                    _getEditedItem();
                  },
                )
              : Container(),
          (Auth.logedInUser!.isAdmin)
              ? IconButton(
                  icon: Icon(Icons.delete,
                      color: Color.fromARGB(255, 255, 255, 255)),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Mahsulotni o'chirish"),
                            content: const Text(
                                "Mahsulotni haqiqatdan ham o'chirmoqchimisiz?"),
                            actionsAlignment: MainAxisAlignment.spaceBetween,
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  // color: Colors.green,
                                  padding: const EdgeInsets.all(14),
                                  child: const Text("Yo'q"),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  _removeItem();
                                  // Navigator.of(ctx).pop();
                                },
                                child: Container(
                                  // color: Colors.green,
                                  padding: const EdgeInsets.all(14),
                                  child: const Text("Ha"),
                                ),
                              ),
                            ],
                          );
                        });
                    // )
                  },
                )
              : Container(),
        ],
      ),

      body: ListView(padding: EdgeInsets.symmetric(horizontal: 25), children: [
        SizedBox(height: 15.0),
        // Text(
        //       widget.product.name.substring(
        //               0,
        //               widget.product.name.length > 10
        //                   ? 10
        //                   : widget.product.name.length) +
        //           "...",
        //       style: TextStyle(
        //           fontFamily: 'Varela',
        //           fontSize: 26.0,
        //           fontWeight: FontWeight.bold,
        //           color: Color(0xFFF17532))),
        // SizedBox(height: 15.0),
        // Expanded(
        // child:
        Column(
          children: [
            widget.productItem.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: widget.productItem.imageUrl,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    imageBuilder: (context, imageProvider) {
                      return Container(
                        height: 250,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(30)),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    })
                : Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Color.fromARGB(255, 102, 160, 126),
                      // border: Border(bottom: BorderSide(width: 2, color: Colors.grey))
                    ),
                    alignment: Alignment.center,
                    child: Text("Rasm yuklanmagan"),
                  ),
          ],
        ),
        // ),
        // SizedBox(height: 20.0),

        SizedBox(height: 20.0),
        Text(widget.productItem.name,
            textAlign: TextAlign.left,
            style: TextStyle(
                color: Color(0xFF575E67),
                fontFamily: 'Varela',
                fontSize: 24.0)),
        SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                "Narxi: ${widget.productItem.price} ${widget.productItem.currency}",
                style: TextStyle(
                    fontFamily: 'Varela',
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo)),
            // Text("${widget.productItem.boxCount} ta karobka",
            //     style: TextStyle(
            //         fontFamily: 'Varela',
            //         fontSize: 22.0,
            //         fontWeight: FontWeight.bold,
            //         color: Colors.indigo)),
          ],
        ),
        SizedBox(height: 20.0),
        Text(
          "Mahsulot haqida ta'rif:",
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 20.0),

        Center(
          child: Container(
            width: MediaQuery.of(context).size.width - 50.0,
            child: widget.productItem.description!.isNotEmpty
                ? ReadMoreText(
                    widget.productItem.description![0].toUpperCase() +
                        widget.productItem.description!.substring(1),
                    colorClickableText: Colors.pink,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: 'Batafsil',
                    trimExpandedText: 'Qisqartirish',
                    moreStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                        backgroundColor: Color.fromARGB(255, 170, 170, 170)),
                    lessStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo),
                  )
                : Text("Kiritilmagan"),
          ),
        ),

        SizedBox(height: 20.0),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [

        //   ],
        // ),
        Text(
          "Brand: " + widget.productItem.brand,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 10.0),
        Text(
          "Model: " + widget.productItem.model,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 10.0),
        Row(
          children: [
            Text(
              "Color: ",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(width: 10.0),
            ClipOval(
              child: Container(
                width: 20,
                height: 20,
                color: widget.productItem.color,
              ),
            )
          ],
        ),

        SizedBox(height: 20.0),
        Text(
          "Kategoriyalari: ",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20.0),

        Text(widget.productItem.factionList!
            .map((e) => e[0].toUpperCase() + e.substring(1).toLowerCase())
            .toList()
            .join(", ")),

        // Row(

        //   children: [
        //                 if (_relativeList.isNotEmpty)
        //       ..._relativeList.map((e) => Container(
        //             child: Text(e.name),
        //           )),
        //   ],
        // )
        // SingleChildScrollView(
        //   scrollDirection: Axis.horizontal,
        //   child: Row(
        //     children: [
        //       if (_relativeList.isNotEmpty)
        //         ..._relativeList.map((e) => RelativeItemCard(productItem: e)),
        //       // Text("data"),
        //     ],
        //   ),
        // ),

        // Flex(
        //   direction: Axis.horizontal,
        //   // clipBehavior: Clip.antiAlias,
        //   children: [

        //   ],
        // )
      ]),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   backgroundColor: Color(0xFFF17532),
      //   child: Icon(Icons.fastfood),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // bottomNavigationBar: BottomBar(),
    );
  }
}
