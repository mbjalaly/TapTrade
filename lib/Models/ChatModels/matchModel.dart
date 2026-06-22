/// Model representing a confirmed mutual match between two users
class MatchModel {
  int? id;
  String? user1Id;
  String? user2Id;
  int? user1ProductId;
  int? user2ProductId;
  DateTime? matchedAt;
  DateTime? lastMessageAt;
  String? status;
  int? user1UnreadCount;
  int? user2UnreadCount;
  int? tradeRequestId;
  String? tradeRequestStatus;

  // Enriched data from API
  MatchProductInfo? myProduct;
  MatchProductInfo? theirProduct;
  MatchUserInfo? otherUser;
  String? lastMessage;

  MatchModel({
    this.id,
    this.user1Id,
    this.user2Id,
    this.user1ProductId,
    this.user2ProductId,
    this.matchedAt,
    this.lastMessageAt,
    this.status,
    this.user1UnreadCount,
    this.user2UnreadCount,
    this.tradeRequestId,
    this.tradeRequestStatus,
    this.myProduct,
    this.theirProduct,
    this.otherUser,
    this.lastMessage,
  });

  MatchModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user1Id = json['user1_id'];
    user2Id = json['user2_id'];
    user1ProductId = json['user1_product_id'];
    user2ProductId = json['user2_product_id'];
    matchedAt = json['matched_at'] != null
        ? DateTime.tryParse(json['matched_at'])
        : null;
    lastMessageAt = json['last_message_at'] != null
        ? DateTime.tryParse(json['last_message_at'])
        : null;
    status = json['status'] ?? 'active';
    user1UnreadCount = json['user1_unread_count'] ?? 0;
    user2UnreadCount = json['user2_unread_count'] ?? 0;
    tradeRequestId = json['trade_request_id'];
    tradeRequestStatus = json['trade_request_status'];

    // Enriched data
    if (json['my_product'] != null) {
      myProduct = MatchProductInfo.fromJson(json['my_product']);
    }
    if (json['their_product'] != null) {
      theirProduct = MatchProductInfo.fromJson(json['their_product']);
    }
    if (json['other_user'] != null) {
      otherUser = MatchUserInfo.fromJson(json['other_user']);
    }
    lastMessage = json['last_message'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user1_id': user1Id,
      'user2_id': user2Id,
      'user1_product_id': user1ProductId,
      'user2_product_id': user2ProductId,
      'matched_at': matchedAt?.toIso8601String(),
      'last_message_at': lastMessageAt?.toIso8601String(),
      'status': status,
      'user1_unread_count': user1UnreadCount,
      'user2_unread_count': user2UnreadCount,
      'trade_request_id': tradeRequestId,
      'trade_request_status': tradeRequestStatus,
      'my_product': myProduct?.toJson(),
      'their_product': theirProduct?.toJson(),
      'other_user': otherUser?.toJson(),
      'last_message': lastMessage,
    };
  }

  /// Parse from the get matches API response format
  factory MatchModel.fromApiResponse(Map<String, dynamic> json) {
    return MatchModel(
      id: json['match_id'],
      user1Id: json['user1_id'],
      user2Id: json['user2_id'],
      matchedAt: json['matched_at'] != null
          ? DateTime.tryParse(json['matched_at'])
          : null,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.tryParse(json['last_message_at'])
          : null,
      status: json['status'] ?? 'active',
      user1UnreadCount: json['unread_count'] ?? 0,
      user2UnreadCount: 0,
      tradeRequestId: json['trade_request_id'],
      tradeRequestStatus: json['trade_request_status'],
      myProduct: json['my_product'] != null
          ? MatchProductInfo.fromJson(json['my_product'])
          : null,
      theirProduct: json['other_product'] != null
          ? MatchProductInfo.fromJson(json['other_product'])
          : null,
      otherUser: json['other_user'] != null
          ? MatchUserInfo.fromJson(json['other_user'])
          : null,
      lastMessage: json['last_message'],
    );
  }

  /// Get unread count for the current user
  int getUnreadCount(String currentUserId) {
    if (currentUserId == user1Id) {
      return user1UnreadCount ?? 0;
    } else {
      return user2UnreadCount ?? 0;
    }
  }
}

/// Product info for match display
class MatchProductInfo {
  int? id;
  String? title;
  String? image;
  String? minPrice;
  String? maxPrice;
  String? productCondition;

  MatchProductInfo({
    this.id,
    this.title,
    this.image,
    this.minPrice,
    this.maxPrice,
    this.productCondition,
  });

  MatchProductInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'] ?? '';
    image = json['image'] ?? '';
    minPrice = json['min_price']?.toString() ?? '';
    maxPrice = json['max_price']?.toString() ?? '';
    productCondition = json['product_condition'] ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'min_price': minPrice,
      'max_price': maxPrice,
      'product_condition': productCondition,
    };
  }
}

/// User info for match display (privacy-focused - only shows name after match)
class MatchUserInfo {
  String? id;
  String? username;

  MatchUserInfo({
    this.id,
    this.username,
  });

  MatchUserInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    username = json['username'] ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
    };
  }
}

/// Response model for matches list API
class MatchesResponseModel {
  bool? success;
  String? message;
  List<MatchModel>? matches;

  MatchesResponseModel({
    this.success,
    this.message,
    this.matches,
  });

  MatchesResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    message = json['message'] ?? '';
    // API returns data array with transformed match objects
    if (json['data'] != null) {
      matches = <MatchModel>[];
      json['data'].forEach((v) {
        matches!.add(MatchModel.fromApiResponse(v));
      });
    } else if (json['matches'] != null) {
      matches = <MatchModel>[];
      json['matches'].forEach((v) {
        matches!.add(MatchModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'matches': matches?.map((v) => v.toJson()).toList(),
    };
  }
}

/// Response model for create match API (when mutual match detected)
class CreateMatchResponseModel {
  bool? success;
  String? message;
  bool? isMatch;
  MatchModel? match;

  CreateMatchResponseModel({
    this.success,
    this.message,
    this.isMatch,
    this.match,
  });

  CreateMatchResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    message = json['message'] ?? '';
    isMatch = json['is_match'] ?? false;
    if (json['match'] != null) {
      match = MatchModel.fromJson(json['match']);
    }
  }
}
