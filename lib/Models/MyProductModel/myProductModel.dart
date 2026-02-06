class MyProductResponseModel {
  bool? success;
  String? message;
  List<Data>? data;

  MyProductResponseModel({this.success, this.message, this.data});

  MyProductResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    message = json['message'] ?? '';
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    } else {
      data = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success ?? false;
    data['message'] = message ?? '';
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    } else {
      data['data'] = [];
    }
    return data;
  }
}

class Data {
  int? id;
  String? category;
  String? title;
  String? description;
  String? minPrice;
  String? maxPrice;
  int? quantity;
  String? image;
  List<String>? images;
  String? productCondition;
  String? status;

  Data({
    this.id,
    this.category,
    this.title,
    this.description,
    this.minPrice,
    this.maxPrice,
    this.quantity,
    this.image,
    this.images,
    this.productCondition,
    this.status,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    category = json['category'] ?? '';
    title = json['title'] ?? '';
    description = json['description'] ?? '';
    // Handle both int and string for prices (backend may send either)
    final minPriceValue = json['min_price'];
    minPrice = minPriceValue != null ? minPriceValue.toString() : '';
    final maxPriceValue = json['max_price'];
    maxPrice = maxPriceValue != null ? maxPriceValue.toString() : '';
    quantity = json['quantity'] is int ? json['quantity'] : (int.tryParse(json['quantity']?.toString() ?? '1') ?? 1);
    image = json['image'] ?? '';
    if (json['images'] is List) {
      // Remove duplicates by converting to Set and back to List
      images = (json['images'] as List)
          .map((e) => e.toString())
          .toSet()
          .toList();
    } else {
      images = [];
    }
    productCondition = json['product_condition'] ?? '';
    status = json['status'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id ?? 0;
    data['category'] = category ?? '';
    data['title'] = title ?? '';
    data['description'] = description ?? '';
    data['min_price'] = minPrice ?? '';
    data['max_price'] = maxPrice ?? '';
    data['quantity'] = quantity ?? 1;
    data['image'] = image ?? '';
    if (images != null) {
      data['images'] = images;
    }
    data['product_condition'] = productCondition ?? '';
    data['status'] = status ?? '';
    return data;
  }
}
