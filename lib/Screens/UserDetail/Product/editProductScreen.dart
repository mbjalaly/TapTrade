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
  File? _newCover;
  final List<File> _extras = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _title.text = widget.product.title ?? '';
    _category = widget.product.category;
    _condition = widget.product.productCondition?.isNotEmpty == true ? widget.product.productCondition! : 'New';
    _minPrice.text = widget.product.minPrice ?? '0';
    _maxPrice.text = widget.product.maxPrice ?? '0';
  }

  @override
  void dispose() {
    _title.dispose();
    _minPrice.dispose();
    _maxPrice.dispose();
    super.dispose();
  }

  Future<void> _pickNewCover() async {
    final XFile? f = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (f != null) setState(() => _newCover = File(f.path));
  }

  Future<void> _pickExtraImages() async {
    final List<XFile> picked = await ImagePicker().pickMultiImage(imageQuality: 85);
    if (picked.isNotEmpty) {
      setState(() {
        _extras.addAll(picked.map((x) => File(x.path)));
        if (_extras.length > 6) {
          _extras.removeRange(6, _extras.length);
        }
      });
    }
  }

  void _manageExtras() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Additional photos (2–6)', style: TextStyle(fontWeight: FontWeight.w700)),
                    TextButton.icon(onPressed: _pickExtraImages, icon: const Icon(Icons.add_a_photo_outlined), label: const Text('Add')),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (int i = 0; i < _extras.length; i++)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_extras[i], height: 80, width: 80, fit: BoxFit.cover),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: InkWell(
                              onTap: () {
                                if (_extras.length <= 2) {
                                  ShowMessage.notify(context, 'At least 2 additional photos required');
                                  return;
                                }
                                setState(() => _extras.removeAt(i));
                              },
                              child: const CircleAvatar(radius: 12, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 14, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) {
      ShowMessage.notify(context, 'Please enter title');
      return;
    }
    setState(() => _isSaving = true);
    try {
      final userId = Get.find<UserController>().userProfile.value.data?.id ?? '';
      final body = <String, dynamic>{
        'category': _category ?? widget.product.category ?? '',
        'title': _title.text.trim(),
        'min_price': double.tryParse(_minPrice.text.trim()) ?? 0,
        'max_price': double.tryParse(_maxPrice.text.trim()) ?? 0,
        'product_condition': _condition,
      };
      // If backend supports updating with file via same endpoint, include 'image'
      if (_newCover != null) body['image'] = _newCover!;
      // Keep single cover image only as per backend limits

      // Using addSingleProduct as there is no explicit update endpoint provided.
      // Replace with a proper update API when available.
      // No extra photos upload
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
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _newCover != null
                    ? Image.file(_newCover!, height: 88, width: 88, fit: BoxFit.cover)
                    : Image.network(
                        (widget.product.image ?? '').isNotEmpty ? KeyConstants.imageUrl + (widget.product.image ?? '') : KeyConstants.imagePlaceHolder,
                        height: 88,
                        width: 88,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(onPressed: _pickNewCover, icon: const Icon(Icons.photo_outlined), label: const Text('Change cover')),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: _manageExtras,
                  child: Container(
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Stack(
                      children: [
                        if (_extras.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_extras.first, height: 88, width: double.infinity, fit: BoxFit.cover),
                          ),
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text('+${_extras.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        if (_extras.isEmpty)
                          const Center(child: Text('Add more photos', style: TextStyle(color: AppColors.primaryTextColor))),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _isSaving ? null : _save, child: _isSaving ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Save changes')),
        ],
      ),
    );
  }
}


