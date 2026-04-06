class SubstatusLeadStageResponse {
  bool? success;
  int? total;
  int? currentPage;
  int? totalPages;
  List<SubStatusData>? data;

  SubstatusLeadStageResponse({
    this.success,
    this.total,
    this.currentPage,
    this.totalPages,
    this.data,
  });

  SubstatusLeadStageResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    total = json['total'];
    currentPage = json['currentPage'];
    totalPages = json['totalPages'];

    if (json['data'] != null) {
      data = <SubStatusData>[];
      json['data'].forEach((v) {
        data!.add(SubStatusData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = {};
    dataMap['success'] = success;
    dataMap['total'] = total;
    dataMap['currentPage'] = currentPage;
    dataMap['totalPages'] = totalPages;

    if (data != null) {
      dataMap['data'] = data!.map((v) => v.toJson()).toList();
    }

    return dataMap;
  }
}

class SubStatusData {
  String? id;
  String? name;
  bool? isActive;
  LeadStage? leadStage;
  String? tenantId;
  String? createdAt;
  String? updatedAt;
  int? v;

  SubStatusData({
    this.id,
    this.name,
    this.isActive,
    this.leadStage,
    this.tenantId,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  SubStatusData.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    isActive = json['isActive'];
    tenantId = json['tenantId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];

    leadStage = json['lead_stage_id'] != null
        ? LeadStage.fromJson(json['lead_stage_id'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = id;
    data['name'] = name;
    data['isActive'] = isActive;
    data['tenantId'] = tenantId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = v;

    if (leadStage != null) {
      data['lead_stage_id'] = leadStage!.toJson();
    }

    return data;
  }
}

class LeadStage {
  String? id;
  String? name;
  String? color;

  LeadStage({this.id, this.name, this.color});

  LeadStage.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = id;
    data['name'] = name;
    data['color'] = color;
    return data;
  }
}
