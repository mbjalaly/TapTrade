import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/Services/IntegrationServices/generalService.dart';
import 'package:taptrade/Services/IntegrationServices/productService.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Screens/Dashboard/Bottombar/bottombarscreen.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';
import 'package:taptrade/l10n/app_localizations.dart';
import 'package:taptrade/Widgets/saudi_riyal_symbol.dart';

class AddProductWizardScreen extends StatefulWidget {
  const AddProductWizardScreen({Key? key, this.initialTitle, this.initialCategory, this.initialCondition, this.initialMinPrice, this.initialMaxPrice}) : super(key: key);

  final String? initialTitle;
  final String? initialCategory;
  final String? initialCondition;
  final double? initialMinPrice;
  final double? initialMaxPrice;

  @override
  State<AddProductWizardScreen> createState() => _AddProductWizardScreenState();
}

class _AddProductWizardScreenState extends State<AddProductWizardScreen> {
  final ImagePicker _picker = ImagePicker();
  final userController = Get.find<UserController>();

  // Step state
  int _currentStep = 0;
  final List<File> _images = [];
  int _coverIndex = 0;

  // Details
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _quantity = TextEditingController(text: '1');
  String? _category;
  String _condition = 'New';

  // Pricing
  final TextEditingController _minPrice = TextEditingController(text: '0');
  final TextEditingController _maxPrice = TextEditingController(text: '500');
  RangeValues _range = const RangeValues(0, 500);

  // Validation errors
  String? _minPriceError;
  String? _maxPriceError;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Ensure categories are loaded
    final hasCategories = (GeneralService.instance.allCategory.value.data ?? const []).isNotEmpty;
    if (!hasCategories) {
      // Fire and forget; UI below observes with Obx
      GeneralService.instance.getAllCategories(context);
    }
    if ((widget.initialTitle ?? '').isNotEmpty) {
      _title.text = widget.initialTitle!;
    }
    if ((widget.initialCategory ?? '').isNotEmpty) {
      _category = widget.initialCategory;
    }
    if ((widget.initialCondition ?? '').isNotEmpty) {
      _condition = widget.initialCondition!;
    }
    if (widget.initialMinPrice != null && widget.initialMaxPrice != null) {
      _minPrice.text = widget.initialMinPrice!.toInt().toString();
      _maxPrice.text = widget.initialMaxPrice!.toInt().toString();
      _range = RangeValues(widget.initialMinPrice!.clamp(0, 1000), widget.initialMaxPrice!.clamp(0, 1000));
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _quantity.dispose();
    _minPrice.dispose();
    _maxPrice.dispose();
    super.dispose();
  }

