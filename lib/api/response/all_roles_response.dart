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
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['totalPage'] = totalPage;
    data['total'] = total;
    data['currentPage'] = currentPage;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['description'] = description;
    data['permission_type'] = permissionType;
    data['permissions'] = permissions;
    data['tenantId'] = tenantId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
