import 'package:flutter/material.dart';
import '../theme/app_dimensions.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final BoxBorder? border;
  final Color? color;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.border,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        side: border is Border ? (border as Border).top : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppDimensions.m),
          child: child,
        ),
      ),
    );
  }
}
