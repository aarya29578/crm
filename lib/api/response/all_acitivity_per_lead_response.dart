class AllActivityPerLeadResponse {
  bool? success;
  List<Data>? data;

  AllActivityPerLeadResponse({this.success, this.data});

  AllActivityPerLeadResponse.fromJson(Map<String, dynamic> json) {
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
  String? leadId;
  String? userId;
  String? type;
  String? status;
  String? priority;
  String? createdAt;
  String? description;
  String? completedAt;
  String? subject;
  CallInfo? callInfo;
  List<NotesInfo>? notesInfo;

  Data({
    this.sId,
    this.leadId,
    this.userId,
    this.type,
    this.status,
    this.priority,
    this.createdAt,
    this.description,
    this.completedAt,
    this.subject,
    this.callInfo,
    this.notesInfo,
  });

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    leadId = json['lead_id'];
    userId = json['user_id'];
    type = json['type'];
    status = json['status'];
    priority = json['priority'];
    createdAt = json['createdAt'];
    description = json['description'];
    completedAt = json['completed_at'];
    subject = json['subject'];
    callInfo =
        json['call_info'] != null
            ? new CallInfo.fromJson(json['call_info'])
            : null;
    if (json['notes_info'] != null) {
      notesInfo = <NotesInfo>[];
      json['notes_info'].forEach((v) {
        notesInfo!.add(new NotesInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['lead_id'] = this.leadId;
    data['user_id'] = this.userId;
    data['type'] = this.type;
    data['status'] = this.status;
    data['priority'] = this.priority;
    data['createdAt'] = this.createdAt;
    data['description'] = this.description;
    data['completed_at'] = this.completedAt;
    data['subject'] = this.subject;
    if (this.callInfo != null) {
      data['call_info'] = this.callInfo!.toJson();
    }
    if (this.notesInfo != null) {
      data['notes_info'] = this.notesInfo!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CallInfo {
  List<CallId>? callId;
  int? duration;
  String? recordingUrl;
  String? disposition;

  CallInfo({this.callId, this.duration, this.recordingUrl, this.disposition});

  CallInfo.fromJson(Map<String, dynamic> json) {
    if (json['call_id'] != null) {
      callId = <CallId>[];
      json['call_id'].forEach((v) {
        callId!.add(new CallId.fromJson(v));
      });
    }
    duration = json['duration'];
    recordingUrl = json['recording_url'];
    disposition = json['disposition'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.callId != null) {
      data['call_id'] = this.callId!.map((v) => v.toJson()).toList();
    }
    data['duration'] = this.duration;
    data['recording_url'] = this.recordingUrl;
    data['disposition'] = this.disposition;
    return data;
  }
}

class CallId {
  String? sId;
  int? duration;
  String? recordingUrl;
  String? disposition;

  CallId({this.sId, this.duration, this.recordingUrl, this.disposition});

  CallId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    duration = json['duration'];
    recordingUrl = json['recording_url'];
    disposition = json['disposition'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['duration'] = this.duration;
    data['recording_url'] = this.recordingUrl;
    data['disposition'] = this.disposition;
    return data;
  }
}

class NotesInfo {
  String? sId;
  String? description;
  String? createdAt;

  NotesInfo({this.sId, this.description, this.createdAt});

  NotesInfo.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    description = json['description'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['description'] = this.description;
    data['createdAt'] = this.createdAt;
    return data;
  }
}
