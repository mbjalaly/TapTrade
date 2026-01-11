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
        const MAX_IMAGES = 4; // Maximum 4 images allowed
        for (final file in newFiles) {
          if (_allImages.length < MAX_IMAGES) {
            _allImages.add(_ImageItem(file: file, isCover: false));
          }
        }
        if (_allImages.length > MAX_IMAGES) {
          _allImages.removeRange(MAX_IMAGES, _allImages.length);
          ShowMessage.notify(context, 'Maximum ${MAX_IMAGES} images allowed');
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
    
    // Ensure at least 1 image exists (existing or new)
    if (_allImages.isEmpty) {
      ShowMessage.notify(context, 'At least 1 image is required');
      return;
    }
    
    setState(() => _isSaving = true);
    try {
      final productId = widget.product.id?.toString() ?? '';
      if (productId.isEmpty) {
        ShowMessage.notify(context, 'Product ID is missing');
        setState(() => _isSaving = false);
        return;
      }
      
      // Separate new File images from existing URLs
      final List<File> newImageFiles = [];
      final List<String> existingImageUrls = [];
      
      for (final img in _allImages) {
        if (img.file != null) {
          newImageFiles.add(img.file!);
        } else if (img.url != null && img.url!.isNotEmpty) {
          existingImageUrls.add(img.url!);
        }
      }
      
      // Validate prices
      final minPrice = double.tryParse(_minPrice.text.trim()) ?? 0;
      final maxPrice = double.tryParse(_maxPrice.text.trim()) ?? 0;
      
      if (minPrice >= maxPrice) {
        ShowMessage.notify(context, 'Minimum price must be less than maximum price');
        setState(() => _isSaving = false);
        return;
      }
      
      final body = <String, dynamic>{
        'category': _category ?? widget.product.category ?? '',
        'title': _title.text.trim(),
        'min_price': minPrice,
        'max_price': maxPrice,
        'product_condition': _condition,
      };
      
      // Handle images: combine existing URLs with new Files (max 4 total)
      const MAX_IMAGES = 4;
      if (newImageFiles.isNotEmpty || existingImageUrls.isNotEmpty) {
        // Ensure cover index is valid
        if (_coverIndex < 0 || _coverIndex >= _allImages.length) {
          _coverIndex = 0;
        }
        
        // Get cover image
        final coverImg = _allImages[_coverIndex];
        File? coverFile;
        String? coverUrl;
        
        if (coverImg.file != null) {
          coverFile = coverImg.file;
        } else if (coverImg.url != null && coverImg.url!.isNotEmpty) {
          coverUrl = coverImg.url;
        }
        
        // Build ordered lists with cover first
        final List<File> orderedNewFiles = [];
        final List<String> orderedExistingUrls = [];
        
        // Add cover first if it's a new file
        if (coverFile != null) {
          orderedNewFiles.add(coverFile);
        } else if (coverUrl != null) {
          orderedExistingUrls.add(coverUrl);
        }
        
        // Add remaining images (excluding cover)
        for (int i = 0; i < _allImages.length; i++) {
          if (i == _coverIndex) continue; // Skip cover (already added)
          
          final img = _allImages[i];
          if ((orderedNewFiles.length + orderedExistingUrls.length) >= MAX_IMAGES) break;
          
          if (img.file != null) {
            orderedNewFiles.add(img.file!);
          } else if (img.url != null && img.url!.isNotEmpty) {
            orderedExistingUrls.add(img.url!);
          }
        }
        
        // Set the cover/primary image
        // Backend expects 'image' field to be a File (not a string URL)
        // For existing images, backend uses the first item in 'existing_images' as primary
        if (coverFile != null) {
          // Cover is a new file - send it as the primary image
          body['image'] = coverFile; // Will be sent as multipart file with fieldname 'image'
        }
        // If cover is an existing URL (coverUrl != null but coverFile == null),
        // we don't send it in 'image' field. Instead, it's already first in orderedExistingUrls
        // and the backend will use it as primary when processing existing_images
        
        // Send new files (cover is already first in the list if it's a new file)
        if (orderedNewFiles.isNotEmpty) {
          body['images'] = orderedNewFiles;
        }
        
        // Send existing image URLs (cover is already first in the list)
        // Backend uses first image in existing_images as primary when no new 'image' file is provided
        if (orderedExistingUrls.isNotEmpty) {
          body['existing_images'] = orderedExistingUrls;
        }
      }
      
      // Use updateProduct instead of addSingleProduct
      final ApiResponse resp = await ProductService.instance.updateProduct(context, body, productId);
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
                  const Text('Images (1-4)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  TextButton.icon(
                    onPressed: _allImages.length < 4 ? _pickImages : null,
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
