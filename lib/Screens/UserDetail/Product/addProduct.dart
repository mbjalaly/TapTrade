import 'dart:io';
import 'package:flutter/material.dart';
import 'package:taptrade/Widgets/saudi_riyal_symbol.dart';
import 'package:taptrade/l10n/app_localizations.dart';
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
import 'package:taptrade/Screens/Dashboard/Bottombar/bottombarscreen.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/deviceResolutionType.dart';
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
  final List<File> _images = [];
  TextEditingController productTitle = TextEditingController();
  TextEditingController productDescription = TextEditingController();
  TextEditingController minPrice = TextEditingController(text: '0');
  TextEditingController maxPrice = TextEditingController(text: '500');
  TextEditingController quantityController = TextEditingController(text: '1');
  String? selectedCategory;
  String _selectedCondition = 'New';  // Default to New
  String? _minPriceError;
  String? _maxPriceError;
  RangeValues _currentRangeValues = const RangeValues(0, 500);
  Future<void> _showImagePickerOptions() async {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      backgroundColor: AppColors.contentBg(context),
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text(l10n.camera),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_album),
                title: Text(l10n.galleryMultiple),
                onTap: () {
                  _pickMultipleImages();
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
        minPrice.text = start.toString();
        maxPrice.text = end.toString();
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
    if (_imageFile != null && _images.isEmpty) {
      _images.add(_imageFile!);
    }
    FocusScope.of(context).unfocus();
    print("-=-=-=-=-=-= ${pickedFile.path}");
    print("-=-=-=-=-=-= ${_imageFile?.path}");
    setState(() {

    });
  }

  Future<void> _pickMultipleImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> picked = await picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;
    final List<File> resized = [];
    for (final x in picked) {
      final File? file = await resizeImage(x, 300, 400);
      if (file != null) resized.add(file);
    }
    if (resized.isEmpty) return;
    setState(() {
      _images.addAll(resized);
      // Use the first as cover if none set yet
      _imageFile ??= _images.first;
      // Cap to 4 images to keep payload reasonable
      const MAX_IMAGES = 4;
      if (_images.length > MAX_IMAGES) {
        _images.removeRange(MAX_IMAGES, _images.length);
        ShowMessage.notify(context, 'Maximum $MAX_IMAGES images allowed');
      }
    });
  }

  void clearFields() {
    selectProduct = ProductModel();
    _imageFile = null;
    productTitle.clear();
    productDescription.clear();
    minPrice.text = '0';
    maxPrice.text = '500';
    quantityController.text = '1';
    selectedCategory = null;
    _selectedCondition = 'New';
    _currentRangeValues = RangeValues(0, 500);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.contentBg(context),
        bottomNavigationBar: Container(
          color: AppColors.secondaryColor.withOpacity(0.1),
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.225,vertical: 20),
          child: AppButton(
            onPressed: () async {
              String? message;
              if (productList.length < 3) {
                if (_imageFile == null) {
                  message = l10n.pleaseAddProductImage;
                } else if (selectedCategory == null) {
                  message = l10n.pleaseSelectProductCategory;
                } else if (productTitle.text.trim().isEmpty) {
                  message = l10n.pleaseAddProductTitle;
                } else if (productDescription.text.trim().isEmpty) {
                  message = l10n.pleaseAddProductDescription;
                } else if (productDescription.text.trim().length > 500) {
                  message = l10n.descriptionTooLong;
                } else if (quantityController.text.trim().isEmpty) {
                  message = l10n.pleaseAddProductQuantity;
                } else if (int.tryParse(quantityController.text.trim()) == null) {
                  message = l10n.pleaseEnterValidQuantity;
                } else if ((int.tryParse(quantityController.text.trim()) ?? 0) < 1 || (int.tryParse(quantityController.text.trim()) ?? 0) > 99) {
                  message = l10n.quantityMustBeBetween;
                } else if (minPrice.text.trim().isEmpty) {
                  message = l10n.pleaseAddMinPrice;
                } else if (maxPrice.text.trim().isEmpty) {
                  message = l10n.pleaseAddMaxPrice;
                }
              }

              if (message != null) {
                ShowMessage.notify(context, message);
              } else {
                if (productList.length >= 3 && widget.isDirect == false) {
                  Get.to(() => MyProduct(
                        productList: productList,
                      ));
                } else {
                  String id = userController.userProfile.value.data?.id ?? '';
                  // Send category as name per backend expectation
                  if ((selectedCategory ?? '').isEmpty) {
                    ShowMessage.notify(context, l10n.selectACategory);
                    return;
                  }
                  // Prepare single image to send: if multiple selected, merge into one PNG
                  File? imageToSend = _imageFile ?? (_images.isNotEmpty ? _images.first : null);
                  if (_images.length > 1) {
                    imageToSend = await mergeImagesToSinglePng(_images, columns: 2, tileSize: 300, padding: 8, quality: 85);
                  }

                  // Validate prices
                  final minPriceValue = double.tryParse(minPrice.text) ?? 0;
                  final maxPriceValue = double.tryParse(maxPrice.text) ?? 0;

                  if (minPriceValue >= maxPriceValue) {
                    ShowMessage.notify(context, l10n.minPriceMustBeLess);
                    setState(() {
                      isLoading = false;
                    });
                    return;
                  }
                  
                  Map<String, dynamic> body = {
                    "category": selectedCategory,
                    "title": productTitle.text,
                    "description": productDescription.text.trim(),
                    "min_price": minPriceValue,
                    "max_price": maxPriceValue,
                    "quantity": int.tryParse(quantityController.text.trim()) ?? 1,
                    // Send the prepared PNG image
                    "image": imageToSend,
                    "product_condition": _selectedCondition,  // Changed from hardcoded "New"
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
                            context, l10n.productAddedCount(productList.length));
                        clearFields();
                      } else {
                        ShowMessage.notify(context,
                            l10n.pleaseAddThreeProducts(productList.length));
                      }
                    }else{
                      ShowMessage.notify(context, l10n.productAddedSuccessfully);
                      // Navigate to home screen after adding product
                      Get.offAll(() => const BottomNavigationScreen());
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
            text: widget.isDirect ? (AppLocalizations.of(context)?.addButton ?? "+ Add") : productList.length >= 3 ? (AppLocalizations.of(context)?.saveButton ?? "Save") : (AppLocalizations.of(context)?.addButton ?? "+ Add"),
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
                      text: l10n.addProducts,
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
                            child: Stack(
                              children: [
                                Container(
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
                                // NEW: Image count badge
                                if (_images.length > 1)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        l10n.imagesCount(_images.length),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
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
                      width: Get.width * 0.55,
                      height: size.height * 0.07,
                      child: Obx(() {
                        final categories = GeneralService.instance.allCategory.value.data
                                ?.map((e) => e.name ?? '')
                                .where((name) => name.isNotEmpty)
                                .toList() ??
                            [];
                        final items = categories
                            .map((name) => DropdownMenuItem<String>(
                                  value: name,
                                  child: Text(name),
                                ))
                            .toList();

                        // Reset selectedCategory if it's not in the latest list
                        if (selectedCategory != null && !categories.contains(selectedCategory)) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              selectedCategory = null;
                            });
                          });
                        }

                        return DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: items.isEmpty ? l10n.noCategoriesAvailable : l10n.selectCategory,
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
                          style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textOnBg(context),
                              fontWeight: FontWeight.w600),
                          items: items,
                          onChanged: items.isEmpty
                              ? null
                              : (value) {
                                  setState(() {
                                    selectedCategory = value;
                                  });
                                },
                        );
                      }),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Center(
                    child: AppText(
                      text: l10n.productTitleLabel,
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
                            fillColor: AppColors.fieldBg(context),
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
                            hintText: l10n.describeProductShort,
                            hintStyle: TextStyle(
                                color: Colors.grey.withOpacity(.60),
                                fontSize: 14)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  // PRODUCT DESCRIPTION (REQUIRED)
                  Center(
                    child: AppText(
                      text: l10n.productDescriptionLabel,
                      fontSize: Get.width * 0.04,
                      textcolor: AppColors.darkBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 15),
                  Center(
                    child: SizedBox(
                      width: Get.width * 0.7,
                      child: TextFormField(
                        controller: productDescription,
                        maxLines: 5,
                        minLines: 3,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(500),
                        ],
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          filled: true,
                          fillColor: AppColors.fieldBg(context),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          hintText: l10n.describeProductDetailRequired,
                          hintStyle: TextStyle(
                            color: Colors.grey.withOpacity(.60),
                            fontSize: 14,
                          ),
                          counterText: '${productDescription.text.length}/500',
                        ),
                        onChanged: (value) {
                          setState(() {}); // Update character counter
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  // QUANTITY AVAILABLE
                  Center(
                    child: AppText(
                      text: l10n.quantityAvailable,
                      fontSize: Get.width * 0.04,
                      textcolor: AppColors.darkBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 15),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: AppColors.darkBlue, size: 32),
                          onPressed: () {
                            final current = int.tryParse(quantityController.text) ?? 1;
                            if (current > 1) {
                              quantityController.text = (current - 1).toString();
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: Get.width * 0.25,
                          child: TextFormField(
                            controller: quantityController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                              filled: true,
                              fillColor: AppColors.fieldBg(context),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              hintText: '1',
                              hintStyle: TextStyle(
                                color: Colors.grey.withOpacity(.60),
                                fontSize: 16,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            onChanged: (value) {
                              if (value.isEmpty) {
                                // Auto-fill with 1 if user deletes all text
                                quantityController.text = '1';
                                quantityController.selection = TextSelection.fromPosition(
                                  TextPosition(offset: 1),
                                );
                              } else if (value.isNotEmpty) {
                                final qty = int.tryParse(value) ?? 1;
                                if (qty > 99) {
                                  quantityController.text = '99';
                                  quantityController.selection = TextSelection.fromPosition(
                                    TextPosition(offset: quantityController.text.length),
                                  );
                                } else if (qty < 1) {
                                  quantityController.text = '1';
                                  quantityController.selection = TextSelection.fromPosition(
                                    TextPosition(offset: quantityController.text.length),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: AppColors.darkBlue, size: 32),
                          onPressed: () {
                            final current = int.tryParse(quantityController.text) ?? 1;
                            if (current < 99) {
                              quantityController.text = (current + 1).toString();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Center(
                    child: AppText(
                      text: l10n.productConditionLabel,
                      fontSize: Get.width * 0.04,
                      textcolor: AppColors.darkBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 15),
                  Center(
                    child: SizedBox(
                      width: Get.width * 0.7,
                      child: DropdownButtonFormField<String>(
                        value: _selectedCondition,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.fieldBg(context),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        items: {
                          'New': l10n.productNew,
                          'Like New': l10n.productLikeNew,
                          'Good': l10n.productGood,
                          'Fair': l10n.productFair,
                          'Poor': l10n.poor,
                        }.entries
                            .map((entry) => DropdownMenuItem(
                                  value: entry.key,
                                  child: Text(entry.value),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCondition = value ?? 'New';
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Center(
                    child: AppText(
                      text: l10n.priceRange,
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
                              setState(() {
                                _minPriceError = null;  // Clear error
                              });

                              if(value.isNotEmpty){
                                final minVal = double.tryParse(value.trim());
                                final maxVal = double.tryParse(maxPrice.text.trim());

                                if (minVal != null && maxVal != null) {
                                  if(minVal >= maxVal){
                                    setState(() {
                                      _minPriceError = AppLocalizations.of(context)?.minMustBeLessThanMax ?? "Min must be less than max";
                                    });
                                    return;
                                  }
                                  _currentRangeValues = RangeValues(minVal, maxVal);
                                }
                              }else{
                                _currentRangeValues = RangeValues(0, double.parse(maxPrice.text.trim()));
                              }
                              setState(() {});
                            },
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.transparent,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: _minPriceError != null ? Colors.red : Colors.grey),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: _minPriceError != null ? Colors.red : Colors.grey),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red, width: 2),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                hintText: '0 ',
                                suffixIcon: const Padding(
                                  padding: EdgeInsets.all(14.0),
                                  child: SaudiRiyalSymbol(color: Colors.grey, size: 16),
                                ),
                                errorText: _minPriceError,  // NEW: Show inline error
                                errorStyle: TextStyle(fontSize: 10),
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
                              setState(() {
                                _maxPriceError = null;  // Clear error
                              });

                              if(value.isNotEmpty){
                                final minVal = double.tryParse(minPrice.text.trim());
                                final maxVal = double.tryParse(value.trim());

                                if (minVal != null && maxVal != null) {
                                  if(maxVal > 1000){
                                    setState(() {
                                      _maxPriceError = AppLocalizations.of(context)?.maxCannotExceed ?? "Max cannot exceed 1000";
                                    });
                                    return;
                                  }
                                  if(maxVal <= minVal){
                                    setState(() {
                                      _maxPriceError = AppLocalizations.of(context)?.maxMustBeGreaterThanMin ?? "Max must be greater than min";
                                    });
                                    return;
                                  }
                                  _currentRangeValues = RangeValues(minVal, maxVal);
                                }
                              }else{
                                _currentRangeValues = RangeValues(double.parse(minPrice.text.trim()),500);
                              }
                              setState(() {});
                            },
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.transparent,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: _maxPriceError != null ? Colors.red : Colors.grey),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: _maxPriceError != null ? Colors.red : Colors.grey),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red, width: 2),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                hintText: '300 ',
                                suffixIcon: const Padding(
                                  padding: EdgeInsets.all(14.0),
                                  child: SaudiRiyalSymbol(color: Colors.grey, size: 16),
                                ),
                                errorText: _maxPriceError,  // NEW: Show inline error
                                errorStyle: TextStyle(fontSize: 10),
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