import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Controller/productController.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/Services/IntegrationServices/generalService.dart';
import 'package:taptrade/Services/SearchFilterService/search_filter_service.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Widgets/customText.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({Key? key}) : super(key: key);

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final productController = Get.find<ProductController>();
  final userController = Get.find<UserController>();

  final Set<int> _selectedMyProductIds = <int>{};
  int? _singleSelectedProductId;
  final Set<int> _selectedCategoryIds = <int>{};
  final Set<String> _selectedInterests = <String>{};
  double? _radiusKm;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() { _loading = true; });
    // Ensure data sources are present
    if ((GeneralService.instance.allCategory.value.data ?? []).isEmpty) {
      await GeneralService.instance.getAllCategories(context);
    }
    if ((GeneralService.instance.allInterest.value.data ?? []).isEmpty) {
      await GeneralService.instance.getAllInterests(context);
    }
    final filters = await SearchFilterService.instance.loadFilters();
    _selectedMyProductIds.addAll(filters.myProductIds);
    _selectedCategoryIds.addAll(filters.categoryIds);
    _selectedInterests.addAll(filters.interestNames);
    _radiusKm = filters.radiusKm;
    _singleSelectedProductId = filters.selectedMyProductId;
    setState(() { _loading = false; });
  }

  Future<void> _saveAndClose() async {
    setState(() { _loading = true; });
    await SearchFilterService.instance.saveFilters(SearchFilters(
      myProductIds: _selectedMyProductIds.toList(),
      categoryIds: _selectedCategoryIds.toList(),
      interestNames: _selectedInterests.toList(),
      radiusKm: _radiusKm,
      selectedMyProductId: _singleSelectedProductId,
    ));
    setState(() { _loading = false; });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final myProducts = productController.myProduct.value.data ?? [];
    final categories = GeneralService.instance.allCategory.value.data ?? [];
    final interests = GeneralService.instance.allInterest.value.data ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: AppText(
          text: 'Search Filters',
          textcolor: AppColors.primaryTextColor,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _loading ? null : _saveAndClose,
            child: const Text('Save', style: TextStyle(color: AppColors.primaryTextColor, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppColors.primaryTextColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: 'Filter by My Products (multiple)',
                    textcolor: AppColors.primaryTextColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: myProducts.map((p) {
                      final id = p.id ?? 0;
                      final selected = _selectedMyProductIds.contains(id);
                      return FilterChip(
                        label: Text((p.title ?? '').isEmpty ? 'Product #$id' : p.title!),
                        selected: selected,
                        onSelected: (v) {
                          setState(() {
                            if (v) {
                              _selectedMyProductIds.add(id);
                            } else {
                              _selectedMyProductIds.remove(id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  AppText(
                    text: 'Only show matches for one product',
                    textcolor: AppColors.primaryTextColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int?> (
                    value: _singleSelectedProductId,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    hint: const Text('Select one of my products (optional)'),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('All my products'),
                      ),
                      ...myProducts.map((p) => DropdownMenuItem<int?>(
                        value: p.id ?? 0,
                        child: Text((p.title ?? '').isEmpty ? 'Product #${p.id}' : p.title!),
                      )),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _singleSelectedProductId = val;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  AppText(
                    text: 'Categories',
                    textcolor: AppColors.primaryTextColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((c) {
                      final id = c.id ?? 0;
                      final selected = _selectedCategoryIds.contains(id);
                      return FilterChip(
                        label: Text((c.name ?? '').toString().capitalize ?? ''),
                        selected: selected,
                        onSelected: (v) {
                          setState(() {
                            if (v) {
                              _selectedCategoryIds.add(id);
                            } else {
                              _selectedCategoryIds.remove(id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  AppText(
                    text: 'Interests',
                    textcolor: AppColors.primaryTextColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: interests.map((i) {
                      final name = (i.name ?? '').toString();
                      final selected = _selectedInterests.contains(name);
                      return FilterChip(
                        label: Text(name.capitalize ?? ''),
                        selected: selected,
                        onSelected: (v) {
                          setState(() {
                            if (v) {
                              _selectedInterests.add(name);
                            } else {
                              _selectedInterests.remove(name);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        text: 'Radius (km)',
                        textcolor: AppColors.primaryTextColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                      Text(_radiusKm?.toStringAsFixed(0) ?? 'Default', style: const TextStyle(color: AppColors.primaryTextColor)),
                    ],
                  ),
                  Slider(
                    value: (_radiusKm ?? 0) > 0 ? _radiusKm!.clamp(0, 500) : 0,
                    min: 0,
                    max: 500,
                    divisions: 100,
                    onChanged: (v) {
                      setState(() {
                        _radiusKm = v == 0 ? null : v;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            await SearchFilterService.instance.clearFilters();
                            setState(() {
                              _selectedMyProductIds.clear();
                              _selectedCategoryIds.clear();
                              _selectedInterests.clear();
                              _radiusKm = null;
                            });
                          },
                          child: const Text('Clear filters'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _loading ? null : _saveAndClose,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTextColor, foregroundColor: Colors.white),
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}


