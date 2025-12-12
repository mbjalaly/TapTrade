class TradeResponseModel {
  bool? success;
  String? message;
  TradeData? data;

  TradeResponseModel({this.success, this.message, this.data});

  TradeResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    message = json['message'] ?? '';
    data = json['data'] != null ? TradeData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['success'] = success ?? false;
    data['message'] = message ?? '';
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class TradeData {
  int? tradeRequest;  // Can handle both 'trade_request' and 'trade_request_id'
  Requester? requester;
  Requester? receiver;
  Product? userProduct;
  Product? otherProduct;
  String? status;  // Optional field, present in second response

  TradeData(
      {this.tradeRequest,
        this.requester,
        this.receiver,
        this.userProduct,
        this.otherProduct,
        this.status});

  TradeData.fromJson(Map<String, dynamic> json) {
    tradeRequest = json['trade_request'] ?? json['trade_request_id'];
    requester = json['requester'] != null ? Requester.fromJson(json['requester']) : null;
    receiver = json['receiver'] != null ? Requester.fromJson(json['receiver']) : null;
    userProduct = json['user_product'] != null ? Product.fromJson(json['user_product']) : null;
    otherProduct = json['other_product'] != null ? Product.fromJson(json['other_product']) : null;
    status = json['status'];  // Optional field
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['trade_request'] = tradeRequest;
    if (requester != null) {
      data['requester'] = requester!.toJson();
    }
    if (receiver != null) {
      data['receiver'] = receiver!.toJson();
    }
    if (userProduct != null) {
      data['user_product'] = userProduct!.toJson();
    }
    if (otherProduct != null) {
      data['other_product'] = otherProduct!.toJson();
    }
    if (status != null) {
      data['status'] = status;
    }
    return data;
  }
}

class Requester {
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

  Requester({
    this.id,
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
    this.isProfileCompleted,
  });

  Requester.fromJson(Map<String, dynamic> json) {
    id = json['id'];
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
    final Map<String, dynamic> data = {};
    data['id'] = id;
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

class Product {
  int? id;
  String? title;
  String? minPrice;
  String? maxPrice;
  String? image;
  String? productCondition;
  String? status;
  int? category;
  String? user;

  Product({
    this.id,
    this.title,
    this.minPrice,
    this.maxPrice,
    this.image,
    this.productCondition,
    this.status,
    this.category,
    this.user,
  });

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
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
    final Map<String, dynamic> data = {};
    data['id'] = id;
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
