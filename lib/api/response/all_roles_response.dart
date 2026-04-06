class AllRoleResponse {
  bool? success;
  int? totalPage;
  int? total;
  int? currentPage;
  List<Data>? data;

  AllRoleResponse({
    this.success,
    this.totalPage,
    this.total,
    this.currentPage,
    this.data,
  });

  AllRoleResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    totalPage = json['totalPage'];
    total = json['total'];
    currentPage = json['currentPage'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['totalPage'] = this.totalPage;
    data['total'] = this.total;
    data['currentPage'] = this.currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? sId;
  String? name;
  String? description;
  String? permissionType;
  List<String>? permissions;
  String? tenantId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data({
    this.sId,
    this.name,
    this.description,
    this.permissionType,
    this.permissions,
    this.tenantId,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    description = json['description'];
    permissionType = json['permission_type'];
    permissions = json['permissions'].cast<String>();
    tenantId = json['tenantId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['permission_type'] = this.permissionType;
    data['permissions'] = this.permissions;
    data['tenantId'] = this.tenantId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
