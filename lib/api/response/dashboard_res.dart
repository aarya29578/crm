class DashboardDataRes {
  bool? success;
  Data? data;

  DashboardDataRes({this.success, this.data});

  DashboardDataRes.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
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
        leadCountByNewStage!.add(new LeadCountByNewStage.fromJson(v));
      });
    }
    if (json['leadCountByConnected'] != null) {
      leadCountByConnected = <LeadCountByConnected>[];
      json['leadCountByConnected'].forEach((v) {
        leadCountByConnected!.add(new LeadCountByConnected.fromJson(v));
      });
    }
    if (json['leadCountBystages'] != null) {
      leadCountBystages = <LeadCountBystages>[];
      json['leadCountBystages'].forEach((v) {
        leadCountBystages!.add(new LeadCountBystages.fromJson(v));
      });
    }
    callStats = json['callStates'] != null
        ? new CallStats.fromJson(json['callStates'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalLeads'] = this.totalLeads;
    if (this.leadCountByNewStage != null) {
      data['leadCountByNewStage'] = this.leadCountByNewStage!
          .map((v) => v.toJson())
          .toList();
    }
    if (this.leadCountByConnected != null) {
      data['leadCountByConnected'] = this.leadCountByConnected!
          .map((v) => v.toJson())
          .toList();
    }
    if (this.leadCountBystages != null) {
      data['leadCountBystages'] = this.leadCountBystages!
          .map((v) => v.toJson())
          .toList();
    }
    if (this.callStats != null) {
      data['callStats'] = this.callStats!.toJson();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['count'] = this.count;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    data['connected'] = this.connected;
    data['percentage'] = this.percentage;
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
    stage = json['stage'] != null ? new Stage.fromJson(json['stage']) : null;
    percentage = json['percentage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['count'] = this.count;
    if (this.stage != null) {
      data['stage'] = this.stage!.toJson();
    }
    data['percentage'] = this.percentage;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['code'] = this.code;
    data['name'] = this.name;
    data['tenantId'] = this.tenantId;
    data['color'] = this.color;
    data['is_user_defined'] = this.isUserDefined;
    data['connected'] = this.connected;
    data['__v'] = this.iV;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
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
  int? totalDuration;
  String? formattedTotalDuration;

  CallStats({this.overall, this.outbound, this.inbound, this.followUp});

  CallStats.fromJson(Map<String, dynamic> json) {
    overall = json['overall'];
    outbound = json['outbound'];
    inbound = json['inbound'];
    callCount = json['overallTotalCallsCount'];
    followUp = json['overallFollowupCount'];
    connCount = json['overallConnectedCount'];
    totalDuration = json['totalDuration'];
    formattedTotalDuration = json['totalDurationFormatted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['overall'] = this.overall;
    data['outbound'] = this.outbound;
    data['inbound'] = this.inbound;
    data['overallTotalCallsCount'] = this.callCount;
    data['overallFollowupCount'] = this.followUp;
    data['overallConnectedCount'] = this.connCount;
    data['totalDuration'] = totalDuration;
    data['totalDurationFormatted'] = formattedTotalDuration;
    return data;
  }
}
