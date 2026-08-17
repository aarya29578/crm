class DashboardDataRes {
  bool? success;
  Data? data;

  DashboardDataRes({this.success, this.data});

  DashboardDataRes.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? totalLeads;
  List<LeadCountByNewStage>? leadCountByNewStage;
  List<LeadCountByConnected>? leadCountByConnected;
  List<LeadCountBystages>? leadCountBystages;
  CallStats? callStats;

  Data({
    this.totalLeads,
    this.leadCountByNewStage,
    this.leadCountByConnected,
    this.leadCountBystages,
    this.callStats,
  });

  Data.fromJson(Map<String, dynamic> json) {
    totalLeads = json['totalLeads'];
    if (json['leadCountByNewStage'] != null) {
      leadCountByNewStage = <LeadCountByNewStage>[];
      json['leadCountByNewStage'].forEach((v) {
        leadCountByNewStage!.add(LeadCountByNewStage.fromJson(v));
      });
    }
    if (json['leadCountByConnected'] != null) {
      leadCountByConnected = <LeadCountByConnected>[];
      json['leadCountByConnected'].forEach((v) {
        leadCountByConnected!.add(LeadCountByConnected.fromJson(v));
      });
    }
    if (json['leadCountBystages'] != null) {
      leadCountBystages = <LeadCountBystages>[];
      json['leadCountBystages'].forEach((v) {
        leadCountBystages!.add(LeadCountBystages.fromJson(v));
      });
    }
    callStats = json['callStates'] != null
        ? CallStats.fromJson(json['callStates'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalLeads'] = totalLeads;
    if (leadCountByNewStage != null) {
      data['leadCountByNewStage'] = leadCountByNewStage!
          .map((v) => v.toJson())
          .toList();
    }
    if (leadCountByConnected != null) {
      data['leadCountByConnected'] = leadCountByConnected!
          .map((v) => v.toJson())
          .toList();
    }
    if (leadCountBystages != null) {
      data['leadCountBystages'] = leadCountBystages!
          .map((v) => v.toJson())
          .toList();
    }
    if (callStats != null) {
      data['callStats'] = callStats!.toJson();
    }
    return data;
  }
}

class LeadCountByNewStage {
  String? sId;
  int? count;

  LeadCountByNewStage({this.sId, this.count});

  LeadCountByNewStage.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['count'] = count;
    return data;
  }
}

class LeadCountByConnected {
  int? count;
  String? connected;
  String? percentage;

  LeadCountByConnected({this.count, this.connected, this.percentage});

  LeadCountByConnected.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    connected = json['connected'];
    percentage = json['percentage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    data['connected'] = connected;
    data['percentage'] = percentage;
    return data;
  }
}

class LeadCountBystages {
  String? sId;
  int? count;
  Stage? stage;
  String? percentage;

  LeadCountBystages({this.sId, this.count, this.stage, this.percentage});

  LeadCountBystages.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    count = json['count'];
    stage = json['stage'] != null ? Stage.fromJson(json['stage']) : null;
    percentage = json['percentage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['count'] = count;
    if (stage != null) {
      data['stage'] = stage!.toJson();
    }
    data['percentage'] = percentage;
    return data;
  }
}

class Stage {
  String? sId;
  String? code;
  String? name;
  String? tenantId;
  String? color;
  bool? isUserDefined;
  bool? connected;
  int? iV;
  String? createdAt;
  String? updatedAt;

  Stage({
    this.sId,
    this.code,
    this.name,
    this.tenantId,
    this.color,
    this.isUserDefined,
    this.connected,
    this.iV,
    this.createdAt,
    this.updatedAt,
  });

  Stage.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    code = json['code'];
    name = json['name'];
    tenantId = json['tenantId'];
    color = json['color'];
    isUserDefined = json['is_user_defined'];
    connected = json['connected'];
    iV = json['__v'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['code'] = code;
    data['name'] = name;
    data['tenantId'] = tenantId;
    data['color'] = color;
    data['is_user_defined'] = isUserDefined;
    data['connected'] = connected;
    data['__v'] = iV;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class CallStats {
  int? overall;
  int? outbound;
  int? inbound;
  int? callCount;
  int? followUp;
  int? connCount;
  int? missedFollowUps;
  int? totalDuration;
  String? formattedTotalDuration;

  CallStats({
    this.overall,
    this.outbound,
    this.inbound,
    this.followUp,
    this.missedFollowUps,
  });

  CallStats.fromJson(Map<String, dynamic> json) {
    overall = json['overall'];
    outbound = json['outbound'];
    inbound = json['inbound'];
    callCount = json['overallTotalCallsCount'];
    followUp = json['overallFollowupCount'];
    connCount = json['overallConnectedCount'];
    missedFollowUps = json['missedFollowUps'];
    totalDuration = json['totalDuration'];
    formattedTotalDuration = json['totalDurationFormatted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['overall'] = overall;
    data['outbound'] = outbound;
    data['inbound'] = inbound;
    data['overallTotalCallsCount'] = callCount;
    data['overallFollowupCount'] = followUp;
    data['overallConnectedCount'] = connCount;
    data['missedFollowUps'] = missedFollowUps;
    data['totalDuration'] = totalDuration;
    data['totalDurationFormatted'] = formattedTotalDuration;
    return data;
  }
}


