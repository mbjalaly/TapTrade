import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/Models/ProductModel/productModel.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Services/IntegrationServices/generalService.dart';
import 'package:taptrade/Services/IntegrationServices/productService.dart';
import 'package:taptrade/Services/IntegrationServices/profileService.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/Widgets/customButtom.dart';
import 'package:taptrade/Widgets/customText.dart';
import 'package:taptrade/dummy.dart';
import 'myProduct.dart';

class AddProductScreen extends StatefulWidget {
  AddProductScreen({Key?key, this.isDirect = false}) : super(key: key);
  bool isDirect;
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  var userController = Get.find<UserController>();
  bool isLoading = false;
  String selectedItem = 'Watch';
  final List<String> items = ['Watch', 'Shoes', 'Tyre'];
  List<ProductModel> productList = [];
  ProductModel selectProduct = ProductModel();
  File? _imageFile;
  TextEditingController productTitle = TextEditingController();
  TextEditingController minPrice = TextEditingController(text: '0');
  TextEditingController maxPrice = TextEditingController(text: '500');
  String? selectedCategory;
  RangeValues _currentRangeValues = const RangeValues(0, 500);
  Future<void> _showImagePickerOptions() async {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_album),
                title: Text('Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _adjustRange(double adjustment) {
    setState(() {
      double start = _currentRangeValues.start + adjustment;
      double end = _currentRangeValues.end + adjustment;
      if (start >= 0 && end <= 1000) {
        _currentRangeValues = RangeValues(start, end);
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        // _imageFile = File(pickedFile.path);
      });
    }
    XFile changeFile = XFile(pickedFile!.path);
    // _imageFile = await resizeAndCropImage(changeFile,300, 400);
    _imageFile = await resizeImage(changeFile,300, 400);
    setState(() {

    });
  }

