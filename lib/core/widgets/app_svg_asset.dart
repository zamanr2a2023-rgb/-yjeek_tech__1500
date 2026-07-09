import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yjeek_app/core/utils/responsive.dart';

class AppSvgAsset extends StatelessWidget {
  const AppSvgAsset({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.color,
  });

  final String assetPath;
  final double? width;
  final double? height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: width ?? 24.w,
      height: height ?? 24.w,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}
