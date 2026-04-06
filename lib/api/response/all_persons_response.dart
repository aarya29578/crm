class AllPersonResponse {
  bool? success;
  int? results;
  int? totalPages;
  int? currentPage;
  List<Data>? data;

  AllPersonResponse({
    this.success,
    this.results,
    this.totalPages,
    this.currentPage,
    this.data,
  });

  AllPersonResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    results = json['results'];
    totalPages = json['totalPages'];
    currentPage = json['currentPage'];
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
    data['results'] = this.results;
    data['totalPages'] = this.totalPages;
    data['currentPage'] = this.currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? sId;
  String? name;
  List<String>? emails;
  List<String>? contactNumbers;
  String? jobTitle;
  String? organizationId;
  String? userId;
  String? createdAt;
  String? updatedAt;
  int? iV;
  Organization? organization;

  Data({
    this.sId,
    this.name,
    this.emails,
    this.contactNumbers,
    this.jobTitle,
    this.organizationId,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.organization,
  });

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    emails = json['emails'].cast<String>();
    contactNumbers = json['contact_numbers'].cast<String>();
    jobTitle = json['job_title'];
    organizationId = json['organization_id'];
    userId = json['user_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    organization =
        json['organization'] != null
            ? new Organization.fromJson(json['organization'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['emails'] = this.emails;
    data['contact_numbers'] = this.contactNumbers;
    data['job_title'] = this.jobTitle;
    data['organization_id'] = this.organizationId;
    data['user_id'] = this.userId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    if (this.organization != null) {
      data['organization'] = this.organization!.toJson();
    }
    return data;
  }
}

class Organization {
  String? sId;
  String? name;
  Address? address;
  String? userId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Organization({
    this.sId,
    this.name,
    this.address,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Organization.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    address =
        json['address'] != null ? new Address.fromJson(json['address']) : null;
    userId = json['user_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    if (this.address != null) {
      data['address'] = this.address!.toJson();
    }
    data['user_id'] = this.userId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class Address {
  String? street;
  String? city;
  String? state;
  String? zip;

  Address({this.street, this.city, this.state, this.zip});

  Address.fromJson(Map<String, dynamic> json) {
    street = json['street'];
    city = json['city'];
    state = json['state'];
    zip = json['zip'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['street'] = this.street;
    data['city'] = this.city;
    data['state'] = this.state;
    data['zip'] = this.zip;
    return data;
  }
}
