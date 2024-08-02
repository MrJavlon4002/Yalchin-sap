import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class FilterModelPage extends StatefulWidget {
  const FilterModelPage({super.key});

  @override
  State<FilterModelPage> createState() => _FilterModelPageState();
}

class _FilterModelPageState extends State<FilterModelPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Text("Model tanlang"),
        
      ),
    );
  }
}