  Future<void> _showImagePickerOptions() async {
    final l10n = AppLocalizations.of(context)!;
    if (Platform.isIOS) {
      // iOS native action sheet
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
              child: Text(l10n.takePhoto),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _pickImages();
              },
              child: Text(l10n.chooseFromPhotos),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(l10n.cancel),
          ),
        ),
      );
    } else {
      // Android material bottom sheet
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text(l10n.takePhoto),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text(l10n.chooseFromPhotos),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImages();
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Future<void> _pickImageFromCamera() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (photo != null) {
        setState(() {
          const MAX_IMAGES = 4;
          _images.add(File(photo.path));
          if (_images.length > MAX_IMAGES) {
            _images.removeRange(MAX_IMAGES, _images.length);
            ShowMessage.notify(context, l10n.maximumImagesAllowed(MAX_IMAGES));
          }
        });
      }
    } catch (e) {
      ShowMessage.notify(context, 'Camera access failed: $e');
    }
  }

  Future<void> _pickImages() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final List<XFile> picked = await _picker.pickMultiImage(imageQuality: 85);
      if (picked.isNotEmpty) {
        setState(() {
          const MAX_IMAGES = 4; // Maximum 4 images allowed
          _images.addAll(picked.map((x) => File(x.path)));
          if (_images.length > MAX_IMAGES) {
            _images.removeRange(MAX_IMAGES, _images.length);
            ShowMessage.notify(context, l10n.maximumImagesAllowed(MAX_IMAGES));
          }
        });
      }
    } catch (e) {
      ShowMessage.notify(context, 'Image pick failed: $e');
    }
  }

  void _viewImage(File image, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4,
                  child: Image.file(image, fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Image ${index + 1} of ${_images.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _next() {
    final l10n = AppLocalizations.of(context)!;
    const MAX_IMAGES = 4; // Maximum 4 images allowed
    if (_currentStep == 0 && (_images.isEmpty || _images.length > MAX_IMAGES)) {
      ShowMessage.notify(context, l10n.addAtLeastOnePhoto(MAX_IMAGES));
      return;
    }
    if (_currentStep == 1) {
      if (_category == null || _title.text.trim().isEmpty) {
        ShowMessage.notify(context, l10n.pleaseEnterTitleAndCategory);
        return;
      }
      if (_description.text.trim().isEmpty) {
        ShowMessage.notify(context, l10n.pleaseEnterDescription);
        return;
      }
      if (_description.text.trim().length > 500) {
        ShowMessage.notify(context, l10n.descriptionTooLong);
        return;
      }
      final qty = int.tryParse(_quantity.text.trim());
      if (qty == null || qty < 1 || qty > 99) {
        ShowMessage.notify(context, l10n.quantityMustBeBetween);
        return;
      }
    }
    if (_currentStep == 2) {
      final double minV = double.tryParse(_minPrice.text.trim()) ?? 0;
      final double maxV = double.tryParse(_maxPrice.text.trim()) ?? 0;
      if (minV < 0 || maxV <= minV) {
        ShowMessage.notify(context, l10n.minPriceMustBeLess);
        return;
      }
    }
    setState(() {
      _currentStep = (_currentStep + 1).clamp(0, 3);
    });
  }

  void _back() {
    setState(() {
      _currentStep = (_currentStep - 1).clamp(0, 3);
    });
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final String id = userController.userProfile.value.data?.id ?? '';
    if (id.isEmpty) {
      ShowMessage.notify(context, l10n.userNotFound);
      return;
    }
    if (_images.isEmpty) {
      ShowMessage.notify(context, l10n.pleaseAddPhotos);
      return;
    }
    if ((_category ?? '').isEmpty) {
      ShowMessage.notify(context, l10n.selectACategory);
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      // Ensure cover index is valid
      if (_coverIndex < 0 || _coverIndex >= _images.length) {
        _coverIndex = 0; // Fallback to first image
      }

      // Upload all images - cover image as 'image' and all images as 'images' array
      final File cover = _images[_coverIndex];

      // Reorder images to put cover first
      final List<File> orderedImages = [cover]; // Cover first
      for (int i = 0; i < _images.length; i++) {
        if (i != _coverIndex) {
          orderedImages.add(_images[i]);
        }
      }

      final Map<String, dynamic> body = {
        'category': _category,
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        'quantity': int.tryParse(_quantity.text.trim()) ?? 1,
        'min_price': double.tryParse(_minPrice.text.trim()) ?? 0,
        'max_price': double.tryParse(_maxPrice.text.trim()) ?? 0,
        'image': cover, // Primary/cover image (must be first)
        'images': orderedImages, // All images as array with cover first
        'product_condition': _condition,
      };
      final ApiResponse resp = await ProductService.instance.addSingleProduct(context, body, id);
      if (resp.status == Status.COMPLETED) {
        ShowMessage.notify(context, l10n.productSubmitted);
        // Navigate to home screen after first product submission
        Get.offAll(() => const BottomNavigationScreen());
      } else {
        ShowMessage.notify(context, l10n.failedToSubmitProduct);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addProduct),
        centerTitle: false,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _currentStep == 3 ? null : _next,
        onStepCancel: _currentStep == 0 ? null : _back,
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                if (_currentStep > 0)
                  OutlinedButton(onPressed: details.onStepCancel, child: Text(l10n.back)),
                const SizedBox(width: 8),
                if (_currentStep < 3)
                  ElevatedButton(onPressed: details.onStepContinue, child: Text(l10n.next)),
                if (_currentStep == 3)
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(l10n.submit),
                  )
              ],
            ),
          );
        },
        steps: [
          Step(
            title: Text(l10n.photos),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.addAtLeastOnePhoto(4), style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(l10n.tapToSetCoverPhoto, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (int i = 0; i < _images.length; i++)
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _coverIndex = i),
                            onLongPress: () => _viewImage(_images[i], i),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: i == _coverIndex ? AppColors.primaryColor : Colors.transparent, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(_images[i], height: 90, width: 90, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 4,
                            top: 4,
                            child: i == _coverIndex ? const CircleAvatar(radius: 10, backgroundColor: AppColors.primaryColor, child: Icon(Icons.star, size: 12, color: Colors.white)) : const SizedBox(),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _images.removeAt(i);
                                  if (_coverIndex >= _images.length) _coverIndex = 0;
                                });
                              },
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.black54,
                                child: Icon(Icons.close, color: Colors.white, size: 14),
                              ),
                            ),
                          )
                        ],
                      ),
                    InkWell(
                      onTap: _showImagePickerOptions,
                      child: Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          color: AppColors.fieldBg(context),
                          border: Border.all(color: AppColors.outlineColor(context)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add_a_photo_outlined),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Step(
            title: Text(l10n.details),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(l10n.title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _title,
                  decoration: InputDecoration(hintText: l10n.enterShortTitle),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(l10n.category, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 6),
                Obx(() {
                  final List<String> categories = GeneralService.instance.allCategory.value.data
                          ?.map((e) => e.name)
                          .whereType<String>()
                          .where((name) => name.isNotEmpty)
                          .toList() ??
                      [];
                  final items = categories
                      .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
                      .toList();
                  // If current selection is no longer in list, clear it
                  if (_category != null && !categories.contains(_category)) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _category = null);
                    });
                  }
                  return DropdownButtonFormField<String>(
                    value: _category,
                    items: items,
                    onChanged: items.isEmpty ? null : (v) => setState(() => _category = v),
                    decoration: InputDecoration(
                      hintText: items.isEmpty ? l10n.loadingCategories : l10n.selectACategory,
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(l10n.descriptionRequired, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _description,
                  maxLines: 4,
                  minLines: 2,
                  decoration: InputDecoration(
                    hintText: l10n.describeProductDetail,
                    counterText: '${_description.text.length}/500',
                  ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(500),
                  ],
                  onChanged: (value) {
                    setState(() {}); // Update character counter
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(l10n.quantityAvailable, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        final current = int.tryParse(_quantity.text) ?? 1;
                        if (current > 1) {
                          setState(() => _quantity.text = (current - 1).toString());
                        }
                      },
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _quantity,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          hintText: '1',
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        onChanged: (value) {
                          if (value.isEmpty) {
                            _quantity.text = '1';
                            _quantity.selection = TextSelection.fromPosition(
                              const TextPosition(offset: 1),
                            );
                          } else {
                            final qty = int.tryParse(value) ?? 1;
                            if (qty > 99) {
                              _quantity.text = '99';
                              _quantity.selection = TextSelection.fromPosition(
                                TextPosition(offset: _quantity.text.length),
                              );
                            } else if (qty < 1) {
                              _quantity.text = '1';
                              _quantity.selection = TextSelection.fromPosition(
                                TextPosition(offset: _quantity.text.length),
                              );
                            }
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        final current = int.tryParse(_quantity.text) ?? 1;
                        if (current < 99) {
                          setState(() => _quantity.text = (current + 1).toString());
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Step(
            title: Text(l10n.conditionAndPrice),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(l10n.condition, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _condition,
                  items: [
                    DropdownMenuItem(value: 'New', child: Text(l10n.productNew)),
                    DropdownMenuItem(value: 'Like New', child: Text(l10n.productLikeNew)),
                    DropdownMenuItem(value: 'Good', child: Text(l10n.productGood)),
                    DropdownMenuItem(value: 'Fair', child: Text(l10n.productFair)),
                    DropdownMenuItem(value: 'Poor', child: Text(l10n.poor)),
                  ],
                  onChanged: (v) => setState(() => _condition = v ?? 'New'),
                  decoration: InputDecoration(hintText: l10n.selectCondition),
                ),
                const SizedBox(height: 12),
                RangeSlider(
                  activeColor: AppColors.primaryText(context),
                  values: _range,
                  min: 0,
                  max: 1000,
                  divisions: 100,
                  labels: RangeLabels(_range.start.round().toString(), _range.end.round().toString()),
                  onChanged: (val) {
                    setState(() {
                      _range = val;
                      _minPrice.text = _range.start.toInt().toString();
                      _maxPrice.text = _range.end.toInt().toString();
                    });
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _minPrice,
                        decoration: InputDecoration(
                          labelText: l10n.minPrice,
                          errorText: _minPriceError,
                          errorStyle: const TextStyle(fontSize: 10),
                          suffixIcon: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SaudiRiyalSymbol(color: Colors.grey, size: 24),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (v) {
                          setState(() => _minPriceError = null);
                          final minVal = double.tryParse(v) ?? 0;
                          final maxVal = double.tryParse(_maxPrice.text) ?? 500;
                          if (minVal >= maxVal) {
                            setState(() => _minPriceError = l10n.minMustBeLessThanMax);
                            return;
                          }
                          if (minVal <= _range.end) setState(() => _range = RangeValues(minVal, _range.end));
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _maxPrice,
                        decoration: InputDecoration(
                          labelText: l10n.maxPrice,
                          errorText: _maxPriceError,
                          errorStyle: const TextStyle(fontSize: 10),
                          suffixIcon: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SaudiRiyalSymbol(color: Colors.grey, size: 24),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (v) {
                          setState(() => _maxPriceError = null);
                          final minVal = double.tryParse(_minPrice.text) ?? 0;
                          final maxVal = double.tryParse(v) ?? 0;
                          if (maxVal > 1000) {
                            setState(() => _maxPriceError = l10n.maxCannotExceed1000);
                            return;
                          }
                          if (maxVal <= minVal) {
                            setState(() => _maxPriceError = l10n.maxMustBeGreaterThanMin);
                            return;
                          }
                          if (maxVal >= _range.start) setState(() => _range = RangeValues(_range.start, maxVal));
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Step(
            title: Text(l10n.review),
            isActive: _currentStep >= 3,
            state: StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.preview, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(l10n.tapImagesToView, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                const SizedBox(height: 8),
                if (_images.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (int i = 0; i < _images.take(4).length; i++)
                        GestureDetector(
                          onTap: () => _viewImage(_images[i], i),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_images[i], height: 64, width: 64, fit: BoxFit.cover),
                          ),
                        ),
                      if (_images.length > 4)
                        GestureDetector(
                          onTap: () => _viewImage(_images[4], 4),
                          child: Chip(label: Text('+${_images.length - 4} more')),
                        ),
                    ],
                  )
                else
                  Text(l10n.noPhotosSelected),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.photo_library_outlined),
                        title: Text(l10n.photosSelected(_images.length)),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.label_outline),
                        title: Text(l10n.title),
                        subtitle: Text(_title.text.isEmpty ? '-' : _title.text),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.category_outlined),
                        title: Text(l10n.category),
                        subtitle: Text(_category ?? '-'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.description_outlined),
                        title: Text(l10n.description),
                        subtitle: Text(_description.text.isEmpty ? '-' : _description.text),
                        isThreeLine: _description.text.length > 50,
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.format_list_numbered),
                        title: Text(l10n.quantity),
                        subtitle: Text(_quantity.text),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.inventory_2_outlined),
                        title: Text(l10n.condition),
                        subtitle: Text(_condition),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.price_check_outlined),
                        title: Text(l10n.priceRange),
                        subtitle: SaudiRiyalFormatter.formatRange(
                          _minPrice.text,
                          _maxPrice.text,
                          fontSize: 14,
                          color: AppColors.secondaryText(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(l10n.pressSubmitToUpload)
              ],
            ),
          ),
        ],
      ),
    );
  }
}


