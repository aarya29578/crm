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
        data!.add(Data.fromJson(v));
      });
    }
    total = json['total'];
    currentPage = json['currentPage'];
    totalPage = json['totalPage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['total'] = total;
    data['currentPage'] = currentPage;
    data['totalPage'] = totalPage;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
