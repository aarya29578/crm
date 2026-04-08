// class AllLeadDetailResponse {
//   bool? success;
//   Data? data;

//   AllLeadDetailResponse({this.success, this.data});

//   AllLeadDetailResponse.fromJson(Map<String, dynamic> json) {
//     success = json['success'];
//     data = json['data'] != null ? new Data.fromJson(json['data']) : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['success'] = this.success;
//     if (this.data != null) {
//       data['data'] = this.data!.toJson();
//     }
//     return data;
//   }
// }

// class Data {
//   Location? location;
//   String? sId;
//   String? userId;
//   Country? leadSourceId;
//   Countrys? leadStageId;
//   Name? name;
//   int? phone;
//   String? email;
//   String? address;
//   // int? pincode;
//   String? remarks;
//   CompaignName? compaignName;
//   Country? assignedTo;
//   String? priority;
//   int? age;
//   String? gender;
//   String? companyName;
//   String? designation;
//   String? website;
//   String? tenantId;
//   int? iV;
//   String? createdAt;
//   String? updatedAt;
//   // List<Null>? documents;
//   // List<dynamic>? documents;
//   List<Document>? documents;
//   List<String>? visitedStageIds;

//   Data({
//     this.location,
//     this.sId,
//     this.userId,
//     this.leadSourceId,
//     this.name,
//     this.phone,
//     this.email,
//     this.address,
//     // this.pincode,
//     this.remarks,
//     this.compaignName,
//     this.assignedTo,
//     this.priority,
//     this.age,
//     this.gender,
//     this.companyName,
//     this.designation,
//     this.website,
//     this.tenantId,
//     this.iV,
//     this.createdAt,
//     this.updatedAt,
//     this.leadStageId,
//     this.documents,
//     this.visitedStageIds,
//   });

//   Data.fromJson(Map<String, dynamic> json) {
//     location = json['location'] != null
//         ? new Location.fromJson(json['location'])
//         : null;
//     sId = json['_id'];
//     userId = json['user_id'];
//     leadSourceId = json['lead_source_id'] != null
//         ? new Country.fromJson(json['lead_source_id'])
//         : null;
//     name = json['name'] != null ? new Name.fromJson(json['name']) : null;
//     phone = json['phone'];
//     email = json['email'];
//     address = json['address'];
//     // pincode = json['pincode'] ?? "";
//     remarks = json['remarks'];
//     compaignName = json['campaignId'] != null
//         ? CompaignName.fromJson(json['campaignId'])
//         : null;
//     // assignedTo = json['assignedTo'];
//     assignedTo = json['assignedTo'] != null
//         ? new Country.fromJson(json['assignedTo'])
//         : null;
//     priority = json['priority'];
//     age = json['age'];
//     gender = json['gender'];
//     companyName = json['company_name'];
//     designation = json['designation'];
//     website = json['website'];
//     tenantId = json['tenantId'];
//     iV = json['__v'];
//     createdAt = json['createdAt'];
//     updatedAt = json['updatedAt'];
//     leadStageId = json['lead_stage_id'] != null
//         ? new Countrys.fromJson(json['lead_stage_id'])
//         : null;
//     visitedStageIds = json['visitedStageIds'] != null
//         ? List<String>.from(json['visitedStageIds'])
//         : [];
//     // if (json['documents'] != null) {
//     //   documents = <Null>[];
//     //   json['documents'].forEach((v) {
//     //     documents!.add(new Null.fromJson(v));
//     //   });
//     // }
//     // documents = json['documents'] ?? [];
//     if (json['documents'] != null) {
//       documents = (json['documents'] as List)
//           .map((e) => Document.fromJson(e))
//           .toList();
//     } else {
//       documents = [];
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.location != null) {
//       data['location'] = this.location!.toJson();
//     }
//     data['_id'] = this.sId;
//     data['user_id'] = this.userId;
//     if (this.leadSourceId != null) {
//       data['lead_source_id'] = this.leadSourceId!.toJson();
//     }
//     if (this.name != null) {
//       data['name'] = this.name!.toJson();
//     }
//     data['phone'] = this.phone;
//     data['email'] = this.email;
//     data['address'] = this.address;
//     // data['pincode'] = this.pincode;
//     data['remarks'] = this.remarks;
//     if (compaignName != null) {
//       data['campaignId'] = compaignName?.toJson();
//     }
//     // data['assignedTo'] = this.assignedTo;
//     if (this.assignedTo != null) {
//       data['assignedTo'] = this.assignedTo!.toJson();
//     }
//     data['priority'] = this.priority;
//     data['age'] = this.age;
//     data['gender'] = this.gender;
//     data['company_name'] = this.companyName;
//     data['designation'] = this.designation;
//     data['website'] = this.website;
//     data['tenantId'] = this.tenantId;
//     data['__v'] = this.iV;
//     data['createdAt'] = this.createdAt;
//     data['updatedAt'] = this.updatedAt;
//     if (this.leadStageId != null) {
//       data['lead_stage_id'] = this.leadStageId!.toJson();
//     }
//     data['visitedStageIds'] = this.visitedStageIds ?? [];
//     // if (this.documents != null) {
//     //   data['documents'] = this.documents!.map((v) => v.toJson()).toList();
//     // }
//     // data['documents'] = this.documents ?? [];
//     if (documents != null) {
//       data['documents'] = documents!.map((e) => e.toJson()).toList();
//     }

//     return data;
//   }
// }

class AllLeadDetailResponse {
  bool? success;
  Data? data;

  AllLeadDetailResponse({this.success, this.data});

  AllLeadDetailResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true;

    data = json['data'] is Map<String, dynamic>
        ? Data.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data?.toJson()};
  }
}

