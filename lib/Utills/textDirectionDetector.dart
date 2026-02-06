import 'package:flutter/material.dart';

/// Utility class to detect text direction based on content
class TextDirectionDetector {
  /// Detects if the text contains RTL characters (Arabic, Hebrew, etc.)
  static bool isRTL(String text) {
    if (text.isEmpty) return false;

    // Get the first character that's not whitespace or punctuation
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    final firstChar = trimmed.codeUnitAt(0);

    // Arabic Unicode ranges
    // Arabic: U+0600 to U+06FF
    // Arabic Supplement: U+0750 to U+077F
    // Arabic Extended-A: U+08A0 to U+08FF
    // Arabic Presentation Forms-A: U+FB50 to U+FDFF
    // Arabic Presentation Forms-B: U+FE70 to U+FEFF
    if ((firstChar >= 0x0600 && firstChar <= 0x06FF) ||
        (firstChar >= 0x0750 && firstChar <= 0x077F) ||
        (firstChar >= 0x08A0 && firstChar <= 0x08FF) ||
        (firstChar >= 0xFB50 && firstChar <= 0xFDFF) ||
        (firstChar >= 0xFE70 && firstChar <= 0xFEFF)) {
      return true;
    }

    // Hebrew: U+0590 to U+05FF
    if (firstChar >= 0x0590 && firstChar <= 0x05FF) {
      return true;
    }

    return false;
  }

  /// Gets the text direction based on content
  static TextDirection getTextDirection(String text) {
    return isRTL(text) ? TextDirection.rtl : TextDirection.ltr;
  }
}

/// A TextField that automatically adjusts its text direction based on content
class AutoDirectionTextField extends StatefulWidget {
  final TextEditingController? controller;
  final InputDecoration? decoration;
  final TextStyle? style;
  final int? maxLines;
  final int? minLines;
  final bool? enabled;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool autocorrect;
  final bool enableSuggestions;
  final FocusNode? focusNode;
  final String? initialValue;

  const AutoDirectionTextField({
    Key? key,
    this.controller,
    this.decoration,
    this.style,
    this.maxLines = 1,
    this.minLines,
    this.enabled,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.focusNode,
    this.initialValue,
  }) : super(key: key);

  @override
  State<AutoDirectionTextField> createState() => _AutoDirectionTextFieldState();
}

class _AutoDirectionTextFieldState extends State<AutoDirectionTextField> {
  late TextEditingController _controller;
  TextDirection _textDirection = TextDirection.ltr;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _updateTextDirection(_controller.text);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    _updateTextDirection(_controller.text);
  }

  void _updateTextDirection(String text) {
    final newDirection = TextDirectionDetector.getTextDirection(text);
    if (newDirection != _textDirection) {
      setState(() {
        _textDirection = newDirection;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _textDirection,
      child: TextField(
        controller: _controller,
        decoration: widget.decoration,
        style: widget.style,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        enabled: widget.enabled,
        onChanged: widget.onChanged,
        onEditingComplete: widget.onEditingComplete,
        onSubmitted: widget.onSubmitted,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        obscureText: widget.obscureText,
        autocorrect: widget.autocorrect,
        enableSuggestions: widget.enableSuggestions,
        focusNode: widget.focusNode,
        textDirection: _textDirection,
      ),
    );
  }
}

/// A TextFormField that automatically adjusts its text direction based on content
class AutoDirectionTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final InputDecoration? decoration;
  final TextStyle? style;
  final int? maxLines;
  final int? minLines;
  final bool? enabled;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool autocorrect;
  final bool enableSuggestions;
  final FocusNode? focusNode;
  final String? initialValue;
  final AutovalidateMode? autovalidateMode;

  const AutoDirectionTextFormField({
    Key? key,
    this.controller,
    this.decoration,
    this.style,
    this.maxLines = 1,
    this.minLines,
    this.enabled,
    this.onChanged,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.validator,
    this.onSaved,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.focusNode,
    this.initialValue,
    this.autovalidateMode,
  }) : super(key: key);

  @override
  State<AutoDirectionTextFormField> createState() => _AutoDirectionTextFormFieldState();
}

class _AutoDirectionTextFormFieldState extends State<AutoDirectionTextFormField> {
  late TextEditingController _controller;
  TextDirection _textDirection = TextDirection.ltr;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _updateTextDirection(_controller.text);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    _updateTextDirection(_controller.text);
  }

  void _updateTextDirection(String text) {
    final newDirection = TextDirectionDetector.getTextDirection(text);
    if (newDirection != _textDirection) {
      setState(() {
        _textDirection = newDirection;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _textDirection,
      child: TextFormField(
        controller: _controller,
        decoration: widget.decoration,
        style: widget.style,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        enabled: widget.enabled,
        onChanged: widget.onChanged,
        onEditingComplete: widget.onEditingComplete,
        onFieldSubmitted: widget.onFieldSubmitted,
        validator: widget.validator,
        onSaved: widget.onSaved,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        obscureText: widget.obscureText,
        autocorrect: widget.autocorrect,
        enableSuggestions: widget.enableSuggestions,
        focusNode: widget.focusNode,
        autovalidateMode: widget.autovalidateMode,
        textDirection: _textDirection,
      ),
    );
  }
}
