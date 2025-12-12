class LikeProductResponseModel {
  bool? success;
  String? message;
  List<LikeData>? data;

  LikeProductResponseModel({this.success, this.message, this.data});

  LikeProductResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    message = json['message'] ?? '';
    if (json['data'] != null) {
      data = <LikeData>[];
      json['data'].forEach((v) {
        data!.add(LikeData.fromJson(v));
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

class LikeData {
  LikeUser? user;
  LikeUser? nearbyUser;
  LikeUserProduct? userProduct;
  LikeUserProduct? otherProduct;
  String? feedback;
  bool? hasLike;
  bool? hasDislike;
  String? createdAt;

  LikeData(
      {this.user,
        this.nearbyUser,
        this.userProduct,
        this.otherProduct,
        this.feedback,
        this.hasLike,
        this.hasDislike,
        this.createdAt});

  LikeData.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? LikeUser.fromJson(json['user']) : null;
    nearbyUser = json['nearby_user'] != null
        ? LikeUser.fromJson(json['nearby_user'])
        : null;
    userProduct = json['user_product'] != null
        ? LikeUserProduct.fromJson(json['user_product'])
        : null;
    otherProduct = json['nearby_user_product'] != null
        ? LikeUserProduct.fromJson(json['nearby_user_product'])
        : null;
    feedback = json['feedback'] ?? '';
    hasLike = json['has_like'] ?? false;
    hasDislike = json['has_dislike'] ?? false;
    createdAt = json['created_at'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (nearbyUser != null) {
      data['nearby_user'] = nearbyUser!.toJson();
    }
    if (userProduct != null) {
      data['user_product'] = userProduct!.toJson();
    }
    if (otherProduct != null) {
      data['nearby_user_product'] = otherProduct!.toJson();
    }
    data['feedback'] = feedback ?? '';
    data['has_like'] = hasLike ?? false;
    data['has_dislike'] = hasDislike ?? false;
    data['created_at'] = createdAt ?? '';
    return data;
  }
}

class LikeUser {
  String? id;
  String? email;
  String? contact;
  String? fullName;
  String? username;
  String? userType;
  bool? isActive;
  bool? isAdmin;
  String? createdAt;
  String? updatedAt;
  String? image;
  bool? isRegistered;
  bool? isDeleted;
  String? address;
  String? longitude;
  String? latitude;
  String? dob;
  String? gender;
  bool? isProfileCompleted;

  LikeUser(
      {this.id,
        this.email,
        this.contact,
        this.fullName,
        this.username,
        this.userType,
        this.isActive,
        this.isAdmin,
        this.createdAt,
        this.updatedAt,
        this.image,
        this.isRegistered,
        this.isDeleted,
        this.address,
        this.longitude,
        this.latitude,
        this.dob,
        this.gender,
        this.isProfileCompleted});

  LikeUser.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    email = json['email'] ?? '';
    contact = json['contact'] ?? '';
    fullName = json['full_name'] ?? '';
    username = json['username'] ?? '';
    userType = json['user_type'] ?? '';
    isActive = json['is_active'] ?? false;
    isAdmin = json['is_admin'] ?? false;
    createdAt = json['created_at'] ?? '';
    updatedAt = json['updated_at'] ?? '';
    image = json['image'] ?? '';
    isRegistered = json['is_registered'] ?? false;
    isDeleted = json['is_deleted'] ?? false;
    address = json['address'] ?? '';
    longitude = json['longitude'] ?? '';
    latitude = json['latitude'] ?? '';
    dob = json['dob'] ?? '';
    gender = json['gender'] ?? '';
    isProfileCompleted = json['is_profile_completed'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id ?? '';
    data['email'] = email ?? '';
    data['contact'] = contact ?? '';
    data['full_name'] = fullName ?? '';
    data['username'] = username ?? '';
    data['user_type'] = userType ?? '';
    data['is_active'] = isActive ?? false;
    data['is_admin'] = isAdmin ?? false;
    data['created_at'] = createdAt ?? '';
    data['updated_at'] = updatedAt ?? '';
    data['image'] = image ?? '';
    data['is_registered'] = isRegistered ?? false;
    data['is_deleted'] = isDeleted ?? false;
    data['address'] = address ?? '';
    data['longitude'] = longitude ?? '';
    data['latitude'] = latitude ?? '';
    data['dob'] = dob ?? '';
    data['gender'] = gender ?? '';
    data['is_profile_completed'] = isProfileCompleted ?? false;
    return data;
  }
}

class LikeUserProduct {
  int? id;
  String? title;
  String? minPrice;
  String? maxPrice;
  String? image;
  String? productCondition;
  String? status;
  int? category;
  String? user;

  LikeUserProduct(
      {this.id,
        this.title,
        this.minPrice,
        this.maxPrice,
        this.image,
        this.productCondition,
        this.status,
        this.category,
        this.user});

  LikeUserProduct.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    title = json['title'] ?? '';
    minPrice = json['min_price'] ?? '';
    maxPrice = json['max_price'] ?? '';
    image = json['image'] ?? '';
    productCondition = json['product_condition'] ?? '';
    status = json['status'] ?? '';
    category = json['category'] ?? 0;
    user = json['user'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id ?? 0;
    data['title'] = title ?? '';
    data['min_price'] = minPrice ?? '';
    data['max_price'] = maxPrice ?? '';
    data['image'] = image ?? '';
    data['product_condition'] = productCondition ?? '';
    data['status'] = status ?? '';
    data['category'] = category ?? 0;
    data['user'] = user ?? '';
    return data;
  }
}

