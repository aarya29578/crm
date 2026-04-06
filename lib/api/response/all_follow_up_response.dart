class FollowUpResponse {
  bool? success;
  List<FollowUpData>? data;
  int? total;
  int? totalPages;
  int? currentPage;

  FollowUpResponse({
    this.success,
    this.data,
    this.total,
    this.totalPages,
    this.currentPage,
  });

  factory FollowUpResponse.fromJson(Map<String, dynamic> json) {
    return FollowUpResponse(
      success: json['success'],
      data: (json['data'] as List?)
          ?.map((e) => FollowUpData.fromJson(e))
          .toList(),
      total: json['total'],
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data?.map((e) => e.toJson()).toList(),
    'total': total,
    'totalPages': totalPages,
    'currentPage': currentPage,
  };
}

class FollowUpData {
  String? id;
  Location? location;
  User? userId;
  SimpleRef? leadSourceId;
  LeadStage? leadStageId;
  Name? name;
  int? phone;
  String? email;
  String? address;
  int? pincode;
  String? remarks;
  String? campaignId;
  String? poolStatus;
  List<dynamic>? rejectedBy;
  AssignedTo? assignedTo;
  String? priority;
  int? age;
  String? gender;
  String? companyName;
  String? designation;
  String? website;
  Tenant? tenantId;
  String? listId;
  List<dynamic>? customList;
  List<Document>? documents;
  String? createdAt;
  String? updatedAt;
  bool? status;
  String? followUpDate;

  FollowUpData({
    this.id,
    this.location,
    this.userId,
    this.leadSourceId,
    this.leadStageId,
    this.name,
    this.phone,
    this.email,
    this.address,
    this.pincode,
    this.remarks,
    this.campaignId,
    this.poolStatus,
    this.rejectedBy,
    this.assignedTo,
    this.priority,
    this.age,
    this.gender,
    this.companyName,
    this.designation,
    this.website,
    this.tenantId,
    this.listId,
    this.customList,
    this.documents,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.followUpDate,
  });

  factory FollowUpData.fromJson(Map<String, dynamic> json) {
    return FollowUpData(
      id: json['_id'],
      location: json['location'] != null
          ? Location.fromJson(json['location'])
          : null,
      userId: json['user_id'] != null ? User.fromJson(json['user_id']) : null,
      leadSourceId: json['lead_source_id'] != null
          ? SimpleRef.fromJson(json['lead_source_id'])
          : null,
      leadStageId: json['lead_stage_id'] != null
          ? LeadStage.fromJson(json['lead_stage_id'])
          : null,
      name: json['name'] != null ? Name.fromJson(json['name']) : null,
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      pincode: json['pincode'],
      remarks: json['remarks'],
      campaignId: json['campaignId'],
      poolStatus: json['poolStatus'],
      rejectedBy: json['rejectedBy'],
      assignedTo: json['assignedTo'] != null
          ? AssignedTo.fromJson(json['assignedTo'])
          : null,
      priority: json['priority'],
      age: json['age'],
      gender: json['gender'],
      companyName: json['company_name'],
      designation: json['designation'],
      website: json['website'],
      tenantId: json['tenantId'] != null
          ? Tenant.fromJson(json['tenantId'])
          : null,
      listId: json['listId'],
      customList: json['customList'],
      documents: (json['documents'] as List?)
          ?.map((e) => Document.fromJson(e))
          .toList(),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      status: json['status'],
      followUpDate: json['followUpDate'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'location': location?.toJson(),
    'user_id': userId?.toJson(),
    'lead_source_id': leadSourceId?.toJson(),
    'lead_stage_id': leadStageId?.toJson(),
    'name': name?.toJson(),
    'phone': phone,
    'email': email,
    'address': address,
    'pincode': pincode,
    'remarks': remarks,
    'campaignId': campaignId,
    'poolStatus': poolStatus,
    'rejectedBy': rejectedBy,
    'assignedTo': assignedTo?.toJson(),
    'priority': priority,
    'age': age,
    'gender': gender,
    'company_name': companyName,
    'designation': designation,
    'website': website,
    'tenantId': tenantId?.toJson(),
    'listId': listId,
    'customList': customList,
    'documents': documents?.map((e) => e.toJson()).toList(),
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'status': status,
    'followUpDate': followUpDate,
  };
}

class Location {
  SimpleRef? country;
  SimpleRef? state;
  SimpleRef? city;

  Location({this.country, this.state, this.city});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      country: json['country'] != null
          ? SimpleRef.fromJson(json['country'])
          : null,
      state: json['state'] != null ? SimpleRef.fromJson(json['state']) : null,
      city: json['city'] != null ? SimpleRef.fromJson(json['city']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'country': country?.toJson(),
    'state': state?.toJson(),
    'city': city?.toJson(),
  };
}

class SimpleRef {
  String? id;
  String? name;

  SimpleRef({this.id, this.name});

  factory SimpleRef.fromJson(Map<String, dynamic> json) {
    return SimpleRef(id: json['_id'], name: json['name']);
  }

  Map<String, dynamic> toJson() => {'_id': id, 'name': name};
}

class LeadStage {
  String? id;
  String? name;
  String? color;

  LeadStage({this.id, this.name, this.color});

  factory LeadStage.fromJson(Map<String, dynamic> json) {
    return LeadStage(id: json['_id'], name: json['name'], color: json['color']);
  }

  Map<String, dynamic> toJson() => {'_id': id, 'name': name, 'color': color};
}

class User {
  String? id;
  String? name;
  String? email;

  User({this.id, this.name, this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['_id'], name: json['name'], email: json['email']);
  }

  Map<String, dynamic> toJson() => {'_id': id, 'name': name, 'email': email};
}

class AssignedTo {
  String? id;
  String? name;

  AssignedTo({this.id, this.name});

  factory AssignedTo.fromJson(Map<String, dynamic> json) {
    return AssignedTo(id: json['_id'], name: json['name']);
  }

  Map<String, dynamic> toJson() => {'_id': id, 'name': name};
}

class Name {
  String? first;
  String? last;
  String? middle;

  Name({this.first, this.last, this.middle});

  factory Name.fromJson(Map<String, dynamic> json) {
    return Name(
      first: json['first'],
      last: json['last'],
      middle: json['middle'],
    );
  }

  Map<String, dynamic> toJson() => {
    'first': first,
    'last': last,
    'middle': middle,
  };
}

class Tenant {
  String? id;
  String? service;

  Tenant({this.id, this.service});

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(id: json['_id'], service: json['service']);
  }

  Map<String, dynamic> toJson() => {'_id': id, 'service': service};
}

class Document {
  String? id;
  String? filename;
  String? originalName;
  String? uploadDate;
  int? size;
  String? mimetype;

  Document({
    this.id,
    this.filename,
    this.originalName,
    this.uploadDate,
    this.size,
    this.mimetype,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['_id'],
      filename: json['filename'],
      originalName: json['originalName'],
      uploadDate: json['uploadDate'],
      size: json['size'],
      mimetype: json['mimetype'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'filename': filename,
    'originalName': originalName,
    'uploadDate': uploadDate,
    'size': size,
    'mimetype': mimetype,
  };
}
