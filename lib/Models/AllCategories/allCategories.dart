class AllCategoriesResponseModel {
  bool? success;
  String? message;
  List<Data>? data;

  AllCategoriesResponseModel({this.success, this.message, this.data});

  AllCategoriesResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['success'] = success ?? false;
    data['message'] = message ?? '';
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? description;

  Data({this.id, this.name, this.description});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    name = json['name'] ?? '';
    description = json['description'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id ?? '';
    data['name'] = name ?? '';
    data['description'] = description ?? '';
    return data;
  }
}
