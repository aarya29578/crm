class AllCallHistoryResponse {
  bool? success;
  int? total;
  int? page;
  int? limit;
  List<CallHistoryGroup>? data;

  AllCallHistoryResponse({
    this.success,
    this.total,
    this.page,
    this.limit,
    this.data,
  });

  AllCallHistoryResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    total = json['total'];
    page = json['page'];
    limit = json['limit'];
    if (json['data'] != null) {
      data = <CallHistoryGroup>[];
      json['data'].forEach((v) {
        data!.add(CallHistoryGroup.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['total'] = total;
    data['page'] = page;
    data['limit'] = limit;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CallHistoryGroup {
  String? date;
  int? callCount;
  String? lastCallAt;
  CalledBy? calledBy;
  Lead? lead;

  CallHistoryGroup({
    this.date,
    this.callCount,
    this.lastCallAt,
    this.calledBy,
    this.lead,
  });

  CallHistoryGroup.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    callCount = json['callCount'];
    lastCallAt = json['lastCallAt'];
    calledBy = (json['calledBy'] != null && json['calledBy'] is Map) 
        ? CalledBy.fromJson(json['calledBy']) : null;
    lead = (json['lead'] != null && json['lead'] is Map) 
        ? Lead.fromJson(json['lead']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['callCount'] = callCount;
    data['lastCallAt'] = lastCallAt;
    if (calledBy != null) {
      data['calledBy'] = calledBy!.toJson();
    }
    if (lead != null) {
      data['lead'] = lead!.toJson();
    }
    return data;
  }
}

class CalledBy {
  String? sId;
  String? name;
  String? email;

  CalledBy({this.sId, this.name, this.email});

  CalledBy.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['email'] = email;
    return data;
  }
}

class Lead {
  String? sId;
  LeadName? name;
  int? phone;
  String? email;
  LeadStage? leadStage;
  String? priority;

  Lead({
    this.sId,
    this.name,
    this.phone,
    this.email,
    this.leadStage,
    this.priority,
  });

  Lead.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = (json['name'] != null && json['name'] is Map) 
        ? LeadName.fromJson(json['name']) : null;
    phone = json['phone'];
    email = json['email'];
    leadStage = (json['lead_stage_id'] != null && json['lead_stage_id'] is Map) 
        ? LeadStage.fromJson(json['lead_stage_id']) : null;
    priority = json['priority'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (name != null) {
      data['name'] = name!.toJson();
    }
    data['phone'] = phone;
    data['email'] = email;
    if (leadStage != null) {
      data['lead_stage_id'] = leadStage!.toJson();
    }
    data['priority'] = priority;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first'] = first;
    data['last'] = last;
    data['middle'] = middle;
    return data;
  }
}

class LeadStage {
  String? sId;
  String? name;
  String? color;
  String? connected;

  LeadStage({this.sId, this.name, this.color, this.connected});

  LeadStage.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    color = json['color'];
    connected = json['connected'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['color'] = color;
    data['connected'] = connected;
    return data;
  }
}
