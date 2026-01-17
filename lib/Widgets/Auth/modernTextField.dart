import 'package:flutter/material.dart';
import 'package:taptrade/Utills/appColors.dart';

/// Modern text field with floating label animation and validation states
/// Features:
/// - Animated floating label
/// - Validation state colors (green/red border)
/// - Helper text below field
/// - Clean minimal design
/// - Optional suffix widget (for visibility toggle, validation icons)
class ModernTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final bool obscureText;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final bool enabled;
  final bool showValidation; // Show validation colors
  final bool isValid; // Validation state
  final int? maxLines;
  final TextInputAction? textInputAction;

  const ModernTextField({
    Key? key,
    required this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.obscureText = false,
    required this.controller,
    this.onChanged,
    this.validator,
    this.suffix,
    this.keyboardType,
    this.enabled = true,
    this.showValidation = false,
    this.isValid = false,
    this.maxLines = 1,
    this.textInputAction,
  }) : super(key: key);

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    // Determine border color based on state
    Color borderColor = AppColors.greyTextColor.withOpacity(0.3);
    if (!widget.enabled) {
      borderColor = AppColors.greyTextColor.withOpacity(0.1);
    } else if (widget.errorText != null) {
      borderColor = Colors.red;
    } else if (widget.showValidation && widget.isValid) {
      borderColor = AppColors.successColor ?? Colors.green;
    } else if (_isFocused) {
      borderColor = AppColors.primaryColor;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _isFocused = hasFocus;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: widget.enabled ? Colors.white : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor,
                width: widget.showValidation || _isFocused ? 2 : 1.5,
              ),
            ),
            child: TextField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              enabled: widget.enabled,
              maxLines: widget.maxLines,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: widget.enabled ? AppColors.primaryTextColor : AppColors.greyTextColor,
                height: 1.5,
              ),
              decoration: InputDecoration(
                labelText: widget.label,
                labelStyle: TextStyle(
                  fontSize: _isFocused || widget.controller.text.isNotEmpty ? 14 : 16,
                  color: widget.errorText != null
                      ? Colors.red
                      : _isFocused
                          ? AppColors.primaryColor
                          : AppColors.greyTextColor,
                  fontWeight: FontWeight.w500,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: AppColors.hintTextColor ?? AppColors.greyTextColor.withOpacity(0.5),
                ),
                suffixIcon: widget.suffix,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
              ),
              onChanged: widget.onChanged,
            ),
          ),
        ),

        // Helper text or error text
        if (widget.errorText != null || widget.helperText != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 6),
            child: Text(
              widget.errorText ?? widget.helperText ?? '',
              style: TextStyle(
                fontSize: 13,
                color: widget.errorText != null
                    ? Colors.red
                    : AppColors.secondaryTextColor ?? AppColors.greyTextColor,
                height: 1.3,
              ),
            ),
          ),
      ],
    );
  }
}
