import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  const MyTextField({super.key, required this.controller, this.hintText, this.hideText = false});

  final TextEditingController controller;
  final String? hintText;
  final bool hideText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: hideText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontStyle: FontStyle.italic
        )
      ),
    );
  }
}