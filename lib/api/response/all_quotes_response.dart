class AllQuoteResponse {
  int? status;
  int? total;
  bool? success;
  int? currentPage;
  int? totalPages;
  List<Data>? data;

  AllQuoteResponse({
    this.status,
    this.total,
    this.success,
    this.currentPage,
    this.totalPages,
    this.data,
  });

  AllQuoteResponse.fromJson(Map<String, dynamic> json) {
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
  String? subject;
  String? description;
  BillingAddress? billingAddress;
  BillingAddress? shippingAddress;
  DiscountPercent? discountPercent;
  DiscountPercent? discountAmount;
  DiscountPercent? taxAmount;
  DiscountPercent? adjustmentAmount;
  DiscountPercent? subTotal;
  DiscountPercent? grandTotal;
  String? expiredAt;
  PersonId? personId;
  List<Items>? items;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? userId;

  Data({
    this.sId,
    this.subject,
    this.description,
    this.billingAddress,
    this.shippingAddress,
    this.discountPercent,
    this.discountAmount,
    this.taxAmount,
    this.adjustmentAmount,
    this.subTotal,
    this.grandTotal,
    this.expiredAt,
    this.personId,
    this.items,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.userId,
  });

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    subject = json['subject'];
    description = json['description'];
    billingAddress =
        json['billing_address'] != null
            ? new BillingAddress.fromJson(json['billing_address'])
            : null;
    shippingAddress =
        json['shipping_address'] != null
            ? new BillingAddress.fromJson(json['shipping_address'])
            : null;
    discountPercent =
        json['discount_percent'] != null
            ? new DiscountPercent.fromJson(json['discount_percent'])
            : null;
    discountAmount =
        json['discount_amount'] != null
            ? new DiscountPercent.fromJson(json['discount_amount'])
            : null;
    taxAmount =
        json['tax_amount'] != null
            ? new DiscountPercent.fromJson(json['tax_amount'])
            : null;
    adjustmentAmount =
        json['adjustment_amount'] != null
            ? new DiscountPercent.fromJson(json['adjustment_amount'])
            : null;
    subTotal =
        json['sub_total'] != null
            ? new DiscountPercent.fromJson(json['sub_total'])
            : null;
    grandTotal =
        json['grand_total'] != null
            ? new DiscountPercent.fromJson(json['grand_total'])
            : null;
    expiredAt = json['expired_at'];
    personId =
        json['person_id'] != null
            ? new PersonId.fromJson(json['person_id'])
            : null;
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['subject'] = this.subject;
    data['description'] = this.description;
    if (this.billingAddress != null) {
      data['billing_address'] = this.billingAddress!.toJson();
    }
    if (this.shippingAddress != null) {
      data['shipping_address'] = this.shippingAddress!.toJson();
    }
    if (this.discountPercent != null) {
      data['discount_percent'] = this.discountPercent!.toJson();
    }
    if (this.discountAmount != null) {
      data['discount_amount'] = this.discountAmount!.toJson();
    }
    if (this.taxAmount != null) {
      data['tax_amount'] = this.taxAmount!.toJson();
    }
    if (this.adjustmentAmount != null) {
      data['adjustment_amount'] = this.adjustmentAmount!.toJson();
    }
    if (this.subTotal != null) {
      data['sub_total'] = this.subTotal!.toJson();
    }
    if (this.grandTotal != null) {
      data['grand_total'] = this.grandTotal!.toJson();
    }
    data['expired_at'] = this.expiredAt;
    if (this.personId != null) {
      data['person_id'] = this.personId!.toJson();
    }
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['user_id'] = this.userId;
    return data;
  }
}

class BillingAddress {
  String? line1;
  String? country;
  String? state;
  String? city;
  String? postalCode;

  BillingAddress({
    this.line1,
    this.country,
    this.state,
    this.city,
    this.postalCode,
  });

  BillingAddress.fromJson(Map<String, dynamic> json) {
    line1 = json['line1'];
    country = json['country'];
    state = json['state'];
    city = json['city'];
    postalCode = json['postal_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['line1'] = this.line1;
    data['country'] = this.country;
    data['state'] = this.state;
    data['city'] = this.city;
    data['postal_code'] = this.postalCode;
    return data;
  }
}

class DiscountPercent {
  String? numberDecimal;

  DiscountPercent({this.numberDecimal});

  DiscountPercent.fromJson(Map<String, dynamic> json) {
    numberDecimal = json['$numberDecimal'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['$numberDecimal'] = this.numberDecimal;
    return data;
  }
}

class PersonId {
  String? sId;
  String? name;

  PersonId({this.sId, this.name});

  PersonId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    return data;
  }
}

class Items {
  String? name;
  int? quantity;
  DiscountPercent? price;
  DiscountPercent? discountPercent;
  DiscountPercent? discountAmount;
  DiscountPercent? taxPercent;
  DiscountPercent? taxAmount;
  DiscountPercent? total;
  String? productId;
  String? sId;
  String? createdAt;
  String? updatedAt;
  String? sku;

  Items({
    this.name,
    this.quantity,
    this.price,
    this.discountPercent,
    this.discountAmount,
    this.taxPercent,
    this.taxAmount,
    this.total,
    this.productId,
    this.sId,
    this.createdAt,
    this.updatedAt,
    this.sku,
  });

  Items.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    quantity = json['quantity'];
    price =
        json['price'] != null
            ? new DiscountPercent.fromJson(json['price'])
            : null;
    discountPercent =
        json['discount_percent'] != null
            ? new DiscountPercent.fromJson(json['discount_percent'])
            : null;
    discountAmount =
        json['discount_amount'] != null
            ? new DiscountPercent.fromJson(json['discount_amount'])
            : null;
    taxPercent =
        json['tax_percent'] != null
            ? new DiscountPercent.fromJson(json['tax_percent'])
            : null;
    taxAmount =
        json['tax_amount'] != null
            ? new DiscountPercent.fromJson(json['tax_amount'])
            : null;
    total =
        json['total'] != null
            ? new DiscountPercent.fromJson(json['total'])
            : null;
    productId = json['product_id'];
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    sku = json['sku'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['quantity'] = this.quantity;
    if (this.price != null) {
      data['price'] = this.price!.toJson();
    }
    if (this.discountPercent != null) {
      data['discount_percent'] = this.discountPercent!.toJson();
    }
    if (this.discountAmount != null) {
      data['discount_amount'] = this.discountAmount!.toJson();
    }
    if (this.taxPercent != null) {
      data['tax_percent'] = this.taxPercent!.toJson();
    }
    if (this.taxAmount != null) {
      data['tax_amount'] = this.taxAmount!.toJson();
    }
    if (this.total != null) {
      data['total'] = this.total!.toJson();
    }
    data['product_id'] = this.productId;
    data['_id'] = this.sId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['sku'] = this.sku;
    return data;
  }
}
