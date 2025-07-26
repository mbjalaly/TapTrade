// class ProductModel {
//   String? image;
//   String? category;
//   String? title;
//   double? minPrice;
//   double? maxPrice;
//
//   ProductModel({this.image, this.category, this.title, this.minPrice, this.maxPrice});
//
//   ProductModel.fromJson(Map<String, dynamic> json) {
//     image = json['image'] ?? '';
//     category = json['category'] ?? '';
//     title = json['title'] ?? '';
//     minPrice = json['minPrice'] ?? 0.0;
//     maxPrice = json['maxPrice'] ?? 0.0;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['image'] = image ?? '';
//     data['category'] = category ?? '';
//     data['title'] = title ?? '';
//     data['minPrice'] = minPrice ?? 0.0;
//     data['maxPrice'] = maxPrice ?? 0.0;
//     return data;
//   }
//
//   // Method to check if model has non-empty fields
//   bool hasNonEmptyFields() {
//     return (image != null && image!.trim().isNotEmpty) &&
//         (category != null && category!.trim().isNotEmpty) &&
//         (title != null && title!.trim().isNotEmpty) &&
//         (minPrice != null && minPrice! > 0.0) &&
//         (maxPrice != null && maxPrice! > 0.0);
//   }
// }

class ProductModel {
  String? category;
  String? title;
  double? minPrice;
  double? maxPrice;
  String? image;
  String? productCondition;
  String? user;

  ProductModel(
      {this.category,
        this.title,
        this.minPrice,
        this.maxPrice,
        this.image,
        this.productCondition,
        this.user});

  ProductModel.fromJson(Map<String, dynamic> json) {
    category = json['category'] ?? '';
    title = json['title'] ?? '';
    minPrice = double.tryParse((json['min_price'] ?? 0.0).toString());
    maxPrice = double.tryParse((json['max_price'] ?? 0.0).toString());
    image = json['image'] ?? '';
    productCondition = json['product_condition'] ?? '';
    user = json['user'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['category'] = category ?? '';
    data['title'] = title ?? '';
    data['min_price'] = double.tryParse((minPrice ?? 0.0).toString());
    data['max_price'] = double.tryParse((maxPrice ?? 0.0).toString());
    data['image'] = image ?? '';
    data['product_condition'] = productCondition ?? '';
    data['user'] = user ?? '';
    return data;
  }
  bool hasNonEmptyFields() {
    return (image != null && image!.trim().isNotEmpty) &&
        (category != null && category!.trim().isNotEmpty) &&
        (title != null && title!.trim().isNotEmpty) &&
        (minPrice != null && minPrice! >= 0.0) &&
        (maxPrice != null && maxPrice! >= 0.0) &&
        (productCondition != null && productCondition!.trim().isNotEmpty) &&
        (user != null && user!.trim().isNotEmpty);
  }
}
