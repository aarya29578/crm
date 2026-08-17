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
        data!.add(Data.fromJson(v));
      });
    }
    total = json['total'];
    currentpage = json['currentpage'];
    totalPage = json['totalPage'];
    status = json['status'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['total'] = total;
    data['currentpage'] = currentpage;
    data['totalPage'] = totalPage;
    data['status'] = status;
    data['success'] = success;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['description'] = description;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
