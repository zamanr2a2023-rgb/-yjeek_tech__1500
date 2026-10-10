import 'package:flutter/material.dart';

/// Keeps phone numbers and country codes left-to-right in Arabic (RTL) layouts.
class LtrPhoneText extends StatelessWidget {
  const LtrPhoneText(
    this.phone, {
    super.key,
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
  });

  final String phone;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text(
        phone,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}
