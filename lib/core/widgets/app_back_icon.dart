import 'package:flutter/material.dart';

/// Back affordance that mirrors correctly in RTL (Arabic).
class AppBackIcon extends StatelessWidget {
  const AppBackIcon({
    super.key,
    this.color,
    this.size = 18,
  });

  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.arrow_back_ios_new_rounded,
      size: size,
      color: color,
    );
  }
}
