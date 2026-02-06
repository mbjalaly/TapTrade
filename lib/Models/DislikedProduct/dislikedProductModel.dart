import 'package:taptrade/Models/ChatModels/matchModel.dart';

class DislikedProductModel {
  int? id;
  MatchProductInfo? userProduct;
  MatchProductInfo? otherProduct;
  MatchUserInfo? otherUser;
  String? dislikedAt;
  bool? canReSwipe;
  int? timeUntilAvailable; // milliseconds

  DislikedProductModel({
    this.id,
    this.userProduct,
    this.otherProduct,
    this.otherUser,
    this.dislikedAt,
    this.canReSwipe,
    this.timeUntilAvailable,
  });

  DislikedProductModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userProduct = json['user_product'] != null
        ? MatchProductInfo.fromJson(json['user_product'])
        : null;
    otherProduct = json['other_product'] != null
        ? MatchProductInfo.fromJson(json['other_product'])
        : null;
    otherUser = json['other_user'] != null
        ? MatchUserInfo.fromJson(json['other_user'])
        : null;
    dislikedAt = json['disliked_at'];
    canReSwipe = json['can_re_swipe'];
    timeUntilAvailable = json['time_until_available'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (userProduct != null) {
      data['user_product'] = userProduct!.toJson();
    }
    if (otherProduct != null) {
      data['other_product'] = otherProduct!.toJson();
    }
    if (otherUser != null) {
      data['other_user'] = otherUser!.toJson();
    }
    data['disliked_at'] = dislikedAt;
    data['can_re_swipe'] = canReSwipe;
    data['time_until_available'] = timeUntilAvailable;
    return data;
  }

  /// Get formatted time until available string
  String getTimeUntilAvailableString() {
    if (canReSwipe == true) return 'Available now';
    if (timeUntilAvailable == null || timeUntilAvailable == 0) return 'Available now';

    final duration = Duration(milliseconds: timeUntilAvailable!);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours >= 24) {
      final days = (hours / 24).floor();
      final remainingHours = hours % 24;
      return '$days day${days > 1 ? 's' : ''}, $remainingHours hour${remainingHours != 1 ? 's' : ''}';
    } else if (hours > 0) {
      return '$hours hour${hours > 1 ? 's' : ''}, $minutes minute${minutes != 1 ? 's' : ''}';
    } else {
      return '$minutes minute${minutes != 1 ? 's' : ''}';
    }
  }
}
