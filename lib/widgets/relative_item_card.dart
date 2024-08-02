import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sap_app/models/product_item.dart';

import 'grocery_item_card.dart';

class RelativeItemCard extends StatefulWidget {
  RelativeItemCard({super.key, required this.productItem});
  ProductItem productItem;

  @override
  State<RelativeItemCard> createState() => _RelativeItemCardState();
}

class _RelativeItemCardState extends State<RelativeItemCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          color: Colors.amber,
          // height: 100,
          child: Column(
            children: [
              Container(
                height: 100,
                child: widget.productItem.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: widget.productItem.imageUrl,
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
              SizedBox(height: 10,),
              Text(widget.productItem.name),
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Flex(
              //         direction: Axis.vertical,
              //         // mainAxisAlignment: MainAxisAlignment.start,
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Text(
              //             textAlign: TextAlign.left,
              //             widget.productItem.name,
              //             style: GoogleFonts.inter(
              //               fontSize: 14,
              //               fontWeight: FontWeight.bold,
              //             ),
              //             maxLines: 1,
              //             overflow: TextOverflow.ellipsis,
              //           ),
              //           SizedBox(
              //             height: 10,
              //           ),
              //           Text(
              //             "Soni: ${widget.productItem.quantity} ta",
              //             style: TextStyle(
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),
              //           SizedBox(
              //             height: 5,
              //           ),
              //           Text(
              //             "Brand: ${widget.productItem.brand}",
              //             maxLines: 1,
              //             overflow: TextOverflow.ellipsis,
              //           ),
              //           SizedBox(
              //             height: 5,
              //           ),
              //           Text(
              //             "Model: ${widget.productItem.model}",
              //             maxLines: 1,
              //             overflow: TextOverflow.ellipsis,
              //           ),
              //           SizedBox(
              //             height: 5,
              //           ),
              //         ],
              //       ),

              //       Expanded(child: Text("")),
              //       Flex(
              //         direction: Axis.vertical,
              //         // mainAxisSize: MainAxisSize.min,
              //         crossAxisAlignment: CrossAxisAlignment.end,

              //         mainAxisAlignment: MainAxisAlignment.end,
              //         children: [
              //           Row(
              //             // mainAxisAlignment: MainAxisAlignment.end,
              //             children: [
              //               Text(
              //                 "${oCcy.format((widget.productItem.price))} ${widget.productItem.currency}",
              //                 maxLines: 1,
              //                 overflow: TextOverflow.ellipsis,
              //                 style: TextStyle(
              //                   fontSize: 16,
              //                   fontWeight: FontWeight.w500,
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ],
              //       ),

                    // ListTile(
                    //   title: Text("Batafsil.."),
                    //   leading: Icon(Icons.read_more_outlined),
                    // ),
          //         ],
          //       ),
          //     ),
            ],
          ),
          ),
    );
  }
}
