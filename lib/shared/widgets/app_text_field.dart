import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final VoidCallback? onEditingComplete;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onEditingComplete,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscure,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onEditingComplete: widget.onEditingComplete,
      validator: widget.validator,
      autocorrect: false,
      enableSuggestions: !widget.isPassword,
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Icon(
            widget.prefixIcon,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 48),
        suffixIcon: widget.isPassword
            ? GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Icon(
                    _obscure
                        ? CupertinoIcons.eye_slash
                        : CupertinoIcons.eye,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              )
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 48),
      ),
    );
  }
}
