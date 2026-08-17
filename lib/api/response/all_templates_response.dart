class AllTemplatesResponse {
  bool? success;
  int? total;
  int? totalPages;
  int? currentPage;
  List<TemplateData>? data;

  AllTemplatesResponse({
    this.success,
    this.total,
    this.totalPages,
    this.currentPage,
    this.data,
  });

  AllTemplatesResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    total = json['total'];
    totalPages = json['totalPages'];
    currentPage = json['currentPage'];

    if (json['data'] != null) {
      data = <TemplateData>[];
      json['data'].forEach((v) {
        data!.add(TemplateData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

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

class TemplateData {
  String? sId;
  String? name;
  String? body;
  String? channel;
  bool? isActive;
  String? createdAt;
  String? updatedAt;

  Campaign? campaign;
  CreatedBy? createdBy;

  TemplateData({
    this.sId,
    this.name,
    this.body,
    this.channel,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.campaign,
    this.createdBy,
  });

  TemplateData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    body = json['body'];
    channel = json['channel'];
    isActive = json['is_active'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];

    campaign = json['campaign_id'] != null
        ? Campaign.fromJson(json['campaign_id'])
        : null;

    createdBy = json['created_by'] != null
        ? CreatedBy.fromJson(json['created_by'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['_id'] = sId;
    data['name'] = name;
    data['body'] = body;
    data['channel'] = channel;
    data['is_active'] = isActive;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;

    if (campaign != null) {
      data['campaign_id'] = campaign!.toJson();
    }

    if (createdBy != null) {
      data['created_by'] = createdBy!.toJson();
    }

    return data;
  }

  @override
  String toString() => name ?? '';
}

class Campaign {
  String? sId;
  String? name;

  Campaign({this.sId, this.name});

  Campaign.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    return {'_id': sId, 'name': name};
  }
}

class CreatedBy {
  String? sId;
  String? name;

  CreatedBy({this.sId, this.name});

  CreatedBy.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    return {'_id': sId, 'name': name};
  }
}
