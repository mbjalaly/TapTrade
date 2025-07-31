import 'package:flutter/material.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/soundManager.dart';

class AppButton extends StatefulWidget {
  final String? text;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final double? fontSize;
  final Color? textColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool? isLoading;
  final EdgeInsetsGeometry? margin;

  const AppButton({
    Key? key,
    this.text,
    this.onPressed,
    required this.width,
    this.height,
    this.fontSize,
    this.textColor,
    this.backgroundColor,
    this.borderColor,
    this.isLoading,
    this.margin,
  }) : super(key: key);

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  @override
  Widget build(BuildContext context) {
    var Size = MediaQuery.of(context).size;
    bool isDisabled = widget.onPressed == null || (widget.isLoading ?? false);
    
    return GestureDetector(
      onTap: isDisabled ? null : () {
        SoundManager().play("anyButton");
        print("=========================");
        widget.onPressed!();
      },
      child: Container(
        height: widget.height ?? Size.height * 0.067,
        width: widget.width ?? Size.width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: isDisabled ? Colors.grey.withValues(alpha: 0.3) : widget.backgroundColor,
          border: widget.borderColor != null ? Border.all(color: widget.borderColor!, width: 2) : null,
          gradient: (widget.backgroundColor != null || isDisabled) ? null : const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFF00E3DF), // Start color
              Color(0xFFF2B721), // End color
            ],
            stops: [0.0, 1.0], // Gradient stops
          ),
        ),
        margin: widget.margin,
        child: (widget.isLoading ?? false) ? const CircularProgressIndicator(color: AppColors.primaryTextColor,) : Text(
          widget.text ?? "",
          style: TextStyle(
              color: isDisabled ? Colors.grey : (widget.textColor ?? Colors.white),
              fontSize: Size.width > 500
                  ? Size.width * 0.03
                  : widget.fontSize ?? Size.width * 0.036,
          fontWeight: FontWeight.w500
          ),
        ),
      ),
    );
  }
}