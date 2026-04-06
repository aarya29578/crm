class AllSourceResponse {
  int? status;
  bool? success;
  List<Data>? data;
  int? total;
  int? currentPage;
  int? totalPage;

  AllSourceResponse({
    this.status,
    this.success,
    this.data,
    this.total,
    this.currentPage,
    this.totalPage,
  });

  AllSourceResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    total = json['total'];
    currentPage = json['currentPage'];
    totalPage = json['totalPage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['total'] = this.total;
    data['currentPage'] = this.currentPage;
    data['totalPage'] = this.totalPage;
    return data;
  }
}

class Data {
  String? sId;
  String? name;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data({this.sId, this.name, this.createdAt, this.updatedAt, this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