  void clearFields() {
    selectProduct = ProductModel();
    _imageFile = null;
    productTitle.clear();
    minPrice.text = '0';
    maxPrice.text = '500';
    selectedCategory = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<String> category = GeneralService.instance.allCategory.value.data
            ?.map((e) => e.name) // Assuming e.name can be null
            .whereType<String>() // Filter out null values
            .toList() ??
        [];
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        color: AppColors.secondaryColor.withOpacity(0.1),
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.225),
        child: AppButton(
          onPressed: () async {
            String? message;
            if (productList.length < 3) {
              if (_imageFile == null) {
                message = "Please Add Product Image";
              } else if (selectedCategory == null) {
                message = "Please Select Product Category";
              } else if (productTitle.text.trim().isEmpty) {
                message = "Please Add Product Description";
              } else if (minPrice.text.trim().isEmpty) {
                message = "Please Add Product Minimum Price";
              } else if (maxPrice.text.trim().isEmpty) {
                message = "Please Add Product Maximum Price";
              }
            }

            if (message != null) {
              ShowMessage.notify(context, message);
            } else {
              if (productList.length >= 3 && widget.isDirect == false) {
                Get.to(() => MyProductScreen(
                      productList: productList,
                    ));
              } else {
                String id = userController.userProfile.value.data?.id ?? '';
                Map<String, dynamic> body = {
                  "category": selectedCategory,
                  "title": productTitle.text,
                  "min_price": double.parse(minPrice.text),
                  "max_price": double.parse(maxPrice.text),
                  "image": _imageFile,
                  "product_condition": "New",
                };
                setState(() {
                  isLoading = true;
                });
                final result = await ProductService.instance
                    .addSingleProduct(context, body, id);
                setState(() {
                  isLoading = false;
                });
                if (result.status == Status.COMPLETED) {
                  if(widget.isDirect == false){
                    selectProduct = ProductModel.fromJson(result.responseData);
                    if (selectProduct.hasNonEmptyFields()) {
                      productList.add(selectProduct);
                      setState(() {});
                      ShowMessage.notify(
                          context, 'Product Added ${productList.length}/3');
                      clearFields();
                    } else {
                      ShowMessage.notify(context,
                          'Please Add At Least Three Product ${productList.length}/3');
                    }
                  }else{
                    ShowMessage.notify(context, 'Product Added Successfully');
                    Navigator.pop(context);
                  }
                } else {
                  ShowMessage.notify(
                      context, result.responseData['message'].toString());
                }
              }
            }
          },
          isLoading: isLoading,
          width: Get.width * 0.55,
          text: widget.isDirect ? "+ Add" : productList.length >= 3 ? "Save" : "+ Add",
          textColor: Colors.white,
          fontSize: Get.width * 0.04,
        ),
      ),
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor.withOpacity(0.1),
              AppColors.secondaryColor.withOpacity(0.1)
            ], // Define your gradient colors
            begin: Alignment.topLeft, // Starting point of the gradient
            end: Alignment.bottomRight, // Ending point of the gradient
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: Get.height * 0.02,
                ),
                Container(
                  height: 4,
                  width: Get.width,
                  color: Colors.grey.withOpacity(.40),
                  child: Row(
                    children: [
                      Container(
                        height: 4,
                        width: Get.width,
                        color: AppColors.themeColor,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: Get.height * 0.02,
                ),
                Center(
                  child: AppText(
                    text: "Add Products",
                    fontSize: Get.width * 0.09,
                    textcolor: AppColors.darkBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Center(
                  child: Container(
                    height: Get.height * 0.35,
                    width: Get.width * 0.56,
                    child: Stack(
                      children: [
                        Container(
                          height: Get.height * 0.32,
                          width: Get.width * 0.53,
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _imageFile == null ? AppColors.themeColor : null,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Container(
                            height: Get.height * 0.32,
                            width: Get.width * 0.55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: _imageFile != null
                                    ? FileImage(
                                        _imageFile!) // Display selected image
                                    : const NetworkImage(KeyConstants.imagePlaceHolder)
                                        as ImageProvider, // Default asset image
                                fit: _imageFile != null ? BoxFit.cover : BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: Get.height * 0.27,
                          left: Get.width * 0.41,
                          child: GestureDetector(
                            onTap: _showImagePickerOptions,
                            child: Container(
                              height: 53,
                              width: 53,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFF00E3DF), // Start color
                                    Color(0xFFF2B721), // End color
                                  ],
                                  stops: [0.0, 1.0], // Gradient stops
                                ),
                              ),
                              child: Icon(Icons.add,
                                  color: Colors.white, size: 26),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: Get.width * 0.47,
                    height: size.height * 0.07,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Category',
                        labelStyle: TextStyle(color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      value: selectedCategory,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w600),
                      items: category
                          .map((method) => DropdownMenuItem<String>(
                                value: method,
                                child: Text(method),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Center(
                  child: AppText(
                    text: "PRODUCT TITLE",
                    fontSize: Get.width * 0.04,
                    textcolor: AppColors.darkBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Center(
                  child: SizedBox(
                    width: Get.width * 0.7, // 70% of the screen width
                    child: TextFormField(
                      controller: productTitle,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(50),
                        WordLimitFormatter(wordLimit: 5),    // Limit to 5 words
                      ],
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 10),
                          filled: true,
                          fillColor: Colors.white, // White fill color
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors.grey), // Grey border color
                            borderRadius:
                                BorderRadius.circular(7), // Border radius 1.2
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Colors
                                    .grey), // Grey border color when focused
                            borderRadius: BorderRadius.circular(
                                7), // Border radius 1.2 when focused
                          ),
                          hintText: 'Describe your product in five words ',
                          hintStyle: TextStyle(
                              color: Colors.grey.withOpacity(.60),
                              fontSize: 14)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: AppText(
                    text: "Price Range",
                    fontSize: Get.width * 0.05,
                    textcolor: AppColors.darkBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                        onTap: () {
                          // Increase range
                          _adjustRange(-5); // Increase both start and end by 5
                        },
                        child: Icon(
                          Icons.remove,
                          color: Colors.grey.withOpacity(.70),
                          size: 27,
                        )),
                    Container(
                      width: Get.width * 0.76, // 80% of screen width
                      height: 60, // Height of the slider for a high appearance
                      child: RangeSlider(
                        activeColor: Color(0xff2280ef),
                        inactiveColor: Color(0xff2280ef).withOpacity(.30),
                        values: _currentRangeValues,
                        min: 0,
                        max: 1000,
                        divisions: 100,
                        labels: RangeLabels(
                          _currentRangeValues.start.round().toString(),
                          _currentRangeValues.end.round().toString(),
                        ),
                        onChanged: (RangeValues values) {
                          setState(() {
                            _currentRangeValues = values;
                            minPrice.text =
                                _currentRangeValues.start.toInt().toString();
                            maxPrice.text =
                                _currentRangeValues.end.toInt().toString();
                          });
                        },
                      ),
                    ),
                    GestureDetector(
                        onTap: () {
                          _adjustRange(5); // Increase both start and end by 5
                        },
                        child: Icon(
                          Icons.add,
                          color: Colors.grey.withOpacity(.80),
                          size: 27,
                        ))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Center(
                      child: Container(
                        width: Get.width * 0.32,
                        height: Get.height * 0.06,
                        // 70% of the screen width
                        child: TextFormField(
                          controller: minPrice,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value){
                            if(value.isNotEmpty){
                              if(double.parse(value.trim())<double.parse(maxPrice.text.trim())){
                                _currentRangeValues =  RangeValues(double.parse(value), double.parse(maxPrice.text.trim()));
                              }else{
                                ShowMessage.notify(context, "Minimum value must be smaller then maximum value");
                                minPrice.text = '0';
                                _currentRangeValues =  RangeValues(0, double.parse(maxPrice.text.trim()));
                              }
                            }else{
                              _currentRangeValues =  RangeValues(0, double.parse(maxPrice.text.trim()));
                            }
                            setState(() {

                            });
                          },
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.transparent,
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey), // Grey border color
                                borderRadius: BorderRadius.circular(
                                    30), // Border radius 1.2
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors
                                        .grey), // Grey border color when focused
                                borderRadius: BorderRadius.circular(
                                    30), // Border radius 1.2 when focused
                              ),
                              hintText: '0 SAR ',
                              suffixText: "SAR",
                              hintStyle: TextStyle(
                                  color: Colors.grey.withOpacity(.50),
                                  fontSize: 14)),
                        ),
                      ),
                    ),
                    GestureDetector(
                        onTap: () {
                          // Increase range
                          _adjustRange(-5); // Increase both start and end by 5
                        },
                        child: Icon(
                          Icons.remove,
                          color: Colors.grey.withOpacity(.70),
                          size: 27,
                        )),
                    Center(
                      child: Container(
                        width: Get.width * 0.32,
                        height: Get.height * 0.06, // 70% of the screen width
                        child: TextFormField(
                          controller: maxPrice,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value){
                            if(value.isNotEmpty){
                              if(double.parse(value.trim())>double.parse(minPrice.text.trim()) && double.parse(value.trim()) <= 1000){
                                _currentRangeValues =  RangeValues(double.parse(minPrice.text.trim()),double.parse(value));
                              }else{
                                if(double.parse(value.trim()) > 1000){
                                  maxPrice.text = '1000';
                                  ShowMessage.notify(context, "Maximum value allowed is 1000.");
                                }else{
                                  ShowMessage.notify(context, "Maximum value must be greater then minimum value");
                                  _currentRangeValues =  RangeValues(double.parse(minPrice.text.trim()),500);
                                }
                              }
                            }else{
                              _currentRangeValues =   RangeValues(double.parse(minPrice.text.trim()),500);
                            }
                            setState(() {

                            });
                          },
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.transparent, // White fill color
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey), // Grey border color
                                borderRadius: BorderRadius.circular(
                                    30), // Border radius 1.2
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors
                                        .grey), // Grey border color when focused
                                borderRadius: BorderRadius.circular(
                                    30), // Border radius 1.2 when focused
                              ),
                              hintText: '300 SAR ',
                              suffixText: "SAR",
                              hintStyle: TextStyle(
                                  color: Colors.grey.withOpacity(.50),
                                  fontSize: 14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class WordLimitFormatter extends TextInputFormatter {
  final int wordLimit;

  WordLimitFormatter({required this.wordLimit});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Split the new text into words
    List<String> words = newValue.text.trim().split(RegExp(r'\s+'));

    if (words.length > wordLimit) {
      // If word count exceeds the limit, revert to the old value
      return oldValue;
    }

    return newValue;
  }
}