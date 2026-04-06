class AllGroupResponse {
  List<Data>? data;
  int? total;
  int? currentpage;
  int? totalPage;
  int? status;
  bool? success;

  AllGroupResponse({
    this.data,
    this.total,
    this.currentpage,
    this.totalPage,
    this.status,
    this.success,
  });

  AllGroupResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    total = json['total'];
    currentpage = json['currentpage'];
    totalPage = json['totalPage'];
    status = json['status'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['total'] = this.total;
    data['currentpage'] = this.currentpage;
    data['totalPage'] = this.totalPage;
    data['status'] = this.status;
    data['success'] = this.success;
    return data;
  }
}

class Data {
  String? sId;
  String? name;
  String? description;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data({
    this.sId,
    this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    description = json['description'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
