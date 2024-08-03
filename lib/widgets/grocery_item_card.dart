import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sap_app/models/product_item.dart';
import 'package:sap_app/widgets/product_detail.dart';

import 'package:intl/intl.dart';

final oCcy = NumberFormat("#,##0", "uz_UZ");

class GroceryItemCard extends StatefulWidget {
  GroceryItemCard({super.key, required this.product_item});

  ProductItem product_item;

  @override
  State<GroceryItemCard> createState() => _GroceryItemCardState();
}

class _GroceryItemCardState extends State<GroceryItemCard> {
  void _goBack() async {
    ProductItem? res = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ProductDetail(
              productItem: widget.product_item,
            )));
    if (res != null) {


      setState(() {
        widget.product_item = res;

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _goBack();
      },
      child: Container(
        
        // padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
          boxShadow: [BoxShadow(color: Color.fromARGB(255, 107, 107, 107), offset: Offset(0, 3), blurRadius: 7),],

          // border: Border.all(color: Colors.grey, ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,

          // direction: Axis.vertical,
          children: [
            Container(
              height: 170,
              child: widget.product_item.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: widget.product_item.imageUrl,
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator()),
                      imageBuilder: (context, imageProvider) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Color.fromARGB(255, 102, 160, 126),
                        // border: Border(bottom: BorderSide(width: 2, color: Colors.grey))
                      ),
                      alignment: Alignment.center,
                      child: Text("Rasm yuklanmagan"),
                    ),
            ),

            SizedBox(
              height: 10,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flex(
                      direction: Axis.vertical,
                      // mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          textAlign: TextAlign.left,
                          widget.product_item.name,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Soni: ${widget.product_item.quantity} ta",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Brand: ${widget.product_item.brand}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Model: ${widget.product_item.model}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                      ],
                    ),

                    Expanded(child: Text("")),
                    Flex(
                      direction: Axis.vertical,
                      // mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,

                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "${oCcy.format((widget.product_item.price))} ${widget.product_item.currency}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // ListTile(
                    //   title: Text("Batafsil.."),
                    //   leading: Icon(Icons.read_more_outlined),
                    // ),
                  ],
                ),
              ),
            ),

            // Text("data"),
            // Text("data"),
            // Text("data"),
          ],
        ),
      ),
    );
  }
}
