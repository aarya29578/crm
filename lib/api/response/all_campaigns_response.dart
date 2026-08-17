class AllCampaignsResponse {
  bool? success;
  List<CampaignData>? data;

  AllCampaignsResponse({this.success, this.data});

  AllCampaignsResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <CampaignData>[];
      json['data'].forEach((v) {
        data!.add(CampaignData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CampaignData {
  String? sId;
  String? name;
  String? createdAt;
  String? updatedAt;

  CampaignData({this.sId, this.name, this.createdAt, this.updatedAt});

  CampaignData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }

  @override
  String toString() => name ?? '';
}
