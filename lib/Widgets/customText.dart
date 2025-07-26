import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  String text;
  Color? textcolor;
  double? fontSize;
  FontWeight? fontWeight;
  TextAlign? textAlign;
  TextDecoration? decoration;
  int? maxLines;

  AppText({
    Key? key,
    required this.text,
    this.textcolor,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
    this.decoration,
    this.maxLines = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      style: TextStyle(
          color: textcolor ?? Colors.white,
          fontSize: fontSize,
          fontWeight: fontWeight,
          overflow: TextOverflow.ellipsis,
          decoration: decoration),
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      textAlign: textAlign ?? TextAlign.start,
    );
  }
}
