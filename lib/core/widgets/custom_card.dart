import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Reusable rounded card widget adhering to the minimalist M3 design system.
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppConstants.spacingMD),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
