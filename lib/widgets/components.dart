import 'package:flutter/material.dart';

class ShortDivider extends StatelessWidget {
  final double height;
  final double thickness;
  final Color color;
  final EdgeInsetsGeometry padding;

  const ShortDivider({
    Key? key,
    this.height = 32.0,
    this.thickness = 1.0,
    required this.color,
    this.padding = const EdgeInsets.symmetric(horizontal: 128.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Divider(height: height, thickness: thickness, color: color),
    );
  }
}

// You can add more custom components here in the future
