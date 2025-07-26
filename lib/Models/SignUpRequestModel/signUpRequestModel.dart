class SignUpRequestModel {
  String? email;
  String? username;
  String? password;
  String? password2;
  String? userType;
  String? firstName;
  String? lastName;
  String? fullName;
  String? address;
  String? contact;

  SignUpRequestModel(
      {this.email,
        this.username,
        this.password,
        this.password2,
        this.userType,
        this.firstName,
        this.lastName,
        this.fullName,
        this.address,
        this.contact});

  SignUpRequestModel.fromJson(Map<String, dynamic> json) {
    email = json['email'] ?? '';
    username = json['username'] ?? '';
    password = json['password'] ?? '';
    password2 = json['password2'] ?? '';
    userType = 'client' ?? '';
    firstName = json['first_name'] ?? '';
    lastName = json['last_name'] ?? '';
    fullName = json['full_name'] ?? '';
    address = json['address'] ?? '';
    contact = json['contact'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['email'] = email ?? '';
    data['username'] = username ?? '';
    data['password'] = password ?? '';
    data['password2'] = password2 ?? '';
    data['user_type'] = 'client' ?? '';
    data['first_name'] = firstName ?? '';
    data['last_name'] = lastName ?? '';
    data['full_name'] = fullName;
    data['address'] = address ?? '';
    data['contact'] = contact ?? '';
    return data;
  }
}
