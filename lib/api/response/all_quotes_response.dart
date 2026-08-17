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
            ? BillingAddress.fromJson(json['billing_address'])
            : null;
    shippingAddress =
        json['shipping_address'] != null
            ? BillingAddress.fromJson(json['shipping_address'])
            : null;
    discountPercent =
        json['discount_percent'] != null
            ? DiscountPercent.fromJson(json['discount_percent'])
            : null;
    discountAmount =
        json['discount_amount'] != null
            ? DiscountPercent.fromJson(json['discount_amount'])
            : null;
    taxAmount =
        json['tax_amount'] != null
            ? DiscountPercent.fromJson(json['tax_amount'])
            : null;
    adjustmentAmount =
        json['adjustment_amount'] != null
            ? DiscountPercent.fromJson(json['adjustment_amount'])
            : null;
    subTotal =
        json['sub_total'] != null
            ? DiscountPercent.fromJson(json['sub_total'])
            : null;
    grandTotal =
        json['grand_total'] != null
            ? DiscountPercent.fromJson(json['grand_total'])
            : null;
    expiredAt = json['expired_at'];
    personId =
        json['person_id'] != null
            ? PersonId.fromJson(json['person_id'])
            : null;
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['subject'] = subject;
    data['description'] = description;
    if (billingAddress != null) {
      data['billing_address'] = billingAddress!.toJson();
    }
    if (shippingAddress != null) {
      data['shipping_address'] = shippingAddress!.toJson();
    }
    if (discountPercent != null) {
      data['discount_percent'] = discountPercent!.toJson();
    }
    if (discountAmount != null) {
      data['discount_amount'] = discountAmount!.toJson();
    }
    if (taxAmount != null) {
      data['tax_amount'] = taxAmount!.toJson();
    }
    if (adjustmentAmount != null) {
      data['adjustment_amount'] = adjustmentAmount!.toJson();
    }
    if (subTotal != null) {
      data['sub_total'] = subTotal!.toJson();
    }
    if (grandTotal != null) {
      data['grand_total'] = grandTotal!.toJson();
    }
    data['expired_at'] = expiredAt;
    if (personId != null) {
      data['person_id'] = personId!.toJson();
    }
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['user_id'] = userId;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['line1'] = line1;
    data['country'] = country;
    data['state'] = state;
    data['city'] = city;
    data['postal_code'] = postalCode;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['$numberDecimal'] = numberDecimal;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
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
            ? DiscountPercent.fromJson(json['price'])
            : null;
    discountPercent =
        json['discount_percent'] != null
            ? DiscountPercent.fromJson(json['discount_percent'])
            : null;
    discountAmount =
        json['discount_amount'] != null
            ? DiscountPercent.fromJson(json['discount_amount'])
            : null;
    taxPercent =
        json['tax_percent'] != null
            ? DiscountPercent.fromJson(json['tax_percent'])
            : null;
    taxAmount =
        json['tax_amount'] != null
            ? DiscountPercent.fromJson(json['tax_amount'])
            : null;
    total =
        json['total'] != null
            ? DiscountPercent.fromJson(json['total'])
            : null;
    productId = json['product_id'];
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    sku = json['sku'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['quantity'] = quantity;
    if (price != null) {
      data['price'] = price!.toJson();
    }
    if (discountPercent != null) {
      data['discount_percent'] = discountPercent!.toJson();
    }
    if (discountAmount != null) {
      data['discount_amount'] = discountAmount!.toJson();
    }
    if (taxPercent != null) {
      data['tax_percent'] = taxPercent!.toJson();
    }
    if (taxAmount != null) {
      data['tax_amount'] = taxAmount!.toJson();
    }
    if (total != null) {
      data['total'] = total!.toJson();
    }
    data['product_id'] = productId;
    data['_id'] = sId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['sku'] = sku;
    return data;
  }
}