class Data {
  Location? location;
  String? sId;
  String? userId;
  Country? leadSourceId;
  Countrys? leadStageId;
  Name? name;
  int? phone;
  String? email;
  String? address;
  int? pincode;
  String? remarks;
  CompaignName? compaignName;
  Country? assignedTo;
  String? priority;
  int? age;
  String? gender;
  String? companyName;
  String? designation;
  String? website;
  String? tenantId;
  int? iV;
  String? createdAt;
  String? updatedAt;
  bool? status;
  String? listId;
  List<Document> documents = [];
  List<String> visitedStageIds = [];
  List<dynamic> customList = [];

  Data();

  Data.fromJson(Map<String, dynamic> json) {
    location = json['location'] is Map
        ? Location.fromJson(json['location'])
        : null;

    sId = json['_id']?.toString();
    userId = json['user_id']?.toString();

    leadSourceId = json['lead_source_id'] is Map
        ? Country.fromJson(json['lead_source_id'])
        : null;

    leadStageId = json['lead_stage_id'] is Map
        ? Countrys.fromJson(json['lead_stage_id'])
        : null;

    name = json['name'] is Map ? Name.fromJson(json['name']) : null;

    phone = json['phone'] is int
        ? json['phone']
        : int.tryParse(json['phone']?.toString() ?? '');

    email = json['email']?.toString();
    address = json['address']?.toString();
    pincode = json['pincode'] is int
        ? json['pincode']
        : int.tryParse(json['pincode']?.toString() ?? '');

    remarks = json['remarks']?.toString();

    /// 🔥 SAFE campaignId handling (IMPORTANT)
    if (json['campaign'] is Map) {
      compaignName = CompaignName.fromJson(json['campaign']);
    } else if (json['campaign'] is String) {
      compaignName = CompaignName(sId: json['campaign']);
    } else {
      compaignName = null;
    }

    assignedTo = json['assignedTo'] is Map
        ? Country.fromJson(json['assignedTo'])
        : null;

    priority = json['priority']?.toString();

    age = json['age'] is int
        ? json['age']
        : int.tryParse(json['age']?.toString() ?? '');

    gender = json['gender']?.toString();
    companyName = json['company_name']?.toString();
    designation = json['designation']?.toString();
    website = json['website']?.toString();
    tenantId = json['tenantId']?.toString();

    iV = json['__v'] is int
        ? json['__v']
        : int.tryParse(json['__v']?.toString() ?? '');

    createdAt = json['createdAt']?.toString();
    updatedAt = json['updatedAt']?.toString();

    status = json['status'] == true;
    listId = json['listId']?.toString();

    /// Documents
    if (json['documents'] is List) {
      documents = (json['documents'] as List)
          .map((e) => Document.fromJson(e))
          .toList();
    }

    /// visitedStageIds
    if (json['visitedStageIds'] is List) {
      visitedStageIds = List<String>.from(
        json['visitedStageIds'].map((e) => e.toString()),
      );
    }

    /// customList
    if (json['customList'] is List) {
      customList = json['customList'];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location?.toJson(),
      '_id': sId,
      'user_id': userId,
      'lead_source_id': leadSourceId?.toJson(),
      'lead_stage_id': leadStageId?.toJson(),
      'name': name?.toJson(),
      'phone': phone,
      'email': email,
      'address': address,
      'pincode': pincode,
      'remarks': remarks,
      'compaignName': compaignName?.toJson(),
      'assignedTo': assignedTo?.toJson(),
      'priority': priority,
      'age': age,
      'gender': gender,
      'company_name': companyName,
      'designation': designation,
      'website': website,
      'tenantId': tenantId,
      '__v': iV,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'status': status,
      'listId': listId,
      'documents': documents.map((e) => e.toJson()).toList(),
      'visitedStageIds': visitedStageIds,
      'customList': customList,
    };
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

class Document {
  String? id;
  String? filename;
  String? originalName;
  String? uploadDate;
  int? size;
  String? mimetype;
  String? documentUrl;

  Document({
    this.id,
    this.filename,
    this.originalName,
    this.uploadDate,
    this.size,
    this.mimetype,
    this.documentUrl,
  });

  Document.fromJson(Map<String, dynamic> json) {
    id = json['_id'] ?? '';
    filename = json['filename'] ?? '';
    originalName = json['originalName'] ?? '';
    uploadDate = json['uploadDate'];
    size = json['size'] ?? 0;
    mimetype = json['mimetype'] ?? '';
    documentUrl = json['url'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = id;
    data['filename'] = filename;
    data['originalName'] = originalName;
    data['uploadDate'] = uploadDate;
    data['size'] = size;
    data['mimetype'] = mimetype;
    data['url'] = documentUrl;
    return data;
  }
}

class Location {
  Country? country;
  Country? state;
  Country? city;

  Location({this.country, this.state, this.city});

  Location.fromJson(Map<String, dynamic> json) {
    country = json['country'] != null
        ? new Country.fromJson(json['country'])
        : null;
    state = json['state'] != null ? new Country.fromJson(json['state']) : null;
    city = json['city'] != null ? new Country.fromJson(json['city']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.country != null) {
      data['country'] = this.country!.toJson();
    }
    if (this.state != null) {
      data['state'] = this.state!.toJson();
    }
    if (this.city != null) {
      data['city'] = this.city!.toJson();
    }

    return data;
  }
}

class Country {
  String? sId;
  String? name;

  Country({this.sId, this.name});

  Country.fromJson(Map<String, dynamic> json) {
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

class Countrys {
  String? sId;
  String? name;
  String? color;

  Countrys({this.sId, this.name, this.color});

  Countrys.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'] ?? '';
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['color'] = this.color;
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
