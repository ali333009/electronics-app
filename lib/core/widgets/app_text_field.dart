import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final bool isPassword;
  final bool isPhone;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final int? maxLines;
  final int? minLines;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextDirection? textDirection;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.isPassword = false,
    this.isPhone = false,
    this.keyboardType,
    this.prefixIcon,
    this.maxLines,
    this.minLines,
    this.textInputAction,
    this.validator,
    this.inputFormatters,
    this.textDirection,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscured : false,
      keyboardType: widget.isPhone ? TextInputType.phone : widget.keyboardType,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      minLines: widget.isPassword ? 1 : widget.minLines,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      inputFormatters: widget.inputFormatters,
      textDirection:
          widget.textDirection ??
          (widget.keyboardType == TextInputType.emailAddress
              ? TextDirection.ltr
              : Directionality.of(context)),
      style: AppTypography.bodyLarge,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.errorText,
        labelStyle: AppTypography.bodyMedium,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: AppColors.textMuted)
            : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscured ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textMuted,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
      ),
    );
  }
}
