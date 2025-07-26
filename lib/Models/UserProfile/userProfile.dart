class UserProfileResponseModel {
  bool? success;
  String? message;
  UserData? data;

  UserProfileResponseModel({this.success, this.message, this.data});

  UserProfileResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? UserData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = success ?? false;
    data['message'] = message ?? '';
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class UserData {
  String? id;
  String? email;
  String? username;
  String? contact;
  String? userType;
  bool? isActive;
  bool? isAdmin;
  String? createdAt;
  String? updatedAt;
  String? image;
  bool? isRegistered;
  bool? isDeleted;
  String? fullName;
  String? address;
  double? longitude;
  double? latitude;
  String? dob;
  String? gender;
  bool? isProfileComplete;

  UserData(
      {this.id,
        this.email,
        this.username,
        this.contact,
        this.userType,
        this.isActive,
        this.isAdmin,
        this.createdAt,
        this.updatedAt,
        this.image,
        this.isRegistered,
        this.isDeleted,
        this.fullName,
        this.address,
        this.longitude,
        this.latitude,
        this.dob,
        this.gender,
        this.isProfileComplete,
      });

  UserData.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    email = json['email'] ?? '';
    username = json['username'] ?? '';
    contact = json['contact'] ?? '';
    userType = json['user_type'] ?? '';
    isActive = json['is_active'] ?? false;
    isAdmin = json['is_admin'] ?? false;
    createdAt = json['created_at'] ?? '';
    updatedAt = json['updated_at'] ?? '';
    image = json['image'] ?? '';
    isRegistered = json['is_registered'] ?? false;
    isDeleted = json['is_deleted'] ?? false;
    fullName = json['full_name'] ?? '';
    address = json['address'] ?? '';
    longitude = double.tryParse((json['longitude'] ?? 0.0).toString());
    latitude = double.tryParse((json['latitude'] ?? 0.0).toString());
    dob = json['dob'] ?? '';
    gender = json['gender'] ?? '';
    isProfileComplete = json['is_profile_completed'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id ?? '';
    data['email'] = email ?? '';
    data['username'] = username ?? '';
    data['contact'] = contact ?? '';
    data['user_type'] = userType ?? '';
    data['is_active'] = isActive ?? false;
    data['is_admin'] = isAdmin ?? false;
    data['created_at'] = createdAt ?? '';
    data['updated_at'] = updatedAt ?? '';
    data['image'] = image ?? '';
    data['is_registered'] = isRegistered ?? false;
    data['is_deleted'] = isDeleted ?? false;
    data['full_name'] = fullName ?? '';
    data['address'] = address ?? '';
    data['longitude'] = double.tryParse((longitude ?? 0.0).toString());
    data['latitude'] = double.tryParse((latitude ?? 0.0).toString());
    data['dob'] = dob ?? '';
    data['gender'] = gender ?? '';
    data['is_profile_completed'] = isProfileComplete ?? false;
    return data;
  }

  /// Calculates the profile completion percentage.
  double getProfileCompletionPercentage() {
    List<bool> fields = [
      email?.isNotEmpty ?? false,
      username?.isNotEmpty ?? false,
      contact?.isNotEmpty ?? false,
      fullName?.isNotEmpty ?? false,
      address?.isNotEmpty ?? false,
      longitude != null && longitude != 0.0,
      latitude != null && latitude != 0.0,
      dob?.isNotEmpty ?? false,
      gender?.isNotEmpty ?? false,
    ];
    int completedFields = fields.where((field) => field).length;
    double percentage = (completedFields / fields.length) * 100;
    return percentage;
  }
}
