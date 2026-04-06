class GetLeadbyStageRes {
  bool? success;
  LeadStageDetails? leadStageDetails;
  List<LeadDetails>? leadDetails;

  GetLeadbyStageRes({this.success, this.leadStageDetails, this.leadDetails});

  GetLeadbyStageRes.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    leadStageDetails = json['lead_stage_details'] != null
        ? new LeadStageDetails.fromJson(json['lead_stage_details'])
        : null;
    if (json['lead_details'] != null) {
      leadDetails = <LeadDetails>[];
      json['lead_details'].forEach((v) {
        leadDetails!.add(new LeadDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.leadStageDetails != null) {
      data['lead_stage_details'] = this.leadStageDetails!.toJson();
    }
    if (this.leadDetails != null) {
      data['lead_details'] = this.leadDetails!.map((v) => v.toJson()).toList();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['code'] = this.code;
    data['name'] = this.name;
    data['is_user_defined'] = this.isUserDefined;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
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
  });

  LeadDetails.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null
        ? new Location.fromJson(json['location'])
        : null;
    sId = json['_id'];
    status = json['status'];
    userId = json['user_id'] != null
        ? new UserId.fromJson(json['user_id'])
        : null;
    leadSourceId = json['lead_source_id'] != null
        ? new LeadSourceId.fromJson(json['lead_source_id'])
        : null;
    name = json['name'] != null ? new Name.fromJson(json['name']) : null;
    phone = json['phone'];
    email = json['email'];
    pincode = json['pincode'];
    remarks = json['remarks'];
    compaignName = json['campaignId'] != null
        ? CompaignName.fromJson(json['campaignId'])
        : null;
    assignedTo = json['assignedTo'] != null
        ? new LeadSourceId.fromJson(json['assignedTo'])
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
        ? new LeadSourceId.fromJson(json['lead_stage_id'])
        : null;
    if (json['documents'] != null) {
      documents = <Null>[];
      // json['documents'].forEach((v) {
      //   documents!.add(new Null.fromJson(v));
      // });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.location != null) {
      data['location'] = this.location!.toJson();
    }
    data['_id'] = this.sId;
    data['status'] = this.status;
    if (this.userId != null) {
      data['user_id'] = this.userId!.toJson();
    }
    if (this.leadSourceId != null) {
      data['lead_source_id'] = this.leadSourceId!.toJson();
    }
    if (this.name != null) {
      data['name'] = this.name!.toJson();
    }
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['pincode'] = this.pincode;
    data['remarks'] = this.remarks;
    if (compaignName != null) {
      data['campaignId'] = compaignName?.toJson();
    }
    if (this.assignedTo != null) {
      data['assignedTo'] = this.assignedTo!.toJson();
    }
    data['priority'] = this.priority;
    data['age'] = this.age;
    data['gender'] = this.gender;
    data['company_name'] = this.companyName;
    data['designation'] = this.designation;
    data['website'] = this.website;
    data['tenantId'] = this.tenantId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    if (this.leadStageId != null) {
      data['lead_stage_id'] = this.leadStageId!.toJson();
    }
    // if (this.documents != null) {
    //   data['documents'] = this.documents!.map((v) => v.toJson()).toList();
    // }
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['country'] = this.country;
    data['state'] = this.state;
    data['city'] = this.city;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['first'] = this.first;
    data['middle'] = this.middle;
    data['last'] = this.last;
    return data;
  }
}
