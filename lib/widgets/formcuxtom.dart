import 'package:flutter/material.dart';
import '../resources/warna.dart';

class FormCustom extends StatelessWidget {
  final String text;
  final Icon? prefixicon;
  final Icon? suffixicon;
  final bool? readOnly;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  const FormCustom({
    Key? key,
    required this.text,
    this.prefixicon,
    this.suffixicon,
    this.readOnly,
    this.onTap,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: TextField(
          controller: controller,
          onTap: onTap,
          readOnly: readOnly ?? false,
          decoration: InputDecoration(
              prefixIcon: prefixicon,
              suffixIcon: suffixicon,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Warna.hijau2,
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Warna.hijau2,
                  width: 1.0,
                ),
              ),
              hintText: text,
              hintStyle:
                  const TextStyle(color: Color.fromRGBO(158, 163, 155, 0.5))),
          style: TextStyle(color: Warna.htam),
        ));
  }
}
