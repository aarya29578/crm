class AllCallHistoryResponse {
  bool? success;
  List<Data>? data;

  AllCallHistoryResponse({this.success, this.data});

  AllCallHistoryResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
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
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? sId;
  LeadIds? leadId;
  UserId? userId;
  String? direction;
  String? fromNumber;
  String? toNumber;
  int? duration;
  String? recordingUrl;
  String? disposition;
  String? status;
  String? startedAt;
  String? endedAt;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data({
    this.sId,
    this.leadId,
    this.userId,
    this.direction,
    this.fromNumber,
    this.toNumber,
    this.duration,
    this.recordingUrl,
    this.disposition,
    this.status,
    this.startedAt,
    this.endedAt,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    leadId = json['lead_id'] != null
        ? new LeadIds.fromJson(json['lead_id'])
        : null;
    userId = json['user_id'] != null
        ? new UserId.fromJson(json['user_id'])
        : null;
    // userId = json['user_id'];
    direction = json['direction'];
    fromNumber = json['from_number'];
    toNumber = json['to_number'];
    duration = json['duration'];
    recordingUrl = json['recording_url'];
    disposition = json['disposition'];
    status = json['status'];
    startedAt = json['started_at'];
    endedAt = json['ended_at'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    // data['lead_id'] = this.leadId;
    if (this.leadId != null) {
      data['name'] = this.leadId!.toJson();
    }
    if (this.userId != null) {
      data['user_id'] = this.userId!.toJson();
    }
    // data['user_id'] = this.userId;
    data['direction'] = this.direction;
    data['from_number'] = this.fromNumber;
    data['to_number'] = this.toNumber;
    data['duration'] = this.duration;
    data['recording_url'] = this.recordingUrl;
    data['disposition'] = this.disposition;
    data['status'] = this.status;
    data['started_at'] = this.startedAt;
    data['ended_at'] = this.endedAt;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class LeadIds {
  String? id;
  LeadName? leadName;
  int? phone;
  String? email;
  bool? status;

  LeadIds({this.id, this.leadName, this.phone, this.email, this.status});

  LeadIds.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    leadName = json['name'] != null
        ? new LeadName.fromJson(json['name'])
        : null;
    phone = json['phone'];
    email = json['email'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['name'] = this.id;
    data['phone'] = this.id;
    data['email'] = this.id;
    data['status'] = this.id;
    if (this.leadName != null) {
      data['name'] = this.leadName!.toJson();
    }
    return data;
  }
}

class LeadName {
  String? first;
  String? last;
  String? middle;

  LeadName({this.first, this.last, this.middle});

  LeadName.fromJson(Map<String, dynamic> json) {
    first = json['first'];
    last = json['last'];
    middle = json['middle'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['first'] = this.first;
    data['last'] = this.last;
    data['middle'] = this.middle;
    return data;
  }
}

class UserId {
  String? uId;
  String? name;
  String? email;

  UserId({this.uId, this.name, this.email});

  UserId.fromJson(Map<String, dynamic> json) {
    uId = json['first'];
    name = json['last'];
    email = json['middle'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['first'] = this.uId;
    data['last'] = this.name;
    data['middle'] = this.email;
    return data;
  }
}
