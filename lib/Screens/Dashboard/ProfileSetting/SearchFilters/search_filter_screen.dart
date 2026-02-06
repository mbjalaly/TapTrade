import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taptrade/Controller/productController.dart';
import 'package:taptrade/Controller/userController.dart';
import 'package:taptrade/Services/IntegrationServices/generalService.dart';
import 'package:taptrade/Services/SearchFilterService/search_filter_service.dart';
import 'package:taptrade/Utills/appColors.dart';
import 'package:taptrade/Widgets/customText.dart';
import 'package:taptrade/l10n/app_localizations.dart';

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
        backgroundColor: AppColors.backgroundColor(context),
        elevation: 0,
        title: AppText(
          text: AppLocalizations.of(context)?.searchFilters ?? 'Search Filters',
          textcolor: AppColors.primaryText(context),
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: AppColors.primaryText(context)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _loading ? null : _saveAndClose,
            child: Text(AppLocalizations.of(context)?.save ?? 'Save', style: TextStyle(color: AppColors.primaryText(context), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppColors.primaryText(context)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: AppLocalizations.of(context)?.filterByMyProducts ?? 'Filter by My Products (multiple)',
                    textcolor: AppColors.primaryText(context),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: myProducts.map((p) {
                      final id = p.id ?? 0;
                      final selected = _selectedMyProductIds.contains(id);
                      final productLabel = (AppLocalizations.of(context)?.productNumber ?? 'Product #').toString();
                      final title = (p.title ?? '').isEmpty ? productLabel.replaceAll('{id}', '$id') : p.title!;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selected) {
                              _selectedMyProductIds.remove(id);
                            } else {
                              _selectedMyProductIds.add(id);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.darkBlue
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: selected
                                  ? AppColors.darkBlue
                                  : AppColors.greyText(context).withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                              color: selected ? Colors.white : AppColors.darkBlue,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  AppText(
                    text: AppLocalizations.of(context)?.onlyShowMatchesForOne ?? 'Only show matches for one product',
                    textcolor: AppColors.primaryText(context),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int?> (
                    value: _singleSelectedProductId,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    hint: Text(AppLocalizations.of(context)?.selectOneOfMyProducts ?? 'Select one of my products (optional)'),
                    items: [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text(AppLocalizations.of(context)?.allMyProducts ?? 'All my products'),
                      ),
                      ...myProducts.map((p) {
                        final label = (AppLocalizations.of(context)?.productNumber ?? 'Product #').toString();
                        final displayTitle = (p.title ?? '').isEmpty ? label.replaceAll('{id}', '${p.id}') : p.title!;
                        return DropdownMenuItem<int?>(
                          value: p.id ?? 0,
                          child: Text(displayTitle),
                        );
                      }),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _singleSelectedProductId = val;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  AppText(
                    text: AppLocalizations.of(context)?.categories ?? 'Categories',
                    textcolor: AppColors.primaryText(context),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: categories.map((c) {
                      final id = c.id ?? 0;
                      final selected = _selectedCategoryIds.contains(id);
                      final name = (c.name ?? '').toString().capitalize ?? '';
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selected) {
                              _selectedCategoryIds.remove(id);
                            } else {
                              _selectedCategoryIds.add(id);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.darkBlue
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: selected
                                  ? AppColors.darkBlue
                                  : AppColors.greyText(context).withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                              color: selected ? Colors.white : AppColors.darkBlue,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  AppText(
                    text: AppLocalizations.of(context)?.interests ?? 'Interests',
                    textcolor: AppColors.primaryText(context),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: interests.map((i) {
                      final name = (i.name ?? '').toString();
                      final selected = _selectedInterests.contains(name);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selected) {
                              _selectedInterests.remove(name);
                            } else {
                              _selectedInterests.add(name);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.darkBlue
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: selected
                                  ? AppColors.darkBlue
                                  : AppColors.greyText(context).withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            name.capitalize ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                              color: selected ? Colors.white : AppColors.darkBlue,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        text: AppLocalizations.of(context)?.radiusKm ?? 'Radius (km)',
                        textcolor: AppColors.primaryText(context),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                      Text(_radiusKm?.toStringAsFixed(0) ?? (AppLocalizations.of(context)?.defaultText ?? 'Default'), style: TextStyle(color: AppColors.primaryText(context))),
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
                          child: Text(AppLocalizations.of(context)?.clearFilters ?? 'Clear filters'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _loading ? null : _saveAndClose,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryText(context), foregroundColor: Colors.white),
                          child: Text(AppLocalizations.of(context)?.apply ?? 'Apply'),
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


