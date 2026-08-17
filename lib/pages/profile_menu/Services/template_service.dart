// import 'package:crm_flutter/api/dio_util.dart';
// import 'package:crm_flutter/api/response/all_templates_response.dart';
// import 'package:crm_flutter/api/response/template_response.dart';

// class TemplateService {
//   final String link = "/api/v1";

//   /// Create Template
//   Future<TemplateResponse> createTemplate(Map<String, dynamic> data) async {
//     try {
//       final response = await DioUtil.dio.post("$link/templates", data: data);

//       if (response.statusCode == 201) {
//         return TemplateResponse.fromJson(response.data);
//       } else {
//         throw Exception('Failed to create template: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('An error occurred while creating template: $e');
//     }
//   }

//   /// Get All Templates
//   Future<AllTemplatesResponse> getAllTemplates() async {
//     try {
//       final response = await DioUtil.dio.get("$link/templates/all");

//       if (response.statusCode == 200) {
//         return AllTemplatesResponse.fromJson(response.data);
//       } else {
//         throw Exception('Failed to load templates: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('An error occurred while fetching templates: $e');
//     }
//   }

//   /// Get Single Template
//   Future<TemplateResponse> getTemplate(String id) async {
//     try {
//       final response = await DioUtil.dio.get("$link/templates/$id");

//       if (response.statusCode == 200) {
//         return TemplateResponse.fromJson(response.data);
//       } else {
//         throw Exception('Failed to load template: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('An error occurred while fetching template: $e');
//     }
//   }

//   /// Update Template
//   Future<TemplateResponse> updateTemplate(
//     String id,
//     Map<String, dynamic> data,
//   ) async {
//     try {
//       final response = await DioUtil.dio.patch(
//         "$link/templates/$id",
//         data: data,
//       );

//       if (response.statusCode == 200) {
//         return TemplateResponse.fromJson(response.data);
//       } else {
//         throw Exception('Failed to update template: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('An error occurred while updating template: $e');
//     }
//   }

//   /// Delete Template
//   Future<void> deleteTemplate(String id) async {
//     try {
//       final response = await DioUtil.dio.delete("$link/templates/$id");

//       if (response.statusCode != 200) {
//         throw Exception("Failed to delete template: ${response.statusCode}");
//       }
//     } catch (e) {
//       throw Exception("An error occurred while deleting template: $e");
//     }
//   }
// }
