class AllInterestResponseModel {
  bool? success;
  String? message;
  List<Data>? data;

  AllInterestResponseModel({this.success, this.message, this.data});

  AllInterestResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    message = json['message'] ?? '';
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

  Data({this.id, this.name});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? -1;
    name = json['name'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id ?? -1;
    data['name'] = name ?? '';
    return data;
  }
}
