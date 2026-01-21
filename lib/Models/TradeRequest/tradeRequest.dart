class TradeRequestResponseModel {
  bool? success;
  String? message;
  List<TradeRequestData>? data;

  TradeRequestResponseModel({this.success, this.message, this.data});

  TradeRequestResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    message = json['message'] ?? '';
    if (json['data'] != null) {
      data = <TradeRequestData>[];
      json['data'].forEach((v) {
        data!.add(TradeRequestData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success ?? false;
    data['message'] = message ?? '';
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TradeRequestData {
  int? id;
  String? requester;
  String? receiver;
  TradeRequestUserProduct? userProduct;
  TradeRequestUserProduct? otherProduct;
  String? status;
  String? paymentStatus;
  String? createdAt;
  String? type;
  // Bilateral confirmation fields
  bool? completedByRequester;
  bool? completedByReceiver;
  String? requesterCompletedAt;
  String? receiverCompletedAt;

  TradeRequestData({
    this.id,
    this.requester,
    this.receiver,
    this.userProduct,
    this.otherProduct,
    this.status,
    this.createdAt,
    this.paymentStatus,
    this.type,
    this.completedByRequester,
    this.completedByReceiver,
    this.requesterCompletedAt,
    this.receiverCompletedAt,
  });

  TradeRequestData.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? -1;
    requester = json['requester'] ?? '';
    receiver = json['receiver'] ?? '';
    userProduct = json['user_product'] != null
        ? TradeRequestUserProduct.fromJson(json['user_product'])
        : null;
    otherProduct = json['other_product'] != null
        ? TradeRequestUserProduct.fromJson(json['other_product'])
        : null;
    status = json['status'] ?? '';
    paymentStatus = json['payment_status'] ?? '';
    createdAt = json['created_at'] ?? '';
    type = json['type'] ?? '';
    completedByRequester = json['completed_by_requester'] ?? false;
    completedByReceiver = json['completed_by_receiver'] ?? false;
    requesterCompletedAt = json['requester_completed_at'];
    receiverCompletedAt = json['receiver_completed_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id ?? -1;
    data['requester'] = requester ?? '';
    data['receiver'] = receiver ?? '';
    if (userProduct != null) {
      data['user_product'] = userProduct!.toJson();
    }
    if (otherProduct != null) {
      data['other_product'] = otherProduct!.toJson();
    }
    data['payment_status'] = paymentStatus ?? '';
    data['status'] = status ?? '';
    data['created_at'] = createdAt ?? '';
    data['type'] = type ?? '';
    data['completed_by_requester'] = completedByRequester ?? false;
    data['completed_by_receiver'] = completedByReceiver ?? false;
    data['requester_completed_at'] = requesterCompletedAt;
    data['receiver_completed_at'] = receiverCompletedAt;
    return data;
  }

  // Helper methods for bilateral confirmation
  bool get isCompleted => status == 'completed';
  bool get isPendingConfirmation => status == 'pending_confirmation';
  bool get canMarkComplete => status == 'accepted' || status == 'in_progress';
}

class TradeRequestUserProduct {
  int? id;
  String? title;
  String? minPrice;
  String? maxPrice;
  String? image;
  String? productCondition;
  String? status;
  int? category;
  String? user;

  TradeRequestUserProduct(
      {this.id,
        this.title,
        this.minPrice,
        this.maxPrice,
        this.image,
        this.productCondition,
        this.status,
        this.category,
        this.user});

  TradeRequestUserProduct.fromJson(Map<String, dynamic> json) {
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