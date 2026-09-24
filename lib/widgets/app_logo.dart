import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double width;
  final double? height;

  const AppLogo({
    super.key,
    this.width = 180,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}