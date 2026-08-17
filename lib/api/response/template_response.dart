import 'package:crm_flutter/api/response/all_templates_response.dart';

class TemplateResponse {
  bool? success;
  TemplateData? data;

  TemplateResponse({this.success, this.data});

  TemplateResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? TemplateData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['success'] = success;

    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }

    return data;
  }
}
