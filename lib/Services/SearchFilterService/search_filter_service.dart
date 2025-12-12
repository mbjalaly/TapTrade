import 'dart:convert';

import 'package:taptrade/Services/SharedPreferenceService/sharePreferenceService.dart';

class SearchFilters {
  final List<int> myProductIds;
  final List<int> categoryIds;
  final List<String> interestNames;
  final double? radiusKm;
  final int? selectedMyProductId; // if set, only show matches for this product

  SearchFilters({
    this.myProductIds = const [],
    this.categoryIds = const [],
    this.interestNames = const [],
    this.radiusKm,
    this.selectedMyProductId,
  });

  Map<String, dynamic> toJson() => {
        'myProductIds': myProductIds,
        'categoryIds': categoryIds,
        'interestNames': interestNames,
        'radiusKm': radiusKm,
        'selectedMyProductId': selectedMyProductId,
      };

  static SearchFilters fromJsonString(String? value) {
    if (value == null || value.isEmpty) return SearchFilters();
    try {
      final Map<String, dynamic> map = json.decode(value);
      return SearchFilters(
        myProductIds: (map['myProductIds'] as List?)?.map((e) => int.tryParse(e.toString()) ?? 0).where((e) => e > 0).toList() ?? const [],
        categoryIds: (map['categoryIds'] as List?)?.map((e) => int.tryParse(e.toString()) ?? 0).where((e) => e > 0).toList() ?? const [],
        interestNames: (map['interestNames'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        radiusKm: map['radiusKm'] == null ? null : double.tryParse(map['radiusKm'].toString()),
        selectedMyProductId: map['selectedMyProductId'] == null ? null : int.tryParse(map['selectedMyProductId'].toString()),
      );
    } catch (_) {
      return SearchFilters();
    }
  }
}

class SearchFilterService {
  SearchFilterService._internal();
  static final SearchFilterService instance = SearchFilterService._internal();

  static const String _key = 'search_filters_v1';

  Future<void> saveFilters(SearchFilters filters) async {
    await SharedPreferencesService().setString(_key, json.encode(filters.toJson()));
  }

  Future<SearchFilters> loadFilters() async {
    final String? value = await SharedPreferencesService().getString(_key);
    return SearchFilters.fromJsonString(value);
  }

  Future<void> clearFilters() async {
    await SharedPreferencesService().remove(_key);
  }
}


