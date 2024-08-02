import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class SingleCategoryView extends StatefulWidget {
  const SingleCategoryView({super.key});

  @override
  State<SingleCategoryView> createState() => _SingleCategoryViewState();
}

class _SingleCategoryViewState extends State<SingleCategoryView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      
      height: 70,
      // width: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        
        children: [
          Text("data"),
          Text("data"),
          Text("data"),
          Text("data"),
          Text("data"),
          Text("data"),
          Text("data"),
          Text("data"),
          Text("data"),
          Text("data"),
          Text("data"),
          Text("data"),
          Text("data"),
          Text("data"),
          Text("data"),
          Text("data"),
          Text("data"),
          Text("data"),
        ],
      ),
    );
  }
}
