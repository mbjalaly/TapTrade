class TraderProfileResponseModel {
  bool? success;
  String? message;
  Data? data;

  TraderProfileResponseModel({this.success, this.message, this.data});

  TraderProfileResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    message = json['message'] ?? "";
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success ?? false;
    data['message'] = message ?? "";
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
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

  Data(
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

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? "";
    email = json['email'] ?? "";
    contact = json['contact'] ?? "";
    fullName = json['full_name'] ?? "";
    username = json['username'] ?? "";
    userType = json['user_type'] ?? "";
    isActive = json['is_active'] ?? false;
    isAdmin = json['is_admin'] ?? false;
    createdAt = json['created_at'] ?? "";
    updatedAt = json['updated_at'] ?? "";
    image = json['image'] ?? "";
    isRegistered = json['is_registered'] ?? false;
    isDeleted = json['is_deleted'] ?? false;
    address = json['address'] ?? "";
    longitude = json['longitude'] ?? "";
    latitude = json['latitude'] ?? "";
    dob = json['dob'] ?? "";
    gender = json['gender'] ?? "";
    isProfileCompleted = json['is_profile_completed'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id ?? "";
    data['email'] = email ?? "";
    data['contact'] = contact ?? "";
    data['full_name'] = fullName ?? "";
    data['username'] = username ?? "";
    data['user_type'] = userType ?? "";
    data['is_active'] = isActive ?? false;
    data['is_admin'] = isAdmin ?? false;
    data['created_at'] = createdAt ?? "";
    data['updated_at'] = updatedAt ?? "";
    data['image'] = image ?? "";
    data['is_registered'] = isRegistered ?? false;
    data['is_deleted'] = isDeleted ?? false;
    data['address'] = address ?? "";
    data['longitude'] = longitude ?? "";
    data['latitude'] = latitude ?? "";
    data['dob'] = dob ?? "";
    data['gender'] = gender ?? "";
    data['is_profile_completed'] = isProfileCompleted ?? false;
    return data;
  }
}
