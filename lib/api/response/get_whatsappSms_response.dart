class GetWhatsappsmsResponse {
  bool? success;
  int? total;
  int? totalPages;
  int? currentPage;
  List<WSData>? data;

  GetWhatsappsmsResponse({
    this.success,
    this.total,
    this.totalPages,
    this.currentPage,
    this.data,
  });

  GetWhatsappsmsResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] ?? false;
    total = json['total'] ?? 0;
    totalPages = json['totalPages'] ?? 0;
    currentPage = json['currentPage'] ?? 0;
    if (json['data'] != null) {
      final List<dynamic> dataList = json['data'];
      data = dataList.map((v) => WSData.fromJson(v)).toList();
    } else {
      data = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['total'] = total;
    data['totalPages'] = totalPages;
    data['currentPage'] = currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class WSData {
  String? sId;
  CompaignName? compaignName;
  // TenantId? tenantId;
  CompaignName? createdBy;
  String? name;
  String? channel;
  String? body;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  int? iV;

  WSData({
    this.sId,
    this.compaignName,
    // this.tenantId,
    this.createdBy,
    this.name,
    this.channel,
    this.body,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  WSData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    compaignName = json['campaignId'] != null
        ? CompaignName.fromJson(json['campaignId'])
        : null;
    // tenantId = json['tenantId'] != null
    //     ? TenantId.fromJson(json['tenantId'])
    //     : null;

    createdBy = json['created_by'] != null
        ? CompaignName.fromJson(json['created_by'])
        : null;

    name = json['name'] ?? 'no name';
    channel = json['channel'] ?? 'no channel';
    body = json['body'] ?? 'no detail found';

    isActive = json['is_active'] ?? false;

    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;

    if (compaignName != null) {
      data['campaignId'] = compaignName?.toJson();
    }
    if (createdBy != null) {
      data['created_by'] = createdBy?.toJson();
    }

    data['name'] = name;
    data['channel'] = channel;
    data['body'] = body;
    data['is_active'] = isActive;

    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class CompaignName {
  String? sId;
  String? name;

  CompaignName({this.sId, this.name});

  CompaignName.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    return data;
  }
}
