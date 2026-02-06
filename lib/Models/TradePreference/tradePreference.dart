class GetTradePreferenceResponseModel {
  bool? success;
  String? message;
  String? tradeRadius;
  List<Interests>? interests;

  // NEW FIELD
  String? meetingPreference;

  GetTradePreferenceResponseModel({
    this.success,
    this.message,
    this.tradeRadius,
    this.interests,
    this.meetingPreference,
  });

  GetTradePreferenceResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    message = json['message'] ?? '';
    tradeRadius = json['trade_radius'] ?? '';

    // NEW FIELD PARSING
    meetingPreference = json['meeting_preference'] ?? 'public_place';

    if (json['interests'] != null) {
      interests = <Interests>[];
      json['interests'].forEach((v) {
        interests!.add(Interests.fromJson(v));
      });
    } else {
      interests = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success ?? false;
    data['message'] = message ?? '';
    data['trade_radius'] = tradeRadius ?? '';

    // NEW FIELD IN JSON
    data['meeting_preference'] = meetingPreference ?? 'public_place';

    data['interests'] = interests != null
        ? interests!.map((v) => v.toJson()).toList()
        : [];
    return data;
  }
}

class Interests {
  int? id;
  String? interestName;

  Interests({this.id, this.interestName});

  Interests.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    interestName = json['interest_name'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id ?? 0;
    data['interest_name'] = interestName ?? '';
    return data;
  }
}
