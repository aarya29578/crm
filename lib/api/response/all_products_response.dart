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
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['total'] = total;
    data['success'] = success;
    data['currentPage'] = currentPage;
    data['totalPages'] = totalPages;
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
    price = json['price'] != null ? Price.fromJson(json['price']) : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['sku'] = sku;
    data['name'] = name;
    data['description'] = description;
    data['quantity'] = quantity;
    if (price != null) {
      data['price'] = price!.toJson();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['\$numberDecimal'] = numberDecimal;
    return data;
  }
}
