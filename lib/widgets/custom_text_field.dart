import 'package:flutter/material.dart';

Widget customTextField({
  TextEditingController? textEditController,
  String? hintText,
}) {
  return TextField(
    controller: textEditController,
    cursorColor: Colors.black,
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        fontSize: 16,
        color: Colors.grey.withOpacity(0.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(5.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
        borderSide: const BorderSide(
          color: Colors.grey,
        ),
      ),
    ),
    style: const TextStyle(
      fontSize: 16,
      color: Colors.black,
      fontWeight: FontWeight.w500,
    ),
  );
}
