class AllActivityPerLeadResponse {
  bool? success;
  List<Data>? data;

  AllActivityPerLeadResponse({this.success, this.data});

  AllActivityPerLeadResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
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
            ? CallInfo.fromJson(json['call_info'])
            : null;
    if (json['notes_info'] != null) {
      notesInfo = <NotesInfo>[];
      json['notes_info'].forEach((v) {
        notesInfo!.add(NotesInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['lead_id'] = leadId;
    data['user_id'] = userId;
    data['type'] = type;
    data['status'] = status;
    data['priority'] = priority;
    data['createdAt'] = createdAt;
    data['description'] = description;
    data['completed_at'] = completedAt;
    data['subject'] = subject;
    if (callInfo != null) {
      data['call_info'] = callInfo!.toJson();
    }
    if (notesInfo != null) {
      data['notes_info'] = notesInfo!.map((v) => v.toJson()).toList();
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
        callId!.add(CallId.fromJson(v));
      });
    }
    duration = json['duration'];
    recordingUrl = json['recording_url'];
    disposition = json['disposition'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (callId != null) {
      data['call_id'] = callId!.map((v) => v.toJson()).toList();
    }
    data['duration'] = duration;
    data['recording_url'] = recordingUrl;
    data['disposition'] = disposition;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['duration'] = duration;
    data['recording_url'] = recordingUrl;
    data['disposition'] = disposition;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['description'] = description;
    data['createdAt'] = createdAt;
    return data;
  }
}
