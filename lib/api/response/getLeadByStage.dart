class GetLeadbyStageRes {
  bool? success;
  LeadStageDetails? leadStageDetails;
  List<LeadDetails>? leadDetails;

  GetLeadbyStageRes({this.success, this.leadStageDetails, this.leadDetails});

  GetLeadbyStageRes.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    leadStageDetails = json['lead_stage_details'] != null
        ? LeadStageDetails.fromJson(json['lead_stage_details'])
        : null;
    if (json['lead_details'] != null) {
      leadDetails = <LeadDetails>[];
      json['lead_details'].forEach((v) {
        leadDetails!.add(LeadDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (leadStageDetails != null) {
      data['lead_stage_details'] = leadStageDetails!.toJson();
    }
    if (leadDetails != null) {
      data['lead_details'] = leadDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LeadStageDetails {
  String? sId;
  String? code;
  String? name;
  bool? isUserDefined;
  String? createdAt;
  String? updatedAt;
  int? iV;

  LeadStageDetails({
    this.sId,
    this.code,
    this.name,
    this.isUserDefined,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  LeadStageDetails.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    code = json['code'];
    name = json['name'];
    isUserDefined = json['is_user_defined'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['code'] = code;
    data['name'] = name;
    data['is_user_defined'] = isUserDefined;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class LeadDetails {
  Location? location;
  String? sId;
  bool? status;
  UserId? userId;
  LeadSourceId? leadSourceId;
  Name? name;
  int? phone;
  String? email;
  int? pincode;
  String? remarks;
  CompaignName? compaignName;
  LeadSourceId? assignedTo;
  String? priority;
  int? age;
  String? gender;
  String? companyName;
  String? designation;
  String? website;
  String? tenantId;
  String? createdAt;
  String? updatedAt;
  int? iV;
  LeadSourceId? leadStageId;
  List<Null>? documents;
  String? followUpDate; // Add this line
  List<dynamic>? stageFieldValues; // Add this line

  LeadDetails({
    this.location,
    this.sId,
    this.status,
    this.userId,
    this.leadSourceId,
    this.name,
    this.phone,
    this.email,
    this.pincode,
    this.remarks,
    this.compaignName,
    this.assignedTo,
    this.priority,
    this.age,
    this.gender,
    this.companyName,
    this.designation,
    this.website,
    this.tenantId,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.leadStageId,
    this.documents,
    this.followUpDate, // Add this line
    this.stageFieldValues, // Add this line
  });

  LeadDetails.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null
        ? Location.fromJson(json['location'])
        : null;
    sId = json['_id'];
    status = json['status'];
    userId = json['user_id'] != null
        ? UserId.fromJson(json['user_id'])
        : null;
    leadSourceId = json['lead_source_id'] != null
        ? LeadSourceId.fromJson(json['lead_source_id'])
        : null;
    name = json['name'] != null ? Name.fromJson(json['name']) : null;
    phone = json['phone'];
    email = json['email'];
    pincode = json['pincode'];
    remarks = json['remarks'];
    compaignName = json['campaign'] != null
        ? CompaignName.fromJson(json['campaign'])
        : null;
    assignedTo = json['assignedTo'] != null
        ? LeadSourceId.fromJson(json['assignedTo'])
        : null;
    priority = json['priority'];
    age = json['age'];
    gender = json['gender'];
    companyName = json['company_name'];
    designation = json['designation'];
    website = json['website'];
    tenantId = json['tenantId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    leadStageId = json['lead_stage_id'] != null
        ? LeadSourceId.fromJson(json['lead_stage_id'])
        : null;
    if (json['documents'] != null) {
      documents = <Null>[];
      // });
    }
    followUpDate = json['followUpDate']; // Add this line
    stageFieldValues = json['stageFieldValues']; // Add this line
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['_id'] = sId;
    data['status'] = status;
    if (userId != null) {
      data['user_id'] = userId!.toJson();
    }
    if (leadSourceId != null) {
      data['lead_source_id'] = leadSourceId!.toJson();
    }
    if (name != null) {
      data['name'] = name!.toJson();
    }
    data['phone'] = phone;
    data['email'] = email;
    data['pincode'] = pincode;
    data['remarks'] = remarks;
    if (compaignName != null) {
      data['campaign'] = compaignName?.toJson();
    }
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
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    if (leadStageId != null) {
      data['lead_stage_id'] = leadStageId!.toJson();
    }
    //   data['documents'] = this.documents!.map((v) => v.toJson()).toList();
    // }
    data['followUpDate'] = followUpDate; // Add this line
    data['stageFieldValues'] = stageFieldValues; // Add this line
    return data;
  }
}

class CompaignName {
  String? sId;
  String? name;

  CompaignName({this.sId, this.name});

  CompaignName.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    return data;
  }
}

class Location {
  String? country;
  String? state;
  String? city;

  Location({this.country, this.state, this.city});

  Location.fromJson(Map<String, dynamic> json) {
    country = json['country'] ?? '';
    state = json['state'] ?? '';
    city = json['city'] ?? '';
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

  UserId({this.sId, this.name, this.email});

  UserId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'] ?? '';
    email = json['email'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['email'] = email;
    return data;
  }
}

class LeadSourceId {
  String? sId;
  String? name;

  LeadSourceId({this.sId, this.name});

  LeadSourceId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'] ?? '';
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
  String? middle;
  String? last;

  Name({this.first, this.middle, this.last});

  Name.fromJson(Map<String, dynamic> json) {
    first = json['first'] ?? '';
    middle = json['middle'] ?? '';
    last = json['last'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first'] = first;
    data['middle'] = middle;
    data['last'] = last;
    return data;
  }
}
