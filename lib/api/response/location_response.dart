class LocationResponse {
  bool? status;
  String? message;
 List<LocationData>? data;

  LocationResponse({
    this.status,
    this.message,
    this.data,
  });

  LocationResponse.fromJson(Map<String, dynamic> json) {
  status = json["status"];
  message = json["message"];

  data = [];

  if (json["data"] != null) {
    if (json["data"]["countries"] != null) {
      json["data"]["countries"].forEach((v) {
        data!.add(LocationData.fromJson(v));
      });
    } else if (json["data"]["states"] != null) {
      json["data"]["states"].forEach((v) {
        data!.add(LocationData.fromJson(v));
      });
    } else if (json["data"]["cities"] != null) {
      json["data"]["cities"].forEach((v) {
        data!.add(LocationData.fromJson(v));
      });
    }
  }
}
}
class LocationData {
  String? sId;
  String? name;

  LocationData({
    this.sId,
    this.name,
  });

  LocationData.fromJson(Map<String, dynamic> json) {
    sId = json["_id"]?.toString();
    name = json["name"]?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": sId,
      "name": name,
    };
  }

  @override
  String toString() {
    return name ?? "";
  }
}