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
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['results'] = results;
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
            ? Organization.fromJson(json['organization'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['emails'] = emails;
    data['contact_numbers'] = contactNumbers;
    data['job_title'] = jobTitle;
    data['organization_id'] = organizationId;
    data['user_id'] = userId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    if (organization != null) {
      data['organization'] = organization!.toJson();
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
        json['address'] != null ? Address.fromJson(json['address']) : null;
    userId = json['user_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    if (address != null) {
      data['address'] = address!.toJson();
    }
    data['user_id'] = userId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['street'] = street;
    data['city'] = city;
    data['state'] = state;
    data['zip'] = zip;
    return data;
  }
}
