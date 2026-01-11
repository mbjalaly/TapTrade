import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taptrade/Const/globleKey.dart';
import 'package:taptrade/Models/MyProductModel/myProductModel.dart' as mp;
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/Services/IntegrationServices/generalService.dart';
import 'package:taptrade/Services/IntegrationServices/productService.dart';
import 'package:taptrade/Services/ApiResponse/apiResponse.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Utills/showMessages.dart';

// Helper class to track images (either existing URL/base64 or new File)
class _ImageItem {
  final String? url; // Existing image URL/base64
  final File? file; // New image file
  final bool isCover;
  
  _ImageItem({this.url, this.file, this.isCover = false});
  
  bool get isNew => file != null;
  bool get isExisting => url != null && file == null;
}

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({Key? key, required this.product}) : super(key: key);
  final mp.Data product;

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _minPrice = TextEditingController();
  final TextEditingController _maxPrice = TextEditingController();
  String? _category;
  String _condition = 'New';
  final List<_ImageItem> _allImages = [];
  int _coverIndex = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _title.text = widget.product.title ?? '';
    _category = widget.product.category;
    _condition = widget.product.productCondition?.isNotEmpty == true ? widget.product.productCondition! : 'New';
    _minPrice.text = widget.product.minPrice ?? '0';
    _maxPrice.text = widget.product.maxPrice ?? '0';
    
    // Load existing images
    _loadExistingImages();
  }

  void _loadExistingImages() {
    final List<_ImageItem> loaded = [];
    
    // Add cover image (always first)
    if (widget.product.image != null && widget.product.image!.isNotEmpty) {
      loaded.add(_ImageItem(url: widget.product.image, isCover: true));
    }
    
    // Add additional images (exclude cover if it's also in images array)
    final existingImages = widget.product.images ?? [];
    final coverUrl = widget.product.image ?? '';
    for (final imgUrl in existingImages) {
      final imgStr = imgUrl.toString();
      // Skip if this is the cover image
      if (imgStr != coverUrl) {
        loaded.add(_ImageItem(url: imgStr, isCover: false));
      }
    }
    
    setState(() {
      _allImages.clear();
      _allImages.addAll(loaded);
      _coverIndex = 0; // First image is always cover
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _minPrice.dispose();
    _maxPrice.dispose();
    super.dispose();
  }

  // Helper widget to display images (handles base64 data URIs and regular URLs)
  Widget _buildProductImage(String? imageUrl, {double? width, double? height}) {
    final w = width ?? 88.0;
    final h = height ?? 88.0;
    
    // Always return a widget, even if there's an error
    Widget buildPlaceholder() {
      return Image.network(
        KeyConstants.imagePlaceHolder,
        width: w,
        height: h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: w,
            height: h,
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported, color: Colors.grey),
          );
        },
      );
    }
    
    if (imageUrl == null || imageUrl.isEmpty) {
      return buildPlaceholder();
    }
    
    // Handle base64 data URIs
    if (imageUrl.startsWith('data:image')) {
      try {
        final parts = imageUrl.split(',');
        if (parts.length == 2) {
          final base64String = parts[1];
          final bytes = base64Decode(base64String);
          return Image.memory(
            Uint8List.fromList(bytes),
            width: w,
            height: h,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Error displaying base64 image: $error');
              return buildPlaceholder();
            },
          );
        }
      } catch (e) {
        print('Error decoding base64 image: $e');
        return buildPlaceholder();
      }
    }
    
    // Handle regular HTTP URLs or relative paths
    try {
      final finalUrl = imageUrl.startsWith('http')
          ? imageUrl
          : KeyConstants.imageUrl + imageUrl;
      
      return Image.network(
        finalUrl,
        width: w,
        height: h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading network image: $error');
          return buildPlaceholder();
        },
      );
    } catch (e) {
      print('Error building image URL: $e');
      return buildPlaceholder();
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> picked = await ImagePicker().pickMultiImage(imageQuality: 85);
    if (picked.isNotEmpty) {
      setState(() {
        final newFiles = picked.map((x) => File(x.path)).toList();
        for (final file in newFiles) {
          if (_allImages.length < 6) {
            _allImages.add(_ImageItem(file: file, isCover: false));
          }
        }
        if (_allImages.length > 6) {
          _allImages.removeRange(6, _allImages.length);
        }
      });
    }
  }

  void _setCover(int index) {
    if (index >= 0 && index < _allImages.length) {
      setState(() {
        _coverIndex = index;
      });
    }
  }

  void _removeImage(int index) {
    // Ensure at least 1 image remains
    if (_allImages.length <= 1) {
      ShowMessage.notify(context, 'At least 1 image is required');
      return;
    }
    
    setState(() {
      _allImages.removeAt(index);
      // Adjust cover index if needed
      if (_coverIndex >= _allImages.length) {
        _coverIndex = 0;
      } else if (_coverIndex > index) {
        _coverIndex--;
      }
    });
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) {
      ShowMessage.notify(context, 'Please enter title');
      return;
    }
    
    // Ensure at least 1 image
    if (_allImages.isEmpty) {
      ShowMessage.notify(context, 'At least 1 image is required');
      return;
    }
    
    setState(() => _isSaving = true);
    try {
      final userId = Get.find<UserController>().userProfile.value.data?.id ?? '';
      
      // Collect all File images (only new files can be sent to backend)
      final List<File> allImageFiles = [];
      for (final img in _allImages) {
        if (img.file != null) {
          allImageFiles.add(img.file!);
        }
      }
      
      // If we have existing images but no new File images, we can't update images
      // For now, require at least one File image to update
      if (allImageFiles.isEmpty) {
        ShowMessage.notify(context, 'Please add at least one new image to update the product images');
        setState(() => _isSaving = false);
        return;
      }
      
      // Get cover image (the one at _coverIndex, or first if index is out of bounds)
      final File coverFile = _coverIndex < allImageFiles.length 
          ? allImageFiles[_coverIndex] 
          : allImageFiles[0];
      
      final body = <String, dynamic>{
        'category': _category ?? widget.product.category ?? '',
        'title': _title.text.trim(),
        'min_price': double.tryParse(_minPrice.text.trim()) ?? 0,
        'max_price': double.tryParse(_maxPrice.text.trim()) ?? 0,
        'product_condition': _condition,
        'image': coverFile,
        'images': allImageFiles,
      };
      
      final ApiResponse resp = await ProductService.instance.addSingleProduct(context, body, userId);
      if (resp.status == Status.COMPLETED) {
        ShowMessage.notify(context, 'Product updated');
        Navigator.pop(context, true);
      } else {
        ShowMessage.notify(context, 'Update failed');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = GeneralService.instance.allCategory.value.data?.map((e) => e.name).whereType<String>().toList() ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('Edit product')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Images section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Images (1-6)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  TextButton.icon(
                    onPressed: _allImages.length < 6 ? _pickImages : null,
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Image grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: _allImages.length,
                itemBuilder: (context, index) {
                  final img = _allImages[index];
                  final isCover = index == _coverIndex;
                  
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _setCover(index),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isCover ? AppColors.primaryColor : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: img.isNew && img.file != null
                                ? Image.file(img.file!, fit: BoxFit.cover)
                                : _buildProductImage(img.url, width: double.infinity, height: double.infinity),
                          ),
                        ),
                      ),
                      // Cover badge
                      if (isCover)
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Cover',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      // Remove button
                      Positioned(
                        right: 4,
                        top: 4,
                        child: InkWell(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      // Tap to set cover hint (if not cover)
                      if (!isCover)
                        Positioned(
                          bottom: 4,
                          left: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Tap to set cover',
                              style: TextStyle(color: Colors.white, fontSize: 9),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              if (_allImages.isEmpty)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.image_outlined, size: 48, color: AppColors.greyTextColor),
                        const SizedBox(height: 12),
                        const Text('No images', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _pickImages,
                          icon: const Icon(Icons.add_a_photo_outlined),
                          label: const Text('Add images'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _category,
            items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _category = v),
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _condition,
            items: const [
              DropdownMenuItem(value: 'New', child: Text('New')),
              DropdownMenuItem(value: 'Like New', child: Text('Like New')),
              DropdownMenuItem(value: 'Used - Good', child: Text('Used - Good')),
              DropdownMenuItem(value: 'Used - Fair', child: Text('Used - Fair')),
            ],
            onChanged: (v) => setState(() => _condition = v ?? 'New'),
            decoration: const InputDecoration(labelText: 'Condition'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextFormField(controller: _minPrice, decoration: const InputDecoration(labelText: 'Min price'), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly])),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(controller: _maxPrice, decoration: const InputDecoration(labelText: 'Max price'), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly])),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving 
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                : const Text('Save changes'),
          ),
        ],
      ),
    );
  }
}
