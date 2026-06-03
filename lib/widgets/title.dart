import 'package:flutter/material.dart';

class MyTitle extends StatelessWidget {
  const MyTitle({super.key, required this.text, this.fontSize, this.color});
  final String? text;
  final double? fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(text ?? "NULL", style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: fontSize,
      color: color,
    ));
  }
}