// class AllLeadsResponse {
//   bool? success;
//   int? total;
//   int? totalPages;
//   int? currentPage;
//   List<Data>? data;
//   AllLeadsResponse({
//     this.success,
//     this.total,
//     this.totalPages,
//     this.currentPage,
//     this.data,
//   });
//   AllLeadsResponse.fromJson(Map<String, dynamic> json) {
//     success = json['success'];
//     total = json['total'];
//     totalPages = json['totalPages'];
//     currentPage = json['currentPage'];
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
//     data['total'] = this.total;
//     data['totalPages'] = this.totalPages;
//     data['currentPage'] = this.currentPage;
//     if (this.data != null) {
//       data['data'] = this.data!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }

// class Data {
//   String? sId;
//   UserId? userId;
//   LeadSourceId? leadSourceId;
//   LeadStageId? leadStageId;
//   Name? name;
//   int? phone;
//   String? email;
//   String? address;
//   int? pincode;
//   String? remarks;
//   LeadSourceId? assignedTo;
//   String? priority;
//   int? age;
//   String? gender;
//   String? companyName;
//   String? designation;
//   String? website;
//   TenantId? tenantId;
//   List<Documents>? documents;
//   List<CustomList>? customList;
//   String? createdAt;
//   String? updatedAt;
//   int? iV;
//   bool? status;
//   Location? location;
//   String? listId;
//   DateTime? followUpDate;

//   Data({
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
//     this.location,
//     this.listId,
//     this.followUpDate,
//   });
//   Data.fromJson(Map<String, dynamic> json) {
//     sId = json['_id'];
//     userId = json['user_id'] != null
//         ? new UserId.fromJson(json['user_id'])
//         : null;
//     leadSourceId = json['lead_source_id'] != null
//         ? new LeadSourceId.fromJson(json['lead_source_id'])
//         : null;
//     leadStageId = json['lead_stage_id'] != null
//         ? new LeadStageId.fromJson(json['lead_stage_id'])
//         : null;
//     name = json['name'] != null ? new Name.fromJson(json['name']) : null;
//     phone = json['phone'];
//     email = json['email'];
//     address = json['address'];
//     pincode = json['pincode'];
//     remarks = json['remarks'];
//     assignedTo = json['assignedTo'] != null
//         ? new LeadSourceId.fromJson(json['assignedTo'])
//         : null;
//     priority = json['priority'];
//     age = json['age'];
//     gender = json['gender'];
//     companyName = json['company_name'];
//     designation = json['designation'];
//     website = json['website'];
//     tenantId = json['tenantId'] != null
//         ? new TenantId.fromJson(json['tenantId'])
//         : null;
//     if (json['documents'] != null) {
//       documents = <Documents>[];
//       json['documents'].forEach((v) {
//         documents!.add(new Documents.fromJson(v));
//       });
//     }
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
//     location = json['location'] != null
//         ? new Location.fromJson(json['location'])
//         : null;
//     listId = json['listId'];
//     // followUpDate = json['followUpDate'];
//     followUpDate = json['followUpDate'] != null
//         ? DateTime.tryParse(json['followUpDate'])
//         : null;
//   }
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['_id'] = this.sId;
//     if (this.userId != null) {
//       data['user_id'] = this.userId!.toJson();
//     }
//     if (this.leadSourceId != null) {
//       data['lead_source_id'] = this.leadSourceId!.toJson();
//     }
//     if (this.leadStageId != null) {
//       data['lead_stage_id'] = this.leadStageId!.toJson();
//     }
//     if (this.name != null) {
//       data['name'] = this.name!.toJson();
//     }
//     data['phone'] = this.phone;
//     data['email'] = this.email;
//     data['address'] = this.address;
//     data['pincode'] = this.pincode;
//     data['remarks'] = this.remarks;
//     if (this.assignedTo != null) {
//       data['assignedTo'] = this.assignedTo!.toJson();
//     }
//     data['priority'] = this.priority;
//     data['age'] = this.age;
//     data['gender'] = this.gender;
//     data['company_name'] = this.companyName;
//     data['designation'] = this.designation;
//     data['website'] = this.website;
//     if (this.tenantId != null) {
//       data['tenantId'] = this.tenantId!.toJson();
//     }
//     if (this.documents != null) {
//       data['documents'] = this.documents!.map((v) => v.toJson()).toList();
//     }
//     if (this.customList != null) {
//       data['customList'] = this.customList!.map((v) => v.toJson()).toList();
//     }
//     data['createdAt'] = this.createdAt;
//     data['updatedAt'] = this.updatedAt;
//     data['__v'] = this.iV;
//     data['status'] = this.status;
//     if (this.location != null) {
//       data['location'] = this.location!.toJson();
//     }
//     data['listId'] = this.listId;
//     // data['followUpDate'] = this.followUpDate;
//     data['followUpDate'] = this.followUpDate?.toIso8601String();
//     return data;
//   }
// }

