import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class SimpleTextField extends StatefulWidget {
  const SimpleTextField({
    Key? key,
    this.formate,
    this.read,
    this.hint,
    this.label,
    this.error = "Required Field",
    this.validator,
    this.prefixIcon,
    this.focus,
    this.valid,
    this.keyboardType,
    this.floatLabel = false,
    this.textEditingController,
    this.function,
    this.optional = false,
    this.suffixIcon = false,

    /// TODO: Remove this.
    BuildContext? context,
    this.onTap,
  }) : super(key: key);
  final read;
  final formate;
  final String? hint;
  final String? label;
  final String? error;
  final IconData? prefixIcon;
  final bool floatLabel;
  final bool? suffixIcon;
  final VoidCallback? onTap;
  final Function? function;
  final FocusNode? focus;
  final String? valid;
  final bool? optional;
  final TextInputType? keyboardType;
  final FormFieldValidator<String?>? validator;
  final TextEditingController? textEditingController;

  @override
  State<SimpleTextField> createState() => _SimpleTextFieldState();
}

class _SimpleTextFieldState extends State<SimpleTextField> {
  final focusNode = FocusNode();
  @override
  void initState() {
    if (widget.optional == false) {
      focusNode.addListener(() async {
        if (!focusNode.hasFocus) {}
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 48,
          child: TextFormField(
            onTap: widget.onTap,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            inputFormatters: widget.formate,
            // obscureText: obscure,
            controller: widget.textEditingController,
            focusNode: focusNode,
            onChanged: (val) {},

            autovalidateMode: AutovalidateMode.onUserInteraction,
            scrollPadding: const EdgeInsets.all(100),
            readOnly: widget.read,
            style: TextStyle(
                color: Colors.black,
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                fontFamily: "InterRegular"),
            decoration: InputDecoration(
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(15),
              border: InputBorder.none,
              hintText: widget.hint,

              hintStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: "InterSemiBold"),
              labelStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
              floatingLabelBehavior: widget.floatLabel
                  ? FloatingLabelBehavior.always
                  : FloatingLabelBehavior.auto,
              labelText: widget.label,

              suffixIcon: widget.suffixIcon == true
                  ? Icon(Icons.arrow_drop_down_rounded)
                  : SizedBox(),
              // suffixIcon: suffix,
            ),

            cursorColor: Colors.grey,
          ),
        ),
      ],
    );
  }
}
