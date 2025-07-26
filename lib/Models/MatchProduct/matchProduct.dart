
class MatchProductResponseModel {
  bool? success;
  String? message;
  List<MatchData>? data;

  MatchProductResponseModel({this.success, this.message, this.data});

  MatchProductResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    message = json['message'] ?? '';
    if (json['matching_products'] != null) {
      data = <MatchData>[];
      json['matching_products'].forEach((v) {
        data!.add(MatchData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success ?? false;
    data['message'] = message ?? '';
    if (this.data != null) {
      data['matching_products'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MatchData {
  UserProduct? userProduct;
  UserProduct? otherProduct;
  NearbyUser? nearbyUser;
  int? matchCount;

  MatchData(
      {this.userProduct, this.otherProduct, this.nearbyUser, this.matchCount});

  MatchData.fromJson(Map<String, dynamic> json) {
    userProduct = json['user_product'] != null
        ? UserProduct.fromJson(json['user_product'])
        : null;
    otherProduct = json['other_product'] != null
        ? UserProduct.fromJson(json['other_product'])
        : null;
    nearbyUser = json['nearby_user'] != null
        ? NearbyUser.fromJson(json['nearby_user'])
        : null;
    matchCount = json['matching_interest_count'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (userProduct != null) {
      data['user_product'] = userProduct!.toJson();
    }
    if (otherProduct != null) {
      data['other_product'] = otherProduct!.toJson();
    }
    if (nearbyUser != null) {
      data['nearby_user'] = nearbyUser!.toJson();
    }
    data['matching_interest_count'] = matchCount ?? 0;
    return data;
  }
}

class UserProduct {
  int? id;
  String? title;
  String? minPrice;
  String? maxPrice;
  String? image;
  String? productCondition;
  String? status;
  int? category;
  String? user;

  UserProduct(
      {this.id,
        this.title,
        this.minPrice,
        this.maxPrice,
        this.image,
        this.productCondition,
        this.status,
        this.category,
        this.user});

  UserProduct.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? -1;
    title = json['title'] ?? '';
    minPrice = json['min_price'] ?? '';
    maxPrice = json['max_price'] ?? '';
    image = json['image'] ?? '';
    productCondition = json['product_condition'] ?? '';
    status = json['status'] ?? '';
    category = json['category'] ?? -1;
    user = json['user'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id ?? -1;
    data['title'] = title ?? '';
    data['min_price'] = minPrice ?? '';
    data['max_price'] = maxPrice ?? '';
    data['image'] = image ?? '';
    data['product_condition'] = productCondition ?? '';
    data['status'] = status ?? '';
    data['category'] = category ?? -1;
    data['user'] = user ?? '';
    return data;
  }
}

class NearbyUser {
  String? id;
  String? username;
  double? latitude;
  double? longitude;
  String? tradeRadius;

  NearbyUser(
      {this.id,
        this.username,
        this.latitude,
        this.longitude,
        this.tradeRadius});

  NearbyUser.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    username = json['username'] ?? '';
    latitude = json['latitude'] ?? 0.0;
    longitude = json['longitude'] ?? 0.0;
    tradeRadius = json['trade_radius'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id ?? '';
    data['username'] = username ?? '';
    data['latitude'] = latitude ?? 0.0;
    data['longitude'] = longitude ?? 0.0;
    data['trade_radius'] = tradeRadius ?? '';
    return data;
  }
}