// class UserId {
//   String? sId;
//   String? name;
//   String? email;
//   UserId({this.sId, this.name, this.email});
//   UserId.fromJson(Map<String, dynamic> json) {
//     sId = json['_id'];
//     name = json['name'];
//     email = json['email'];
//   }
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['_id'] = this.sId;
//     data['name'] = this.name;
//     data['email'] = this.email;
//     return data;
//   }
// }

// class LeadSourceId {
//   String? sId;
//   String? name;
//   LeadSourceId({this.sId, this.name});
//   LeadSourceId.fromJson(Map<String, dynamic> json) {
//     sId = json['_id'];
//     name = json['name'];
//   }
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['_id'] = this.sId;
//     data['name'] = this.name;
//     return data;
//   }
// }

// class LeadStageId {
//   String? sId;
//   String? name;
//   String? color;
//   String? connected;
//   LeadStageId({this.sId, this.name, this.color, this.connected});
//   LeadStageId.fromJson(Map<String, dynamic> json) {
//     sId = json['_id'];
//     name = json['name'];
//     color = json['color'];
//     connected = json['connected'];
//   }
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['_id'] = this.sId;
//     data['name'] = this.name;
//     data['color'] = this.color;
//     data['connected'] = this.connected;
//     return data;
//   }
// }

// class Name {
//   String? first;
//   String? last;
//   String? middle;
//   Name({this.first, this.last, this.middle});
//   Name.fromJson(Map<String, dynamic> json) {
//     first = json['first'];
//     last = json['last'];
//     middle = json['middle'];
//   }
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['first'] = this.first;
//     data['last'] = this.last;
//     data['middle'] = this.middle;
//     return data;
//   }
// }

// class TenantId {
//   String? sId;
//   String? service;
//   TenantId({this.sId, this.service});
//   TenantId.fromJson(Map<String, dynamic> json) {
//     sId = json['_id'];
//     service = json['service'];
//   }
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['_id'] = this.sId;
//     data['service'] = this.service;
//     return data;
//   }
// }

// class Documents {
//   String? filename;
//   String? originalName;
//   String? uploadDate;
//   int? size;
//   String? mimetype;
//   String? sId;
//   Documents({
//     this.filename,
//     this.originalName,
//     this.uploadDate,
//     this.size,
//     this.mimetype,
//     this.sId,
//   });
//   Documents.fromJson(Map<String, dynamic> json) {
//     filename = json['filename'];
//     originalName = json['originalName'];
//     uploadDate = json['uploadDate'];
//     size = json['size'];
//     mimetype = json['mimetype'];
//     sId = json['_id'];
//   }
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['filename'] = this.filename;
//     data['originalName'] = this.originalName;
//     data['uploadDate'] = this.uploadDate;
//     data['size'] = this.size;
//     data['mimetype'] = this.mimetype;
//     data['_id'] = this.sId;
//     return data;
//   }
// }

// class CustomList {
//   String? label;
//   List<String>? value;
//   String? sId;
//   CustomList({this.label, this.value, this.sId});
//   CustomList.fromJson(Map<String, dynamic> json) {
//     label = json['label'];
//     value = json['value'].cast<String>();
//     sId = json['_id'];
//   }
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['label'] = this.label;
//     data['value'] = this.value;
//     data['_id'] = this.sId;
//     return data;
//   }
// }

