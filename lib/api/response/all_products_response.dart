class AllProductResponse {
  int? status;
  int? total;
  bool? success;
  int? currentPage;
  int? totalPages;
  List<Data>? data;

  AllProductResponse({
    this.status,
    this.total,
    this.success,
    this.currentPage,
    this.totalPages,
    this.data,
  });

  AllProductResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    total = json['total'];
    success = json['success'];
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
    data['success'] = this.success;
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
  int? sku;
  String? name;
  String? description;
  int? quantity;
  Price? price;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data({
    this.sId,
    this.sku,
    this.name,
    this.description,
    this.quantity,
    this.price,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    sku = json['sku'];
    name = json['name'];
    description = json['description'];
    quantity = json['quantity'];
    price = json['price'] != null ? new Price.fromJson(json['price']) : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['sku'] = this.sku;
    data['name'] = this.name;
    data['description'] = this.description;
    data['quantity'] = this.quantity;
    if (this.price != null) {
      data['price'] = this.price!.toJson();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class Price {
  String? numberDecimal;

  Price({this.numberDecimal});

  Price.fromJson(Map<String, dynamic> json) {
    numberDecimal = json['\$numberDecimal'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['\$numberDecimal'] = this.numberDecimal;
    return data;
  }
}
