class AllLeadStageResponse {
  bool? success;
  List<Data>? data;
  int? total;
  int? currentPage;
  int? limit;
  int? totalPages;

  AllLeadStageResponse({
    this.success,
    this.data,
    this.total,
    this.currentPage,
    this.limit,
    this.totalPages,
  });

  AllLeadStageResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[]; //CREATES A EMPTY LIST
      json['data'].forEach((v) {
        //EX. IT HAVE A 6 ITERATION({"_Id": ..., "name": ..},{},{},{},{},{})
        //This loop runs once for every object in the JSON array.
        //it runs 6 times (because there are 6 objects).
        //EACH TIME: v = one single JSON object
        data!.add(new Data.fromJson(v));
      });
    }
    total = json['total'];
    currentPage = json['currentPage'];
    limit = json['limit'];
    totalPages = json['totalPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['total'] = this.total;
    data['currentPage'] = this.currentPage;
    data['limit'] = this.limit;
    data['totalPages'] = this.totalPages;
    return data;
  }
}

class Data {
  String? sId;
  String? code;
  String? name;
  bool? isUserDefined;
  String? createdAt;
  String? updatedAt;
  int? iV;
  bool? hasSubStatus;
  int? count;

  Data({
    this.sId,
    this.code,
    this.name,
    this.isUserDefined,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.hasSubStatus,
    this.count,
  });

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    code = json['code'];
    name = json['name'];
    isUserDefined = json['is_user_defined'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    hasSubStatus = json['hasSubStatus'] ?? false;
    count = json['count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    // final Map<String, dynamic> data = <String, String>{};
    data['_id'] = this.sId;
    data['code'] = this.code;
    data['name'] = this.name;
    data['is_user_defined'] = this.isUserDefined;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['hasSubStatus'] = hasSubStatus;
    data['count'] = this.count;
    return data;
  }
}