// class Location {
//   LeadSourceId? country;
//   LeadSourceId? state;
//   LeadSourceId? city;
//   Location({this.country, this.state, this.city});
//   Location.fromJson(Map<String, dynamic> json) {
//     country = json['country'] != null
//         ? new LeadSourceId.fromJson(json['country'])
//         : null;
//     state = json['state'] != null
//         ? new LeadSourceId.fromJson(json['state'])
//         : null;
//     city = json['city'] != null
//         ? new LeadSourceId.fromJson(json['city'])
//         : null;
//   }
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.country != null) {
//       data['country'] = this.country!.toJson();
//     }
//     if (this.state != null) {
//       data['state'] = this.state!.toJson();
//     }
//     if (this.city != null) {
//       data['city'] = this.city!.toJson();
//     }
//     return data;
//   }
// }

import 'package:intl/intl.dart';

/////////////////////////////2
class AllLeadsResponse {
  bool? success;
  int? total;
  int? totalPages;
  int? currentPage;
  List<Data>? data;

  AllLeadsResponse({
    this.success,
    this.total,
    this.totalPages,
    this.currentPage,
    this.data,
  });

  AllLeadsResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    total = json['total'];
    totalPages = json['totalPages'];
    currentPage = json['currentPage'];
    // if (json['data'] != null) {
    //   data = <Data>[];
    //   json['data'].forEach((v) {
    //     data!.add(Data.fromJson(v));
    //   });
    // }
    if (json['data'] != null) {
      final List<dynamic> dataList = json['data'];
      data = dataList.map((v) => Data.fromJson(v)).toList();
    } else {
      data = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['total'] = total;
    data['totalPages'] = totalPages;
    data['currentPage'] = currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? sId;
  UserId? userId;
  LeadSourceId? leadSourceId;
  LeadStageId? leadStageId;
  Name? name;
  int? phone;
  String? email;
  String? address;
  int? pincode;
  String? remarks;
  CompaignName? compaignName;
  AssignedTo? assignedTo;
  String? priority;
  int? age;
  String? gender;
  String? companyName;
  String? designation;
  String? website;
  TenantId? tenantId;
  List<Documents>? documents;
  List<CustomList>? customList;
  String? createdAt;
  String? updatedAt;
  int? iV;
  bool? status;
  Location? location;
  String? listId;
  DateTime? followUpDate;
  List<Timeline>? timeline; // <-- ADD THIS LINE

  Data({
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
    this.compaignName,
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
    this.location,
    this.listId,
    this.followUpDate,
    this.timeline, // <-- ADD THIS LINE
  });

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['user_id'] != null ? UserId.fromJson(json['user_id']) : null;
    leadSourceId = json['lead_source_id'] != null
        ? LeadSourceId.fromJson(json['lead_source_id'])
        : null;
    leadStageId = json['lead_stage_id'] != null
        ? LeadStageId.fromJson(json['lead_stage_id'])
        : null;
    name = json['name'] != null ? Name.fromJson(json['name']) : null;
    phone = json['phone'];
    email = json['email'];
    address = json['address'] ?? '';
    pincode = json['pincode'];
    remarks = json['remarks'] ?? '';
    compaignName = json['campaignId'] != null
        ? CompaignName.fromJson(json['campaignId'])
        : null;
    assignedTo = json['assignedTo'] != null
        ? AssignedTo.fromJson(json['assignedTo'])
        : null;
    priority = json['priority']?.toString();
    age = json['age'];
    gender = json['gender']?.toString();
    companyName = json['company_name'] ?? '';
    designation = json['designation'] ?? '';
    website = json['website'] ?? '';
    tenantId = json['tenantId'] != null
        ? TenantId.fromJson(json['tenantId'])
        : null;

    // Handle documents
    if (json['documents'] != null && json['documents'] is List) {
      documents = (json['documents'] as List)
          .map((v) => Documents.fromJson(v))
          .toList();
    } else {
      documents = [];
    }

    // Handle customList
    if (json['customList'] != null && json['customList'] is List) {
      customList = (json['customList'] as List)
          .map((v) => CustomList.fromJson(v))
          .toList();
    } else {
      customList = [];
    }

    // Handle timeline - ADD THIS SECTION
    if (json['timeline'] != null && json['timeline'] is List) {
      timeline = (json['timeline'] as List)
          .map((v) => Timeline.fromJson(v))
          .toList();
    } else {
      timeline = [];
    }

    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    status = json['status'];
    location = json['location'] != null
        ? Location.fromJson(json['location'])
        : null;
    listId = json['listId'];
    followUpDate = json['followUpDate'] != null
        ? DateTime.tryParse(json['followUpDate'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (userId != null) {
      data['user_id'] = userId!.toJson();
    }
    if (leadSourceId != null) {
      data['lead_source_id'] = leadSourceId!.toJson();
    }
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
    if (compaignName != null) {
      data['campaignId'] = compaignName?.toJson();
    }
    if (assignedTo != null) {
      data['assignedTo'] = assignedTo?.toJson();
    }
    data['priority'] = priority;
    data['age'] = age;
    data['gender'] = gender;
    data['company_name'] = companyName;
    data['designation'] = designation;
    data['website'] = website;
    if (tenantId != null) {
      data['tenantId'] = tenantId!.toJson();
    }
    if (documents != null) {
      data['documents'] = documents!.map((v) => v.toJson()).toList();
    }
    if (customList != null) {
      data['customList'] = customList!.map((v) => v.toJson()).toList();
    }
    if (timeline != null) {
      // <-- ADD THIS
      data['timeline'] = timeline!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['status'] = status;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['listId'] = listId;
    data['followUpDate'] = followUpDate?.toIso8601String();
    return data;
  }
}

// Add this new class
class Timeline {
  String? stage;
  String? note;
  String? agent;
  String? action;
  String? date;

  Timeline({this.stage, this.note, this.agent, this.action, this.date});

  Timeline.fromJson(Map<String, dynamic> json) {
    stage = json['stage'] ?? '';
    note = json['note'] ?? '';
    agent = json['agent'] ?? '';
    action = json['action'] ?? '';
    date = json['date'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stage'] = stage;
    data['note'] = note;
    data['agent'] = agent;
    data['action'] = action;
    data['date'] = date;
    return data;
  }
}

String formatTimelineDate(String? date) {
  if (date == null || date.isEmpty) return "No date";

  try {
    final parsedDate = DateTime.parse(date).toLocal();
    return DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate);
  } catch (e) {
    return date;
  }
}

class UserId {
  String? sId;
  String? name;
  String? email;

  UserId({this.sId, this.name, this.email});

  UserId.fromJson(Map<String, dynamic> json) {
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

class LeadSourceId {
  String? sId;
  String? name;

  LeadSourceId({this.sId, this.name});

  LeadSourceId.fromJson(Map<String, dynamic> json) {
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

class LeadStageId {
  String? sId;
  String? name;
  String? color;
  // bool? connected;
  // String? connected;

  LeadStageId({this.sId, this.name, this.color});

  LeadStageId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    color = json['color'];
    // connected = json['connected'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['color'] = color;
    // data['connected'] = connected;
    return data;
  }
}

class CompaignName {
  String? sId;
  String? name;

  CompaignName({this.sId, this.name});

  CompaignName.fromJson(Map<String, dynamic> json) {
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

class TenantId {
  String? sId;
  String? service;

  TenantId({this.sId, this.service});

  TenantId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    service = json['service'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['service'] = service;
    return data;
  }
}

class Documents {
  String? filename;
  String? originalName;
  String? uploadDate;
  int? size;
  String? mimetype;
  String? sId;

  Documents({
    this.filename,
    this.originalName,
    this.uploadDate,
    this.size,
    this.mimetype,
    this.sId,
  });

  Documents.fromJson(Map<String, dynamic> json) {
    filename = json['filename'];
    originalName = json['originalName'];
    uploadDate = json['uploadDate'];
    size = json['size'];
    mimetype = json['mimetype'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['filename'] = filename;
    data['originalName'] = originalName;
    data['uploadDate'] = uploadDate;
    data['size'] = size;
    data['mimetype'] = mimetype;
    data['_id'] = sId;
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
    if (json['value'] != null) {
      value = List<String>.from(json['value']);
    } else {
      value = [];
    }
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
  Country? country;
  State? state;
  City? city;

  Location({this.country, this.state, this.city});

  Location.fromJson(Map<String, dynamic> json) {
    country = json['country'] != null && json['country'] is Map
        ? Country.fromJson(json['country'])
        : null;
    state = json['state'] != null && json['state'] is Map
        ? State.fromJson(json['state'])
        : null;
    city = json['city'] != null && json['city'] is Map
        ? City.fromJson(json['city'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (country != null) {
      data['country'] = country!.toJson();
    }
    if (state != null) {
      data['state'] = state!.toJson();
    }
    if (city != null) {
      data['city'] = city!.toJson();
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
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    return data;
  }
}

class State {
  String? sId;
  String? name;

  State({this.sId, this.name});

  State.fromJson(Map<String, dynamic> json) {
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

class City {
  String? sId;
  String? name;

  City({this.sId, this.name});

  City.fromJson(Map<String, dynamic> json) {
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
