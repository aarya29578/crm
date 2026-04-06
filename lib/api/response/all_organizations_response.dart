class AllOrganizationResponse {
  int? status;
  int? total;
  int? currentPage;
  int? totalPages;
  List<Data>? data;

  AllOrganizationResponse({
    this.status,
    this.total,
    this.currentPage,
    this.totalPages,
    this.data,
  });

  AllOrganizationResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    total = json['total'];
    currentPage = json['currentPage'];
    totalPages = json['totalPages'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['total'] = this.total;
    data['currentPage'] = this.currentPage;
    data['totalPages'] = this.totalPages;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? sId;
  String? name;
  Address? address;
  String? userId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data({
    this.sId,
    this.name,
    this.address,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Data.fromJson(Map<String, dynamic> json) {
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
