import 'dart:io';
import 'package:flutter/material.dart';
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
  String? _category;
  String _condition = 'New';

  // Pricing
  final TextEditingController _minPrice = TextEditingController(text: '0');
  final TextEditingController _maxPrice = TextEditingController(text: '500');
  RangeValues _range = const RangeValues(0, 500);

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
    _minPrice.dispose();
    _maxPrice.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> picked = await _picker.pickMultiImage(imageQuality: 85);
      if (picked.isNotEmpty) {
        setState(() {
          const MAX_IMAGES = 4; // Maximum 4 images allowed
          _images.addAll(picked.map((x) => File(x.path)));
          if (_images.length > MAX_IMAGES) {
            _images.removeRange(MAX_IMAGES, _images.length);
            ShowMessage.notify(context, 'Maximum ${MAX_IMAGES} images allowed');
          }
        });
      }
    } catch (e) {
      ShowMessage.notify(context, 'Image pick failed: $e');
    }
  }

  void _next() {
    const MAX_IMAGES = 4; // Maximum 4 images allowed
    if (_currentStep == 0 && (_images.isEmpty || _images.length > MAX_IMAGES)) {
      ShowMessage.notify(context, 'Please add at least 1 photo (maximum $MAX_IMAGES)');
      return;
    }
    if (_currentStep == 1) {
      if (_category == null || _title.text.trim().isEmpty) {
        ShowMessage.notify(context, 'Please enter title and category');
        return;
      }
    }
    if (_currentStep == 2) {
      final double minV = double.tryParse(_minPrice.text.trim()) ?? 0;
      final double maxV = double.tryParse(_maxPrice.text.trim()) ?? 0;
      if (minV < 0 || maxV <= minV) {
        ShowMessage.notify(context, 'Minimum price must be less than maximum price');
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
    final String id = userController.userProfile.value.data?.id ?? '';
    if (id.isEmpty) {
      ShowMessage.notify(context, 'User not found');
      return;
    }
    if (_images.isEmpty) {
      ShowMessage.notify(context, 'Please add photos');
      return;
    }
    if ((_category ?? '').isEmpty) {
      ShowMessage.notify(context, 'Please select a category');
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
        'min_price': double.tryParse(_minPrice.text.trim()) ?? 0,
        'max_price': double.tryParse(_maxPrice.text.trim()) ?? 0,
        'image': cover, // Primary/cover image (must be first)
        'images': orderedImages, // All images as array with cover first
        'product_condition': _condition,
      };
      final ApiResponse resp = await ProductService.instance.addSingleProduct(context, body, id);
      if (resp.status == Status.COMPLETED) {
        ShowMessage.notify(context, 'Product submitted');
        // Navigate to home screen after first product submission
        Get.offAll(() => const BottomNavigationScreen());
      } else {
        ShowMessage.notify(context, 'Failed to submit product');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add product'),
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
                  OutlinedButton(onPressed: details.onStepCancel, child: const Text('Back')),
                const SizedBox(width: 8),
                if (_currentStep < 3)
                  ElevatedButton(onPressed: details.onStepContinue, child: const Text('Next')),
                if (_currentStep == 3)
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Submit'),
                  )
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Photos'),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add at least 1 photo', style: Theme.of(context).textTheme.bodyMedium),
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
                      onTap: _pickImages,
                      child: Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          color: AppColors.fieldColor,
                          border: Border.all(color: AppColors.outline),
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
            title: const Text('Details'),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Title', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(hintText: 'Enter a short title'),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Category', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
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
                      hintText: items.isEmpty ? 'Loading categories...' : 'Select a category',
                    ),
                  );
                }),
              ],
            ),
          ),
          Step(
            title: const Text('Condition & Price'),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Condition', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _condition,
                  items: const [
                    DropdownMenuItem(value: 'New', child: Text('New')),
                    DropdownMenuItem(value: 'Like New', child: Text('Like New')),
                    DropdownMenuItem(value: 'Used - Good', child: Text('Used - Good')),
                    DropdownMenuItem(value: 'Used - Fair', child: Text('Used - Fair')),
                  ],
                  onChanged: (v) => setState(() => _condition = v ?? 'New'),
                  decoration: const InputDecoration(hintText: 'Select condition'),
                ),
                const SizedBox(height: 12),
                RangeSlider(
                  activeColor: AppColors.primaryTextColor,
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
                        decoration: const InputDecoration(labelText: 'Min price'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (v) {
                          final d = double.tryParse(v) ?? 0;
                          if (d <= _range.end) setState(() => _range = RangeValues(d, _range.end));
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _maxPrice,
                        decoration: const InputDecoration(labelText: 'Max price'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (v) {
                          final d = double.tryParse(v) ?? 0;
                          if (d >= _range.start) setState(() => _range = RangeValues(_range.start, d));
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Review'),
            isActive: _currentStep >= 3,
            state: StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Preview', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                if (_images.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final f in _images.take(4))
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(f, height: 64, width: 64, fit: BoxFit.cover),
                        ),
                      if (_images.length > 4)
                        Chip(label: Text('+${_images.length - 4} more')),
                    ],
                  )
                else
                  const Text('No photos selected'),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.photo_library_outlined),
                        title: Text('${_images.length} photos selected'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.label_outline),
                        title: const Text('Title'),
                        subtitle: Text(_title.text.isEmpty ? '-' : _title.text),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.category_outlined),
                        title: const Text('Category'),
                        subtitle: Text(_category ?? '-'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.inventory_2_outlined),
                        title: const Text('Condition'),
                        subtitle: Text(_condition),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.attach_money),
                        title: const Text('Price range'),
                        subtitle: Text('${_minPrice.text} - ${_maxPrice.text}'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Press Submit to upload all items')
              ],
            ),
          ),
        ],
      ),
    );
  }
}


