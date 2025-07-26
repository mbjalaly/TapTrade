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
  String? minPrice;
  String? maxPrice;
  String? image;
  String? productCondition;
  String? status;

  Data({
    this.id,
    this.category,
    this.title,
    this.minPrice,
    this.maxPrice,
    this.image,
    this.productCondition,
    this.status,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    category = json['category'] ?? '';
    title = json['title'] ?? '';
    minPrice = json['min_price'] ?? '';
    maxPrice = json['max_price'] ?? '';
    image = json['image'] ?? '';
    productCondition = json['product_condition'] ?? '';
    status = json['status'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id ?? 0;
    data['category'] = category ?? '';
    data['title'] = title ?? '';
    data['min_price'] = minPrice ?? '';
    data['max_price'] = maxPrice ?? '';
    data['image'] = image ?? '';
    data['product_condition'] = productCondition ?? '';
    data['status'] = status ?? '';
    return data;
  }
}
