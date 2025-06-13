// ignore_for_file: use_super_parameters, avoid_init_to_null, file_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/appcolors.dart';


class CustomText extends StatelessWidget {
  final String text;
  final Color? textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final bool strikeText;
  final bool textAlign;
  final bool textFontRokkitt;
  final bool textUnderLined;
  final int? maxLines;
  final TextOverflow? textOverflow;

  const CustomText({
    Key? key,
    required this.text,
    this.strikeText = false,
    this.maxLines = null,
    this.textOverflow,
    this.textFontRokkitt = false,
    this.textAlign = false,
    this.textUnderLined = false,
    this.textColor = blackColor,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w400,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.openSans(
        textStyle: TextStyle(
          decoration: strikeText ? TextDecoration.lineThrough : null,
          // decorationColor: greenGradient1,
          overflow: textOverflow,
        ),
        color: textColor,
        decoration: textUnderLined ? TextDecoration.underline : null,
        decorationColor: Colors.grey,
        decorationThickness: 2,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      maxLines: maxLines,
      textAlign: textAlign ? TextAlign.center : null,
    );
  }
}
