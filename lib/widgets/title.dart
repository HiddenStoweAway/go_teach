import 'package:flutter/material.dart';

class MyTitle extends StatelessWidget {
  const MyTitle({super.key, required this.text, this.fontSize});
  final String text;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: fontSize
    ));
  }
}