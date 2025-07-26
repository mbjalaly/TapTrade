import 'package:flutter/material.dart';

import 'package:pin_code_text_field/pin_code_text_field.dart';


class CustomPinCodeInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onDone;
  final Function(String) onTextChanged;

  CustomPinCodeInput({
    required this.controller,
    required this.onDone,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    Size appSize = MediaQuery.of(context).size;

    return Center(
      child: Container(
        child: Align(
          alignment: Alignment.center,
          child: PinCodeTextField(
              pinBoxColor: Colors.transparent,
              autofocus: true,
              pinTextStyle: TextStyle(
                  fontSize: appSize.width * 0.05,
                  color: Colors.black,fontWeight: FontWeight.w700),
              pinBoxBorderWidth: 1.2,
              pinBoxRadius: 4,
              highlight: true,
              pinBoxOuterPadding: const EdgeInsets.symmetric(horizontal: 10.0),
              controller: controller,
              maxLength: 4,
              // focusNode: _focusNode,
              pinBoxWidth: appSize.width * 0.13,
              highlightColor: Colors.black,
              // pinBoxColor: Colors.grey,
              defaultBorderColor: Colors.black,
              pinBoxHeight: appSize.height / 15,
              hasTextBorderColor: Colors.black,
              onDone: onDone,
              onTextChanged: onTextChanged),
        ),
      ),
    );
  }
}
