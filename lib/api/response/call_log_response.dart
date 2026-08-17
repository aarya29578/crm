// class CallLogsResponse {
//   bool? success;
//   List<Data>? data;

//   CallLogsResponse({this.success, this.data});

//   CallLogsResponse.fromJson(Map<String, dynamic> json) {
//     success = json['success'];
//     if (json['data'] != null) {
//       data = <Data>[];
//       json['data'].forEach((v) {
//         data!.add(new Data.fromJson(v));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['success'] = this.success;
//     if (this.data != null) {
//       data['data'] = this.data!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
class CallLogsResponse {
  bool? success;
  int? total;
  int? page;
  int? limit;
  List<Data>? data;

  CallLogsResponse({
    this.success,
    this.total,
    this.page,
    this.limit,
    this.data,
  });

  CallLogsResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    total = json['total'];
    page = json['page'];
    limit = json['limit'];
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
    data['total'] = total;
    data['page'] = page;
    data['limit'] = limit;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// class Data {
//   String? sId;
//   LeadId? leadId;
//   UserId? userId;
//   String? direction;
//   String? fromNumber;
//   String? toNumber;
//   int? duration;
//   String? recordingUrl;
//   String? disposition;
//   String? status;
//   String? startedAt;
//   String? endedAt;
//   String? createdAt;
//   String? updatedAt;
//   int? iV;
//   String? tenantId;
//   Null uniqueCallId;

//   Data({
//     this.sId,
//     this.leadId,
//     this.userId,
//     this.direction,
//     this.fromNumber,
//     this.toNumber,
//     this.duration,
//     this.recordingUrl,
//     this.disposition,
//     this.status,
//     this.startedAt,
//     this.endedAt,
//     this.createdAt,
//     this.updatedAt,
//     this.iV,
//     this.tenantId,
//     this.uniqueCallId,
//   });

//   Data.fromJson(Map<String, dynamic> json) {
//     sId = json['_id'];
//     leadId = json['lead_id'] != null
//         ? new LeadId.fromJson(json['lead_id'])
//         : null;
//     userId = json['user_id'] != null
//         ? new UserId.fromJson(json['user_id'])
//         : null;
//     direction = json['direction'];
//     fromNumber = json['from_number'];
//     toNumber = json['to_number'];
//     duration = json['duration'];
//     recordingUrl = json['recording_url'];
//     disposition = json['disposition'];
//     status = json['status'];
//     startedAt = json['started_at'];
//     endedAt = json['ended_at'];
//     createdAt = json['createdAt'];
//     updatedAt = json['updatedAt'];
//     iV = json['__v'];
//     tenantId = json['tenantId'];
//     uniqueCallId = json['unique_callId'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['_id'] = this.sId;
//     if (this.leadId != null) {
//       data['lead_id'] = this.leadId!.toJson();
//     }
//     if (this.userId != null) {
//       data['user_id'] = this.userId!.toJson();
//     }
//     data['direction'] = this.direction;
//     data['from_number'] = this.fromNumber;
//     data['to_number'] = this.toNumber;
//     data['duration'] = this.duration;
//     data['recording_url'] = this.recordingUrl;
//     data['disposition'] = this.disposition;
//     data['status'] = this.status;
//     data['started_at'] = this.startedAt;
//     data['ended_at'] = this.endedAt;
//     data['createdAt'] = this.createdAt;
//     data['updatedAt'] = this.updatedAt;
//     data['__v'] = this.iV;
//     data['tenantId'] = this.tenantId;
//     data['unique_callId'] = this.uniqueCallId;
//     return data;
//   }
// }
class Data {
  String? sId;
  LeadId? leadId;
  UserId? userId;
  String? uniqueCallId;
  String? direction;
  String? fromNumber;
  String? toNumber;
  int? duration;
  String? recordingUrl;
  String? disposition;
  String? tenantId;
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
    this.uniqueCallId,
    this.direction,
    this.fromNumber,
    this.toNumber,
    this.duration,
    this.recordingUrl,
    this.disposition,
    this.tenantId,
    this.status,
    this.startedAt,
    this.endedAt,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    leadId = json['lead_id'] != null ? LeadId.fromJson(json['lead_id']) : null;
    userId = json['user_id'] != null ? UserId.fromJson(json['user_id']) : null;
    uniqueCallId = json['unique_callId'];
    direction = json['direction'];
    fromNumber = json['from_number'];
    toNumber = json['to_number'];
    duration = json['duration'];
    recordingUrl = json['recording_url'];
    disposition = json['disposition'];
    tenantId = json['tenantId'];
    status = json['status'];
    startedAt = json['started_at'];
    endedAt = json['ended_at'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (leadId != null) {
      data['lead_id'] = leadId!.toJson();
    }
    if (userId != null) {
      data['user_id'] = userId!.toJson();
    }
    data['unique_callId'] = uniqueCallId;
    data['direction'] = direction;
    data['from_number'] = fromNumber;
    data['to_number'] = toNumber;
    data['duration'] = duration;
    data['recording_url'] = recordingUrl;
    data['disposition'] = disposition;
    data['tenantId'] = tenantId;
    data['status'] = status;
    data['started_at'] = startedAt;
    data['ended_at'] = endedAt;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

// class LeadId {
//   String? sId;
//   String? userId;
//   String? leadSourceId;
//   String? leadStageId;
//   Name? name;
//   int? phone;
//   String? email;
//   String? address;
//   int? pincode;
//   String? remarks;
//   String? assignedTo;
//   String? priority;
//   int? age;
//   String? gender;
//   String? companyName;
//   String? designation;
//   String? website;
//   String? tenantId;
//   List<Null>? documents;
//   List<CustomList>? customList;
//   String? createdAt;
//   String? updatedAt;
//   int? iV;
//   bool? status;
//   String? followUpDate;
//   Location? location;
//   String? listId;

//   LeadId({
//     this.sId,
//     this.userId,
//     this.leadSourceId,
//     this.leadStageId,
//     this.name,
//     this.phone,
//     this.email,
//     this.address,
//     this.pincode,
//     this.remarks,
//     this.assignedTo,
//     this.priority,
//     this.age,
//     this.gender,
//     this.companyName,
//     this.designation,
//     this.website,
//     this.tenantId,
//     this.documents,
//     this.customList,
//     this.createdAt,
//     this.updatedAt,
//     this.iV,
//     this.status,
//     this.followUpDate,
//     this.location,
//     this.listId,
//   });

//   LeadId.fromJson(Map<String, dynamic> json) {
//     sId = json['_id'];
//     userId = json['user_id'];
//     leadSourceId = json['lead_source_id'];
//     leadStageId = json['lead_stage_id'];
//     name = json['name'] != null ? new Name.fromJson(json['name']) : null;
//     phone = json['phone'];
//     email = json['email'];
//     address = json['address'];
//     pincode = json['pincode'];
//     remarks = json['remarks'];
//     assignedTo = json['assignedTo'];
//     priority = json['priority'];
//     age = json['age'];
//     gender = json['gender'];
//     companyName = json['company_name'];
//     designation = json['designation'];
//     website = json['website'];
//     tenantId = json['tenantId'];
//     // if (json['documents'] != null) {
//     //   documents = <Null>[];
//     //   json['documents'].forEach((v) {
//     //     documents!.add(new Null.fromJson(v));
//     //   });
//     // }
//     if (json['customList'] != null) {
//       customList = <CustomList>[];
//       json['customList'].forEach((v) {
//         customList!.add(new CustomList.fromJson(v));
//       });
//     }
//     createdAt = json['createdAt'];
//     updatedAt = json['updatedAt'];
//     iV = json['__v'];
//     status = json['status'];
//     followUpDate = json['followUpDate'];
//     location = json['location'] != null
//         ? new Location.fromJson(json['location'])
//         : null;
//     listId = json['listId'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['_id'] = this.sId;
//     data['user_id'] = this.userId;
//     data['lead_source_id'] = this.leadSourceId;
//     data['lead_stage_id'] = this.leadStageId;
//     if (this.name != null) {
//       data['name'] = this.name!.toJson();
//     }
//     data['phone'] = this.phone;
//     data['email'] = this.email;
//     data['address'] = this.address;
//     data['pincode'] = this.pincode;
//     data['remarks'] = this.remarks;
//     data['assignedTo'] = this.assignedTo;
//     data['priority'] = this.priority;
//     data['age'] = this.age;
//     data['gender'] = this.gender;
//     data['company_name'] = this.companyName;
//     data['designation'] = this.designation;
//     data['website'] = this.website;
//     data['tenantId'] = this.tenantId;
//     // if (this.documents != null) {
//     //   data['documents'] = this.documents!.map((v) => v.toJson()).toList();
//     // }
//     if (this.customList != null) {
//       data['customList'] = this.customList!.map((v) => v.toJson()).toList();
//     }
//     data['createdAt'] = this.createdAt;
//     data['updatedAt'] = this.updatedAt;
//     data['__v'] = this.iV;
//     data['status'] = this.status;
//     data['followUpDate'] = this.followUpDate;
//     if (this.location != null) {
//       data['location'] = this.location!.toJson();
//     }
//     data['listId'] = this.listId;
//     return data;
//   }
// }
class LeadId {
  String? sId;
  String? userId;
  String? leadSourceId;
  LeadStageId? leadStageId;
  Name? name;
  int? phone;
  String? email;
  String? address;
  int? pincode;
  String? remarks;
  AssignedTo? assignedTo;
  String? priority;
  int? age;
  String? gender;
  String? companyName;
  String? designation;
  String? website;
  String? tenantId;
  List<dynamic>? documents;
  List<CustomList>? customList;
  String? createdAt;
  String? updatedAt;
  int? iV;
  bool? status;
  String? followUpDate;
  Location? location;
  String? listId;
  String? campaignId; // Add this
  String? poolStatus; // Add this
  List<dynamic>? rejectedBy; // Add this
  SubStatusId? subStatusId; // Add this (new class)

  LeadId({
    this.sId,
    this.userId,
    this.leadSourceId,
    this.leadStageId,
    this.name,
    this.phone,
    this.email,
    this.address,
    this.pincode,
    this.remarks,
    this.assignedTo,
    this.priority,
    this.age,
    this.gender,
    this.companyName,
    this.designation,
    this.website,
    this.tenantId,
    this.documents,
    this.customList,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.status,
    this.followUpDate,
    this.location,
    this.listId,
    this.campaignId,
    this.poolStatus,
    this.rejectedBy,
    this.subStatusId,
  });

  LeadId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['user_id'];
    leadSourceId = json['lead_source_id'];
    leadStageId = json['lead_stage_id'] != null
        ? LeadStageId.fromJson(json['lead_stage_id'])
        : null;
    name = json['name'] != null ? Name.fromJson(json['name']) : null;
    phone = json['phone'];
    email = json['email'];
    address = json['address'];
    pincode = json['pincode'];
    remarks = json['remarks'];
    assignedTo = json['assignedTo'] != null
        ? AssignedTo.fromJson(json['assignedTo'])
        : null;
    priority = json['priority'];
    age = json['age'];
    gender = json['gender'];
    companyName = json['company_name'];
    designation = json['designation'];
    website = json['website'];
    tenantId = json['tenantId'];
    documents = json['documents'] ?? [];
    if (json['customList'] != null) {
      customList = <CustomList>[];
      json['customList'].forEach((v) {
        customList!.add(CustomList.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    status = json['status'];
    followUpDate = json['followUpDate'];
    location = json['location'] != null
        ? Location.fromJson(json['location'])
        : null;
    listId = json['listId'];
    campaignId = json['campaignId'];
    poolStatus = json['poolStatus'];
    rejectedBy = json['rejectedBy'] ?? [];
    subStatusId = json['sub_status_id'] != null
        ? SubStatusId.fromJson(json['sub_status_id'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['user_id'] = userId;
    data['lead_source_id'] = leadSourceId;
    if (leadStageId != null) {
      data['lead_stage_id'] = leadStageId!.toJson();
    }
    if (name != null) {
      data['name'] = name!.toJson();
    }
    data['phone'] = phone;
    data['email'] = email;
    data['address'] = address;
    data['pincode'] = pincode;
    data['remarks'] = remarks;
    if (assignedTo != null) {
      data['assignedTo'] = assignedTo!.toJson();
    }
    data['priority'] = priority;
    data['age'] = age;
    data['gender'] = gender;
    data['company_name'] = companyName;
    data['designation'] = designation;
    data['website'] = website;
    data['tenantId'] = tenantId;
    data['documents'] = documents;
    if (customList != null) {
      data['customList'] = customList!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['status'] = status;
    data['followUpDate'] = followUpDate;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['listId'] = listId;
    data['campaignId'] = campaignId;
    data['poolStatus'] = poolStatus;
    data['rejectedBy'] = rejectedBy;
    if (subStatusId != null) {
      data['sub_status_id'] = subStatusId!.toJson();
    }
    return data;
  }
}

// Add this new class for sub_status_id
class SubStatusId {
  String? sId;
  String? name;

  SubStatusId({this.sId, this.name});

  SubStatusId.fromJson(Map<String, dynamic> json) {
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

// New class for lead_stage_id
class LeadStageId {
  String? sId;
  String? name;
  String? color;
  String? connected; // ✅ Changed from bool to String

  LeadStageId({this.sId, this.name, this.color, this.connected});

  LeadStageId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    color = json['color'];
    connected = json['connected']; // Now it correctly accepts String
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

// New class for assignedTo
class AssignedTo {
  String? sId;
  String? name;

  AssignedTo({this.sId, this.name});

  AssignedTo.fromJson(Map<String, dynamic> json) {
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

class Name {
  String? first;
  String? last;
  String? middle;

  Name({this.first, this.last, this.middle});

  Name.fromJson(Map<String, dynamic> json) {
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

class CustomList {
  String? label;
  List<String>? value;
  String? sId;

  CustomList({this.label, this.value, this.sId});

  CustomList.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    value = json['value'].cast<String>();
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = label;
    data['value'] = value;
    data['_id'] = sId;
    return data;
  }
}

class Location {
  String? country;
  String? state;
  String? city;

  Location({this.country, this.state, this.city});

  Location.fromJson(Map<String, dynamic> json) {
    country = json['country'];
    state = json['state'];
    city = json['city'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['country'] = country;
    data['state'] = state;
    data['city'] = city;
    return data;
  }
}

class UserId {
  String? sId;
  String? name;
  String? email;
  String? password;
  bool? status;
  String? role;
  String? tenantId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  UserId({
    this.sId,
    this.name,
    this.email,
    this.password,
    this.status,
    this.role,
    this.tenantId,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  UserId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    password = json['password'];
    status = json['status'];
    role = json['role'];
    tenantId = json['tenantId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['email'] = email;
    data['password'] = password;
    data['status'] = status;
    data['role'] = role;
    data['tenantId'] = tenantId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
