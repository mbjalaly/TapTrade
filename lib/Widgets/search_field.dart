import 'package:flutter/material.dart';
import 'package:get/get.dart';


class TextFieldWithClearIcon extends StatefulWidget {
  String? hintText;
  TextFieldWithClearIcon(
      {Key? key,

        this.hintText,

      })
      : super(key: key);
  @override
  _TextFieldWithClearIconState createState() => _TextFieldWithClearIconState();
}

class _TextFieldWithClearIconState extends State<TextFieldWithClearIcon> {
  TextEditingController _controller = TextEditingController();
  ValueNotifier<bool> _isTextNotEmpty = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    _isTextNotEmpty.value = _controller.text.isNotEmpty;
  }

  void _clearText() {
    _controller.clear();
    _onTextChanged(); // Update _isTextNotEmpty value after clearing text
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height*0.063,
      width: Get.width,
      child: TextField(
        controller: _controller,
        style:  TextStyle(
          color:Colors.black,
        ),
        cursorColor: Colors.grey,
        textInputAction: TextInputAction.search,

        decoration: InputDecoration(
fillColor: Color(0xffEFF3F4),
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffEFF3F4), width: 1.5),
            borderRadius: BorderRadius.circular(7.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffEFF3F4), width: 1.5),
            borderRadius: BorderRadius.circular(7.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffEFF3F4), width: 1.5),
            borderRadius: BorderRadius.circular(7.0),
          ),
          hintText: widget.hintText ?? "Search",

          suffixIcon: ValueListenableBuilder<bool>(
            valueListenable: _isTextNotEmpty,
            builder: (context, value, child) {
              return Wrap(
                alignment: WrapAlignment.end,
                children: [
                  if (value)
                    IconButton(
                      icon: Icon(Icons.clear,color: Color(0xffEFF3F4),),
                      onPressed: _clearText,
                    ),
                ],
              );
            },
          ),
          prefixIcon: Icon(Icons.search,color: Colors.black,size: 23,)

        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _isTextNotEmpty.dispose();
    super.dispose();
  }
}