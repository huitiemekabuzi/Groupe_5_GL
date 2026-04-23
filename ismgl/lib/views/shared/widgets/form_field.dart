import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ismgl/app/themes/app_theme.dart';

class AppFormField extends StatelessWidget {
  final String          label;
  final String?         hint;
  final String?         errorText;
  final IconData?       prefixIcon;
  final Widget?         suffixWidget;
  final bool            obscureText;
  final TextInputType   keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool            enabled;
  final int             maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode?      focusNode;

  const AppFormField({
    super.key,
    required this.label,
    this.hint,
    this.errorText,
    this.prefixIcon,
    this.suffixWidget,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.maxLines = 1,
    this.inputFormatters,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller:       controller,
          obscureText:      obscureText,
          keyboardType:     keyboardType,
          validator:        validator,
          onChanged:        onChanged,
          onFieldSubmitted: onSubmitted,
          enabled:          enabled,
          maxLines:         maxLines,
          focusNode:        focusNode,
          inputFormatters:  inputFormatters,
          style: GoogleFonts.poppins(fontSize: 15),
          decoration: InputDecoration(
            hintText:    hint,
            errorText:   errorText,
            prefixIcon:  prefixIcon != null ? Icon(prefixIcon, color: AppTheme.textSecondary) : null,
            suffixIcon:  suffixWidget,
          ),
        ),
      ],
    );
  }
}

class AppDropdown<T> extends StatelessWidget {
  final String         label;
  final T?             value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  final String?        errorText;

  const AppDropdown({
    super.key,
    required this.label,
    this.value,
    required this.items,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(errorText: errorText),
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: AppTheme.textPrimary,
          ),
          dropdownColor: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
      ],
    );
  }
}