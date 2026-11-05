import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:crm_flutter/api/response/all_campaigns_response.dart';
import 'package:crm_flutter/api/response/campaign_custom_fields_response.dart';
import 'package:crm_flutter/api/response/all_follow_up_response.dart';
import 'package:crm_flutter/api/response/all_missed_followups_response.dart';
import 'package:crm_flutter/api/response/all_templates_response.dart';
import 'package:crm_flutter/api/response/history_timeline_response.dart';
import 'package:crm_flutter/api/response/call_log_response.dart';
import 'package:crm_flutter/api/response/dashboard_res.dart';
import 'package:crm_flutter/api/response/get_whatsappSms_response.dart';
import 'package:crm_flutter/api/response/notification_model.dart';
import 'package:crm_flutter/api/response/substatus_lead_stage_response.dart';
import 'package:crm_flutter/api/response/template_response.dart';
import 'package:crm_flutter/local_storage/local_storage.dart';
import 'package:dio/dio.dart';
import 'package:crm_flutter/api/dio_util.dart';
import 'package:crm_flutter/api/response/all_calls_history_response.dart';
import 'package:crm_flutter/api/response/all_groups_response.dart';
import 'package:crm_flutter/api/response/all_lead_details_response.dart';
import 'package:crm_flutter/api/response/all_lead_stage_response.dart';
import 'package:crm_flutter/api/response/all_leads_response.dart';
import 'package:crm_flutter/api/response/all_organizations_response.dart';
import 'package:crm_flutter/api/response/all_persons_response.dart';
import 'package:crm_flutter/api/response/all_products_response.dart';
import 'package:crm_flutter/api/response/all_quotes_response.dart';
import 'package:crm_flutter/api/response/all_roles_response.dart';
import 'package:crm_flutter/api/response/all_sources_response.dart';
import 'package:crm_flutter/api/response/all_types_response.dart';
import 'package:crm_flutter/api/response/getLeadByStage.dart';
import 'package:crm_flutter/constants.dart';
import 'package:crm_flutter/api/response/location_response.dart';

String _responseStructure(Object? value, {int depth = 0}) {
  if (value == null) return 'null';
  if (depth >= 4) return value.runtimeType.toString();
  if (value is Map) {
    final fields = value.entries
        .map(
          (entry) =>
              '${entry.key}:${_responseStructure(entry.value, depth: depth + 1)}',
        )
        .join(',');
    return 'Map{$fields}';
  }
  if (value is List) {
    if (value.isEmpty) return 'List[]';
    return 'List[length=${value.length},item='
        '${_responseStructure(value.first, depth: depth + 1)}]';
  }
  return value.runtimeType.toString();
}

class DioApi {
  Future register(data) async {
    try {
      final response = await DioUtil.dio.post("$link/auth/signup", data: data);
      if (response.statusCode == 201) {
        return response.data;
      }
    } catch (e) {
      return (e.toString());
    }
  }

  Future login(data) async {
    try {
      final response = await DioUtil.dio.post("$link/auth/login", data: data);
      // if (response.statusCode == 200) {
      return response.data;
      // }
    } on DioException {
      rethrow;
    }
  }

  Future logout() async {
    try {
      final response = await DioUtil.dio.post("$link/auth/logout");
      return response.data;
    } on DioException {
      rethrow;
    }
  }

