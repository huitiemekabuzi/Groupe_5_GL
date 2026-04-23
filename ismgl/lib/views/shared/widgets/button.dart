import 'package:flutter/material.dart';
import 'package:ismgl/app/themes/app_theme.dart';

class AppButton extends StatelessWidget {
  final String    label;
  final VoidCallback? onPressed;
  final bool      isLoading;
  final IconData? icon;
  final Color?    color;
  final bool      outlined;
  final double?   width;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.color,
    this.outlined  = false,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final btnColor = color ?? AppTheme.primary;

    if (outlined) {
      return SizedBox(
        width: width ?? double.infinity,
        child: OutlinedButton.icon(
          onPressed: isLoading ? null : onPressed,
          icon:      icon != null ? Icon(icon, size: 18) : const SizedBox.shrink(),
          label:     isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: btnColor,
            side:            BorderSide(color: btnColor),
            padding:         padding ?? const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon:      icon != null && !isLoading
            ? Icon(icon, size: 18)
            : const SizedBox.shrink(),
        label: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: btnColor,
          foregroundColor: Colors.white,
          padding:         padding ?? const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}