  Future<AllLeadStageResponse> getAllLeadStage({String? campaignId}) async {
    try {
      Map<String, dynamic> queryParams = {};
      if (campaignId != null && campaignId.isNotEmpty) {
        queryParams['campaign'] = campaignId;
      }
      final response = await DioUtil.dio.get(
        "$link/leadstage/all",
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      if (response.statusCode == 200) {
        return AllLeadStageResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load lead stages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching lead stages: $e');
    }
  }

  Future<AllCampaignsResponse> getAllCampaigns() async {
    try {
      final response = await DioUtil.dio.get("$link/campaign/all");
      if (response.statusCode == 200) {
        return AllCampaignsResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load campaigns: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching campaigns: $e');
    }
  }

  Future<CampaignCustomFieldsResponse> getCampaignCustomFields(
    String campaignId,
  ) async {
    final trimmedId = campaignId.trim();
    if (trimmedId.isEmpty || trimmedId == 'null' || trimmedId == 'undefined') {
      throw Exception('Invalid campaign ID: "$campaignId"');
    }

    try {
      final response = await DioUtil.dio.get(
        "$link/customlist/campaign/$trimmedId",
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return CampaignCustomFieldsResponse.fromJson(response.data);
        } else if (response.data is Map) {
          return CampaignCustomFieldsResponse.fromJson(
            Map<String, dynamic>.from(response.data),
          );
        }
        return CampaignCustomFieldsResponse(success: true, fields: []);
      } else {
        throw Exception(
          'Failed to load campaign custom fields: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;

      // Handle 404
      if (statusCode == 404) {
        // Inspect response body to determine if this is a confirmed "no configuration"
        // versus an incorrect endpoint/route or invalid campaign ID.
        if (responseData is Map) {
          final message = responseData['message']?.toString() ?? '';
          final messageLower = message.toLowerCase();

          // Check if the backend explicitly complained about invalid ID / cast error
          if (messageLower.contains('invalid') ||
              messageLower.contains('cast to') ||
              messageLower.contains('objectid')) {
            throw Exception('Invalid campaign ID: $message');
          }

          // Check if the message is that the campaign itself does not exist
          if (messageLower == 'campaign not found') {
            throw Exception('Campaign not found: $trimmedId');
          }

          // Confirmed no-configuration: custom list document does not exist for this campaign
          // e.g. "Custom list not found", "No custom fields found", data: null, etc.
          return CampaignCustomFieldsResponse(success: true, fields: []);
        }

        // If response is HTML or text like "Cannot GET ...", the endpoint/route is incorrect
        final bodyStr = responseData?.toString() ?? '';
        if (bodyStr.contains('Cannot GET') ||
            bodyStr.contains('<!DOCTYPE') ||
            bodyStr.contains('<html')) {
          throw Exception(
            'Custom list API endpoint not found: $link/customlist/campaign/$trimmedId',
          );
        }

        // Generic 404 with non-JSON or unexpected body
        throw Exception(
          'Campaign custom fields service returned 404: ${e.message ?? 'Resource not found'}',
        );
      }

      if (statusCode == 401) {
        throw Exception('Unauthorized: Session expired or invalid authentication.');
      }

      if (statusCode == 403) {
        throw Exception('Forbidden: You do not have permission to view campaign fields.');
      }

      if (statusCode != null && statusCode >= 500) {
        final serverMsg =
            responseData is Map ? responseData['message']?.toString() : null;
        throw Exception(
          serverMsg != null && serverMsg.isNotEmpty
              ? 'Server error ($statusCode): $serverMsg'
              : 'Server error ($statusCode): Failed to load campaign fields.',
        );
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Network connection error: Failed to connect to server.');
      }

      final errorMsg =
          responseData is Map ? responseData['message']?.toString() : null;
      throw Exception(
        errorMsg != null && errorMsg.isNotEmpty
            ? errorMsg
            : 'An error occurred while fetching campaign custom fields: ${e.message ?? e.toString()}',
      );
    } catch (e) {
      throw Exception(
        'An error occurred while fetching campaign custom fields: $e',
      );
    }
  }

  Future<Map<String, dynamic>> getLeadFields() async {
    try {
      final response = await DioUtil.dio.get("$link/Leadfield");
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return response.data;
        } else if (response.data is Map) {
          return Map<String, dynamic>.from(response.data);
        }
        return {'success': true, 'data': response.data};
      } else {
        throw Exception('Failed to load lead fields: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching lead fields: $e');
    }
  }

  Future<AllTemplatesResponse> getAllTemplates() async {
    try {
      final response = await DioUtil.dio.get("$link/templates/all");

      if (response.statusCode == 200) {
        return AllTemplatesResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load templates: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching templates: $e');
    }
  }

  Future<void> createTemplate(Map<String, dynamic> data) async {
    try {
      final response = await DioUtil.dio.post("$link/templates", data: data);

      if (response.statusCode != 201) {
        throw Exception('Failed to create template: ${response.statusCode}');
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('An error occurred while creating template: $e');
    }
  }

  Future<TemplateResponse> getTemplate(String id) async {
    try {
      final response = await DioUtil.dio.get("$link/templates/$id");

      if (response.statusCode == 200) {
        return TemplateResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load template: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching template: $e');
    }
  }

  Future<void> updateTemplate(String id, Map<String, dynamic> data) async {
    try {
      final response = await DioUtil.dio.patch(
        "$link/templates/$id",
        data: data,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update template: ${response.statusCode}');
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('An error occurred while updating template: $e');
    }
  }

  Future<void> deleteTemplate(String id) async {
    try {
      final response = await DioUtil.dio.delete("$link/templates/$id");

      if (response.statusCode != 200) {
        throw Exception('Failed to delete template: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while deleting template: $e');
    }
  }

  Future recordTemplateUsage({
    required String leadId,
    required String templateId,
    required String channel,
  }) async {
    try {
      final response = await DioUtil.dio.post(
        "$link/templates/usage",
        data: {
          "lead_id": leadId,
          "template_id": templateId,
          "channel": channel,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(
          "Failed to record template usage: ${response.statusCode}",
        );
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception("An error occurred while recording template usage: $e");
    }
  }

  Future<SubstatusLeadStageResponse> getFailedSubLeadStage({
    String? selectedStageId,
  }) async {
    ///1 not getting data************************ it was LAN issue
    try {
      final response = await DioUtil.dio.get(
        "$link/substatus/all?lead_stage_id=$selectedStageId",
      );
      if (response.statusCode == 200) {
        return SubstatusLeadStageResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load lead stages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching lead stages: $e');
    }
  }

  Future<GetLeadbyStageRes> getLeadbyStage(id) async {
    try {
      final response = await DioUtil.dio.get(
        "$link/leadstage/stage/$id",
      ); //id -> stage_id
      if (response.statusCode == 200) {
        return GetLeadbyStageRes.fromJson(response.data);
      } else {
        throw Exception('Failed to load lead stages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching lead stages: $e');
    }
  }

  Future<Map<String, dynamic>> getLeadStageById(String id) async {
    try {
      final response = await DioUtil.dio.get("$link/leadstage/$id");
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
          'Failed to load lead stage details: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(
        'An error occurred while fetching lead stage details: $e',
      );
    }
  }

  Future<AllLeadDetailResponse> getAllLeadDetails(leadId) async {
    final leadIdValue = leadId.toString();
    try {
      final response = await DioUtil.dio.get("$link/lead/$leadIdValue");
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
// Old comments , before Nov 3 2026 Tuesday.
        // debugPrint(
          // 'Lead detail GET /lead/$leadIdValue status=${response.statusCode}',
        // );
        return AllLeadDetailResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to load lead id details: ${response.statusCode}',
        );
      }
    } on DioException catch (error) {
// Old comments , before Nov 3 2026 Tuesday.
      // debugPrint(
        // 'Lead detail GET /lead/$leadIdValue failed '
        // 'status=${error.response?.statusCode} message=${error.message}',
      // );
      rethrow;
    } catch (e) {
      throw Exception('An error occurred while fetching lead id details: $e');
    }
  }

  Future<HistoryTimelineResponse> getLeadTimeline(String leadId) async {
    try {
      final response = await DioUtil.dio.get(
        "$link/history/timeline/${Uri.encodeComponent(leadId)}",
      );
      if (response.statusCode == 200) {
        if (response.data is! Map) {
          throw const FormatException(
            'Invalid lead timeline response: expected an object',
          );
        }
        return HistoryTimelineResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      } else {
        throw Exception('Failed to load lead timeline: ${response.statusCode}');
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception('An error occurred while fetching lead timeline: $e');
    }
  }

  // Future<AllLeadDetailResponse> patchAllLeadDetails(leadId) async {
  //   try {
  //     final response = await DioUtil.dio.patch("$link/lead/$leadId");
  //     print('++++++++ dio +++++++++');
  //     print(response);
  //     if (response.statusCode == 200) {
  //       return AllLeadDetailResponse.fromJson(response.data);
  //     } else {
  //       throw Exception(
  //         'Failed to load lead id details: ${response.statusCode}',
  //       );
  //     }
  //   } catch (e) {
  //     throw Exception('An error occurred while fetching lead id details: $e');
  //   }
  // }

  // Future patchAllLeadDetails(String leadId, String filePath) async {
  //   try {
  //     FormData formData = FormData.fromMap({
  //       "documents": await MultipartFile.fromFile(
  //         filePath,
  //         filename: filePath.split('/').last,
  //       ),
  //     });

  //     final response = await DioUtil.dio.patch(
  //       "$link/lead/$leadId",
  //       data: formData,
  //     );

  //     if (response.statusCode == 200) {
  //       return AllLeadDetailResponse.fromJson(response.data);
  //     } else {
  //       throw Exception("Failed to upload file");
  //     }
  //   } catch (e) {
  //     throw Exception("Upload error: $e");
  //   }
  // }

  Future patchAllLeadDetails(
    String leadId,
    List<String> filePaths,
    List<String> removedFiles,
  ) async {
    try {
      List<MultipartFile> files = [];

      for (var path in filePaths) {
        files.add(
          await MultipartFile.fromFile(path, filename: path.split('/').last),
        );
      }

      FormData formData = FormData.fromMap({
        "documents": files,
        if (removedFiles.isNotEmpty) "removedFiles": jsonEncode(removedFiles),
      });

      final response = await DioUtil.dio.patch(
        "$link/lead/$leadId",
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("Failed to upload file");
      }
    } catch (e) {
      throw Exception("Upload error: $e");
    }
  }

  Future patchLead(String leadId, dynamic data) async {
    final endpoint = '/lead/$leadId';
    var responseFailureLogged = false;
    try {
      final response = await DioUtil.dio.patch(
        "$link$endpoint",
        data: data,
        options: data is FormData
            ? Options(contentType: "multipart/form-data")
            : null,
      );
      final responseBody = response.data;
      final bodyMessage = responseBody is Map
          ? responseBody['message']?.toString()
          : null;
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          !(responseBody is Map && responseBody['success'] == false)) {
// Old comments , before Nov 3 2026 Tuesday.
        // debugPrint('Lead update PATCH $endpoint status=${response.statusCode}');
        return response.data;
      } else {
        final message = bodyMessage ?? 'Failed to update lead';
        responseFailureLogged = true;
// Old comments , before Nov 3 2026 Tuesday.
        // debugPrint(
          // 'Lead update PATCH $endpoint failed '
          // 'status=${response.statusCode} message=$message',
        // );
        throw Exception('$message (HTTP ${response.statusCode ?? 'unknown'})');
      }
    } on DioException catch (error) {
      final responseBody = error.response?.data;
      final responseMessage = responseBody is Map
          ? responseBody['message']?.toString()
          : null;
      final message = responseMessage ?? error.message ?? 'Request failed';
// Old comments , before Nov 3 2026 Tuesday.
      // debugPrint(
        // 'Lead update PATCH $endpoint failed '
        // 'status=${error.response?.statusCode} message=$message',
      // );
      throw Exception(
        'Update lead error (HTTP '
        '${error.response?.statusCode ?? 'unknown'}): $message',
      );
    } catch (error) {
      if (!responseFailureLogged) {
// Old comments , before Nov 3 2026 Tuesday.
        // debugPrint(
          // 'Lead update PATCH $endpoint failed '
          // 'status=unknown message=$error',
        // );
      }
      rethrow;
    }
  }

  Future<AllLeadDetailResponse> getAllLeadDetailsPatchA(leadId) async {
    try {
      final response = await DioUtil.dio.patch("$link/lead/$leadId/accept");
// Old comments , before Nov 3 2026 Tuesday.
      // print('++++++++ dio +++++++++');
// Old comments , before Nov 3 2026 Tuesday.
      // print(response);
      if (response.statusCode == 200) {
        return AllLeadDetailResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to load lead id details: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('An error occurred while fetching lead id details: $e');
    }
  }

  Future<AllLeadDetailResponse> getAllLeadDetailsPatchD(leadId) async {
    try {
      final response = await DioUtil.dio.patch("$link/lead/$leadId/reject");
// Old comments , before Nov 3 2026 Tuesday.
      // print('++++++++ dio +++++++++');
// Old comments , before Nov 3 2026 Tuesday.
      // print(response);
      if (response.statusCode == 200) {
        return AllLeadDetailResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to load lead id details: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('An error occurred while fetching lead id details: $e');
    }
  }

  Future<AllCallHistoryResponse> getAllCallsHistory(
    leadId, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final String url = (leadId == null || leadId.toString().isEmpty)
          ? "$link/call"
          : "$link/call/$leadId";
      final response = await DioUtil.dio.get(url, queryParameters: queryParams);
      if (response.statusCode == 200) {
        return AllCallHistoryResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load calls history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching calls history: $e');
    }
  }

  Future<AllPersonResponse> getAllPersons() async {
    try {
      final response = await DioUtil.dio.get("$link/person/all");
      if (response.statusCode == 200) {
        return AllPersonResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load persons: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching persons: $e');
    }
  }

  Future<AllOrganizationResponse> getAllOrganizations() async {
    try {
      final response = await DioUtil.dio.get("$link/organization/all");
      if (response.statusCode == 200) {
        return AllOrganizationResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load organizations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching organizations: $e');
    }
  }

  Future<AllQuoteResponse> getAllQuotes() async {
    try {
      final response = await DioUtil.dio.get("$link/quote/all");
      if (response.statusCode == 200) {
        return AllQuoteResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load quotes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching quotes: $e');
    }
  }

  Future<AllProductResponse> getAllProducts() async {
    try {
      final response = await DioUtil.dio.get("$link/product/all");
      if (response.statusCode == 200) {
        return AllProductResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching products: $e');
    }
  }

  Future<AllSourceResponse> getAllSources() async {
    try {
      final response = await DioUtil.dio.get("$link/leadsource/all");
      if (response.statusCode == 200) {
        return AllSourceResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load lead sources: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching lead sources: $e');
    }
  }

  Future<AllGroupResponse> getAllGroups() async {
    try {
      final response = await DioUtil.dio.get("$link/group/all");
      if (response.statusCode == 200) {
        return AllGroupResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load groups: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching groups: $e');
    }
  }

  Future<AllTypeResponse> getAllTypes() async {
    try {
      final response = await DioUtil.dio.get("$link/lead-type/all");
      if (response.statusCode == 200) {
        return AllTypeResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load lead-types: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching lead-types: $e');
    }
  }

  Future<AllRoleResponse> getAllRoles() async {
    try {
      final response = await DioUtil.dio.get("$link/role/all");
      if (response.statusCode == 200) {
        return AllRoleResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load lead-types: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching lead-roles: $e');
    }
  }

  Future deleteCallLog(String callId) async {
    try {
      final response = await DioUtil.dio.delete("$link/call/$callId");

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to delete call log: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while deleting call log: $e');
    }
  }

  Future deletePerson(String personId) async {
    try {
      final response = await DioUtil.dio.delete("$link/person/$personId");

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to delete person: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while deleting person: $e');
    }
  }

  Future deleteOrganization(String organizationId) async {
    try {
      final response = await DioUtil.dio.delete(
        "$link/organization/$organizationId",
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
          'Failed to delete organization: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('An error occurred while deleting organization: $e');
    }
  }

  Future deleteProduct(String productId) async {
    try {
      final response = await DioUtil.dio.delete("$link/product/$productId");
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to delete product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while deleting product: $e');
    }
  }

  Future deleteSource(String sourceId) async {
    try {
      final response = await DioUtil.dio.delete("$link/lead-source/$sourceId");
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to delete lead source: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while deleting lead source: $e');
    }
  }

  Future deleteGroup(String groupId) async {
    try {
      final response = await DioUtil.dio.delete("$link/group/$groupId");
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to delete group: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while deleting group: $e');
    }
  }

  Future deleteType(String typeId) async {
    try {
      final response = await DioUtil.dio.delete("$link/lead-type/$typeId");
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to delete lead-type: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while deleting lead-type: $e');
    }
  }

  Future createOrganization(data) async {
    try {
      final response = await DioUtil.dio.post(
        "$link/organization",
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(
          'Failed to create organization: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('An error occurred while creating organization: $e');
    }
  }

  Future createCallHistory(data) async {
    try {
      final response = await DioUtil.dio.post(
        "$link/call/dial",
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(
          'Failed to create call history: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('An error occurred while creating call history: $e');
    }
  }

  // Future<void> syncLatestIncomingCall() async {
  //   try {
  //     const channel = MethodChannel('com.example.crm_flutter/call');

  //     final callData = await channel.invokeMethod('getLatestIncomingCall');

  //     if (callData == null) {
  //       print("No incoming call data found");
  //       return;
  //     }

  //     print("CALL DATA FROM ANDROID: $callData");

  //     final int duration = callData["duration"] ?? 0;

  //     final DateTime startedAt = DateTime.fromMillisecondsSinceEpoch(
  //       callData["timestamp"],
  //     );

  //     final DateTime endedAt = startedAt.add(Duration(seconds: duration));

  //     final data = {
  //       "calls": [
  //         {
  //           "phone_number": callData["number"],
  //           "device_call_id": callData["deviceId"],
  //           "duration": duration,
  //           "missed": duration == 0,
  //           "started_at": startedAt.toIso8601String(),
  //           "ended_at": endedAt.toIso8601String(),
  //         },
  //       ],
  //     };

  //     print("SYNCING CALL: $data");

  //     final response = await syncIncomingCall(data);

  //     print("CALL SYNC RESPONSE: $response");
  //   } catch (e) {
  //     print("CALL SYNC ERROR: $e");
  //   }
  // }

  // Future<dynamic> syncIncomingCall(Map<String, dynamic> data) async {
  //   print("🔥 syncIncomingCall() CALLED");
  //   print("🔥 API DATA: $data");
  //   try {
  //     final response = await DioUtil.dio.post(
  //       "$link/call/sync-incoming",
  //       data: data,
  //       options: Options(headers: {'Content-Type': 'application/json'}),
  //     );

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       print("Incoming call synced successfully: ${response.data}");
  //       return response.data;
  //     }

  //     throw Exception('Failed to sync incoming call: ${response.statusCode}');
  //   } on DioException catch (e) {
  //     print(
  //       "Incoming call sync failed: "
  //       "${e.response?.statusCode} - ${e.response?.data}",
  //     );

  //     throw Exception(
  //       'Incoming call sync failed: ${e.response?.data ?? e.message}',
  //     );
  //   } catch (e) {
  //     print("Incoming call sync error: $e");
  //     throw Exception('An error occurred while syncing incoming call: $e');
  //   }
  // }

  Future createQuote(data) async {
    try {
      final response = await DioUtil.dio.post(
        "$link/quote",
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
// Old comments , before Nov 3 2026 Tuesday.
      // print(
        // "+++++++++++++++++++++ Quote create start ++++++++++++++++++++++++++",
      // );
// Old comments , before Nov 3 2026 Tuesday.
      // print(response.data);
// Old comments , before Nov 3 2026 Tuesday.
      // print(
        // "+++++++++++++++++++++ Quote create end ++++++++++++++++++++++++++",
      // );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(
          'Failed to create organization: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('An error occurred while creating organization: $e');
    }
  }

  Future createPerson(data) async {
    try {
      final response = await DioUtil.dio.post(
        "$link/person",
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to create person: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while creating person: $e');
    }
  }

  Future createProduct(data) async {
    try {
      final response = await DioUtil.dio.post(
        "$link/product",
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to create person: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while creating product: $e');
    }
  }

  Future createSource(data) async {
    try {
      final response = await DioUtil.dio.post(
        "$link/lead-source",
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
// Old comments , before Nov 3 2026 Tuesday.
      // print("+++++++++++++++ Source ++++++++++++++++++++++++++++++++");
// Old comments , before Nov 3 2026 Tuesday.
      // print(response.data);
// Old comments , before Nov 3 2026 Tuesday.
      // print("+++++++++++++++++++++++++++++++++++++++++++++++");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to create lead source: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while creating lead source: $e');
    }
  }

  Future createType(data) async {
    try {
      final response = await DioUtil.dio.post(
        "$link/lead-type",
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
// Old comments , before Nov 3 2026 Tuesday.
      // print(
        // "+++++++++++++++ Type create start ++++++++++++++++++++++++++++++++",
      // );
// Old comments , before Nov 3 2026 Tuesday.
      // print(response.data);
// Old comments , before Nov 3 2026 Tuesday.
      // print("+++++++++++++++ Type create end ++++++++++++++++++++++++++++++++");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to create lead type: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while creating lead type: $e');
    }
  }

  Future createGroup(data) async {
    try {
      final response = await DioUtil.dio.post(
        "$link/group",
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

// Old comments , before Nov 3 2026 Tuesday.
      // print(
        // "+++++++++++++++ Group create start ++++++++++++++++++++++++++++++++",
      // );
// Old comments , before Nov 3 2026 Tuesday.
      // print(response.data);
// Old comments , before Nov 3 2026 Tuesday.
      // print(
        // "++++++++++++++++ Group create end +++++++++++++++++++++++++++++++",
      // );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to create group: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while creating group: $e');
    }
  }

  Future createRole(data) async {
    try {
      final response = await DioUtil.dio.post(
        "$link/role",
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

// Old comments , before Nov 3 2026 Tuesday.
      // print(
        // "+++++++++++++++ Lead Role create start ++++++++++++++++++++++++++++++++",
      // );
// Old comments , before Nov 3 2026 Tuesday.
      // print(response.data);
// Old comments , before Nov 3 2026 Tuesday.
      // print(
        // "++++++++++++++++ Lead Role create end +++++++++++++++++++++++++++++++",
      // );
    } catch (e) {
      throw Exception('An error occurred while creating lead role: $e');
    }
  }

  Future updatePerson(data, id) async {
    try {
      final response = await DioUtil.dio.patch(
        "$link/person/$id",
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
// Old comments , before Nov 3 2026 Tuesday.
      // print("+++++++++++++++++++++++++++++++++++++++++++++++");
// Old comments , before Nov 3 2026 Tuesday.
      // print(response.data);
// Old comments , before Nov 3 2026 Tuesday.
      // print("+++++++++++++++++++++++++++++++++++++++++++++++");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to create person: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while creating person: $e');
    }
  }

  Future updateOrganization(data, id) async {
    try {
      final response = await DioUtil.dio.patch(
        "$link/organization/$id",
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(
          'Failed to update organization: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('An error occurred while updating organization: $e');
    }
  }

  Future updateProduct(data, id) async {
    try {
      final response = await DioUtil.dio.patch(
        "$link/product/$id",
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to create product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while creating product: $e');
    }
  }

  Future updateGroup(data, id) async {
    try {
      final response = await DioUtil.dio.patch(
        "$link/group/$id",
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to create group: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while creating group: $e');
    }
  }

  Future<AllLeadsResponse> searchLeads(String query) async {
    try {
      final response = await DioUtil.dio.get(
        "$link/lead/all",
        queryParameters: {'search': query},
      );
      if (response.statusCode == 200) {
        return AllLeadsResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to search leads: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while searching leads: $e');
    }
  }

  Future<AllLeadsResponse> getAllLeads({
    int page = 1,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? statusIds,
    String? campaignId,
    String? leadSourceId,
  }) async {
    try {
      // Build query parameters
      Map<String, dynamic> queryParams = {};

      if (startDate != null) {
        // Format start date to include time (start of day)
        final startDateTime = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
        );
        queryParams['startDate'] = startDateTime.toIso8601String();
      }

      if (endDate != null) {
        // Format end date to include time (end of day)
        final endDateTime = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          23,
          59,
          59,
          999,
        );
        queryParams['endDate'] = endDateTime.toIso8601String();
      }

      if (statusIds != null && statusIds.isNotEmpty) {
        queryParams['lead_stage_id'] = statusIds.join(',');
      }

      if (campaignId != null && campaignId.isNotEmpty) {
        queryParams['campaign'] = campaignId;
      }

      if (leadSourceId != null && leadSourceId.isNotEmpty) {
        queryParams['lead_source_id'] = leadSourceId;
      }

      final response = await DioUtil.dio.get(
        "$link/lead/all?page=$page",
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
// Old comments , before Nov 3 2026 Tuesday.
      // print(response);
      if (response.statusCode == 200) {
        return AllLeadsResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load lead stages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching leads: $e');
    }
  }

  Future<DashboardDataRes> getDashboard({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? statusIds,
    String? campaignId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (startDate != null) {
        // Start of selected day in local time (IST)
        final startDateTime = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
          0,
          0,
          0,
          0,
        );

        queryParams['startDate'] = startDateTime.toIso8601String();
      }

      if (endDate != null) {
        // End of selected day in local time (IST)
        final endDateTime = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          23,
          59,
          59,
          999,
        );

        queryParams['endDate'] = endDateTime.toIso8601String();
      }

      if (statusIds != null && statusIds.isNotEmpty) {
        queryParams['leadStageId'] = statusIds.join(',');
      }

      if (campaignId != null && campaignId.isNotEmpty) {
        queryParams['campaign'] = campaignId;
      }

      final response = await DioUtil.dio.get(
        "$link/dashboard/call-duration/$userId",
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        return DashboardDataRes.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to load dashboard data: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('An error occurred while fetching dashboard data: $e');
    }
  }

  // POST INCOMING CALL
  // POST INCOMING CALL
  // POST INCOMING CALL
  Future postIncomingCall(Map<String, dynamic> data) async {
// Old comments , before Nov 3 2026 Tuesday.
    // debugPrint(
      // '[incoming-call] ${DateTime.now().toIso8601String()} '
      // 'event=api_request',
    // );

    final incomingCallUrl = "$link/call/incoming";

    try {
      final response = await DioUtil.dio.post(
        incomingCallUrl,
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

// Old comments , before Nov 3 2026 Tuesday.
      // debugPrint(
        // '[incoming-call] ${DateTime.now().toIso8601String()} '
        // 'event=api_response status=${response.statusCode}',
      // );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map && response.data['success'] == false) {
          throw StateError(
            'The incoming-call API reported an unsuccessful save',
          );
        }
        return response.data;
      }

      throw Exception('Failed to post incoming call: ${response.statusCode}');
    } on DioException catch (e) {
// Old comments , before Nov 3 2026 Tuesday.
      // debugPrint(
        // '[incoming-call] ${DateTime.now().toIso8601String()} '
        // 'event=api_transport_error '
        // 'status=${e.response?.statusCode ?? 'none'}',
      // );

      throw Exception(
        'Incoming call post failed (status ${e.response?.statusCode ?? 'unknown'})',
      );
    } catch (e) {
      rethrow;
    }
  }

  // POST PHONE CALL
  Future<dynamic> postPhoneCall(
    Map<String, dynamic> data, {
    String? idempotencyKey,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
      headers['Idempotency-Key'] = idempotencyKey;
    }

    try {
      final response = await DioUtil.dio.post(
        "$link/call/dial",
        data: data,
        options: Options(headers: headers),
      );
// Old comments , before Nov 3 2026 Tuesday.
      // debugPrint(
        // '[call-session] ${DateTime.now().toIso8601String()} '
        // 'event=call_api_response status=${response.statusCode} '
        // 'response_structure=${_responseStructure(response.data)}',
      // );
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
          'Failed to create call history: ${response.statusCode}',
        );
      }
      if (response.data is Map && response.data['success'] == false) {
        throw StateError('The call-history API reported an unsuccessful save');
      }
      return response.data;
    } on DioException catch (error) {
// Old comments , before Nov 3 2026 Tuesday.
      // debugPrint(
        // '[call-session] ${DateTime.now().toIso8601String()} '
        // 'event=call_api_transport_error '
        // 'status=${error.response?.statusCode ?? 'none'} '
        // 'response_structure=${_responseStructure(error.response?.data)}',
      // );
      rethrow;
    }
  }

  Future startPostPhoneCall() async {
    try {
      final response = await DioUtil.dio.post("$link/call/start-call");
      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.data is Map && response.data['success'] == false) {
          throw StateError(
            'The start-call API reported an unsuccessful result',
          );
        }
        return response.data;
      }
      throw Exception('Failed to start call tracking: ${response.statusCode}');
    } on DioException catch (error) {
// Old comments , before Nov 3 2026 Tuesday.
      // debugPrint(
        // '[call-session] ${DateTime.now().toIso8601String()} '
        // 'event=start_call_api_transport_error '
        // 'status=${error.response?.statusCode ?? 'none'}',
      // );
      rethrow;
    }
  }

  Future<CallLogsResponse> getAllCallApi() async {
    try {
      final response = await DioUtil.dio.get("$link/call");
      if (response.statusCode == 200) {
        return CallLogsResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching products: $e');
    }
  }

  Future<List<FollowUpData>> fetchTodayFollowUps() async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      String token = LocalStorage.sharedPreferences?.getString("token") ?? "";

      final response = await Dio().get(
        "$link/lead/followup/today",
        queryParameters: {"currentTime": now},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = response.data;

        if (jsonData['success'] == true) {
          //Parse full response
          final model = FollowUpResponse.fromJson(jsonData);

          // return list safely
          return model.data ?? [];
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
// Old comments , before Nov 3 2026 Tuesday.
      // print("Follow-up API error: $e");
      return [];
    }
  }

  Future<AllMissedFupsRes> getMissedFUps({
    String? currentDateTime,
    int page = 1,
    int limit = 50,
    String search = "",
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Map<String, dynamic> queryParams = {'page': page, 'limit': limit};
      if (search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (currentDateTime != null) queryParams['currentTime'] = currentDateTime;

      if (startDate != null) {
        final startDateTime = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
        );
        queryParams['followUpStartDate'] = startDateTime
            .toUtc()
            .toIso8601String();
      }

      if (endDate != null) {
        final endDateTime = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          23,
          59,
          59,
          999,
        );
        queryParams['followUpEndDate'] = endDateTime.toUtc().toIso8601String();
      }

      final res = await DioUtil.dio.get(
        '$link/lead/followup/missed',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (res.statusCode == 200) {
        return AllMissedFupsRes.fromJson(res.data);
      } else {
        return throw Exception(
          'Failed to load getMissedFUps: ${res.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('An error occurred getMissedFUps: $e');
    }
  }

  Future<GetWhatsappsmsResponse> getwhatsSms({
    String? campaignId,
    String? whichSource,
    int? page = 1,
  }) async {
    try {
      final res = await DioUtil.dio.get(
        '$link/templates/all',
        queryParameters: {
          'campaign_id': campaignId,
          'channel': whichSource,
          'page': page,
        },
      );

      if (res.statusCode == 200) {
        return GetWhatsappsmsResponse.fromJson(res.data);
      } else {
        return throw Exception('Failed to load getwhatsSms: ${res.statusCode}');
      }
    } catch (err) {
      throw Exception('An error occurred getwhatsSms: $err');
    }
  }

  Future createLead(
    Map<String, dynamic> data, {
    List<String>? documentFiles,
  }) async {
    try {
      final formData = FormData();

      // ============================
      // Add Lead Fields
      // ============================

      data.forEach((key, value) {
        if (value == null) return;

        // Nested objects
        if (key == "name" || key == "location") {
          formData.fields.add(MapEntry(key, jsonEncode(value)));
        } else if (key == "customList" || key == "stageFieldValues") {
          final stringVal = value is String ? value : jsonEncode(value);
          formData.fields.add(MapEntry(key, stringVal));
        } else {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      // ============================
      // Add Documents
      // ============================

      if (documentFiles != null && documentFiles.isNotEmpty) {
        for (final filePath in documentFiles) {
          formData.files.add(
            MapEntry(
              "documents",
              await MultipartFile.fromFile(
                filePath,
                filename: filePath.split('/').last,
              ),
            ),
          );
        }
      }

// Old comments , before Nov 3 2026 Tuesday.
      // print("======================================");
// Old comments , before Nov 3 2026 Tuesday.
      // print("CREATE LEAD REQUEST");
// Old comments , before Nov 3 2026 Tuesday.
      // print("======================================");

// Old comments , before Nov 3 2026 Tuesday.
      // print("Fields:");
      for (final field in formData.fields) {
// Old comments , before Nov 3 2026 Tuesday.
        // print("${field.key}: ${field.value}");
      }

// Old comments , before Nov 3 2026 Tuesday.
      // print("Documents: ${formData.files.length}");

      for (final file in formData.files) {
// Old comments , before Nov 3 2026 Tuesday.
        // print("Document: ${file.value.filename}");
      }

// Old comments , before Nov 3 2026 Tuesday.
      // print("======================================");

      final response = await DioUtil.dio.post(
        "$link/lead",
        data: formData,
        options: Options(contentType: "multipart/form-data"),
      );

// Old comments , before Nov 3 2026 Tuesday.
      // print("======================================");
// Old comments , before Nov 3 2026 Tuesday.
      // print("CREATE LEAD RESPONSE");
// Old comments , before Nov 3 2026 Tuesday.
      // print("======================================");
// Old comments , before Nov 3 2026 Tuesday.
      // print(response.data);
// Old comments , before Nov 3 2026 Tuesday.
      // print("======================================");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception("Failed to create lead: ${response.statusCode}");
      }
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception("An error occurred while creating lead: $e");
    }
  }

  Future<AllLeadsResponse> getAllFollowUps({
    int page = 1,
    int limit = 50,
    String search = "",
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };
      if (search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      if (startDate != null) {
        final startDateTime = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
        );
        queryParams['followUpStartDate'] = startDateTime
            .toUtc()
            .toIso8601String();
      }

      if (endDate != null) {
        final endDateTime = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          23,
          59,
          59,
          999,
        );
        queryParams['followUpEndDate'] = endDateTime.toUtc().toIso8601String();
      }

      final response = await DioUtil.dio.get(
        "$link/lead/followup/all",
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        return AllLeadsResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load all followups: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching all followups: $e');
    }
  }

  Future<LocationResponse> getCountries() async {
    try {
      final response = await DioUtil.dio.get("$link/location/countries");

// Old comments , before Nov 3 2026 Tuesday.
      // print("STATUS : ${response.statusCode}");
// Old comments , before Nov 3 2026 Tuesday.
      // print("BODY : ${response.data}");

      return LocationResponse.fromJson(response.data);
    } on DioException catch (e) {
// Old comments , before Nov 3 2026 Tuesday.
      // print("ERROR STATUS : ${e.response?.statusCode}");
// Old comments , before Nov 3 2026 Tuesday.
      // print("ERROR BODY : ${e.response?.data}");
      rethrow;
    }
  }

  Future<LocationResponse> getStates(String countryId) async {
    try {
      final response = await DioUtil.dio.get(
        "$link/location/states/$countryId",
      );

// Old comments , before Nov 3 2026 Tuesday.
      // print("STATE STATUS : ${response.statusCode}");
// Old comments , before Nov 3 2026 Tuesday.
      // print("STATE BODY : ${response.data}");

      return LocationResponse.fromJson(response.data);
    } on DioException catch (e) {
// Old comments , before Nov 3 2026 Tuesday.
      // print("STATE ERROR : ${e.response?.data}");
      rethrow;
    }
  }

  Future<LocationResponse> getCities(String stateId) async {
    try {
      final response = await DioUtil.dio.get("$link/location/cities/$stateId");

// Old comments , before Nov 3 2026 Tuesday.
      // print("CITY STATUS : ${response.statusCode}");
// Old comments , before Nov 3 2026 Tuesday.
      // print("CITY BODY : ${response.data}");

      return LocationResponse.fromJson(response.data);
    } on DioException catch (e) {
// Old comments , before Nov 3 2026 Tuesday.
      // print("CITY ERROR : ${e.response?.data}");
      rethrow;
    }
  }

  Future<Response> getAllUsers({
    String search = "",
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await DioUtil.dio.get(
        "$link/createuser/all",
        queryParameters: {"search": search, "page": page, "limit": limit},
      );

      return response;
    } on DioException {
      rethrow;
    } catch (e) {
      throw Exception("Failed to load users: $e");
    }
  }

  Future<NotificationsResponse> getNotifications({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await DioUtil.dio.get(
        "$link/notifications",
        queryParameters: {
          if (startDate != null) 'startDate': startDate,
          if (endDate != null) 'endDate': endDate,
        },
      );

      if (response.statusCode == 200) {
        return NotificationsResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching notifications: $e');
    }
  }
}
