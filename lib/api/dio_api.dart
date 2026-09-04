import 'dart:convert';
import 'package:crm_flutter/api/response/all_campaigns_response.dart';
import 'package:crm_flutter/api/response/all_follow_up_response.dart';
import 'package:crm_flutter/api/response/all_missed_followups_response.dart';
import 'package:crm_flutter/api/response/all_templates_response.dart';
import 'package:crm_flutter/api/response/call_log_response.dart';
import 'package:crm_flutter/api/response/dashboard_res.dart';
import 'package:crm_flutter/api/response/get_whatsappSms_response.dart';
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
import 'package:flutter/services.dart';

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
    try {
      final response = await DioUtil.dio.get("$link/lead/$leadId");
      print('++++++++ dio +++++++++');
      print(response);
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

  Future patchLead(String leadId, Map<String, dynamic> data) async {
    try {
      final response = await DioUtil.dio.patch(
        "$link/lead/$leadId",
        data: data,
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("Failed to update lead");
      }
    } catch (e) {
      throw Exception("Update lead error: $e");
    }
  }

  Future<AllLeadDetailResponse> getAllLeadDetailsPatchA(leadId) async {
    try {
      final response = await DioUtil.dio.patch("$link/lead/$leadId/accept");
      print('++++++++ dio +++++++++');
      print(response);
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
      print('++++++++ dio +++++++++');
      print(response);
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

  Future<dynamic> syncIncomingCall(Map<String, dynamic> data) async {
    print("🔥 syncIncomingCall() CALLED");
    print("🔥 API DATA: $data");
    try {
      final response = await DioUtil.dio.post(
        "$link/call/sync-incoming",
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Incoming call synced successfully: ${response.data}");
        return response.data;
      }

      throw Exception('Failed to sync incoming call: ${response.statusCode}');
    } on DioException catch (e) {
      print(
        "Incoming call sync failed: "
        "${e.response?.statusCode} - ${e.response?.data}",
      );

      throw Exception(
        'Incoming call sync failed: ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      print("Incoming call sync error: $e");
      throw Exception('An error occurred while syncing incoming call: $e');
    }
  }

  Future createQuote(data) async {
    try {
      final response = await DioUtil.dio.post(
        "$link/quote",
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      print(
        "+++++++++++++++++++++ Quote create start ++++++++++++++++++++++++++",
      );
      print(response.data);
      print(
        "+++++++++++++++++++++ Quote create end ++++++++++++++++++++++++++",
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
      print("+++++++++++++++ Source ++++++++++++++++++++++++++++++++");
      print(response.data);
      print("+++++++++++++++++++++++++++++++++++++++++++++++");

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
      print(
        "+++++++++++++++ Type create start ++++++++++++++++++++++++++++++++",
      );
      print(response.data);
      print("+++++++++++++++ Type create end ++++++++++++++++++++++++++++++++");

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

      print(
        "+++++++++++++++ Group create start ++++++++++++++++++++++++++++++++",
      );
      print(response.data);
      print(
        "++++++++++++++++ Group create end +++++++++++++++++++++++++++++++",
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

  Future createRole(data) async {
    try {
      final response = await DioUtil.dio.post(
        "$link/role",
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      print(
        "+++++++++++++++ Lead Role create start ++++++++++++++++++++++++++++++++",
      );
      print(response.data);
      print(
        "++++++++++++++++ Lead Role create end +++++++++++++++++++++++++++++++",
      );
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
      print("+++++++++++++++++++++++++++++++++++++++++++++++");
      print(response.data);
      print("+++++++++++++++++++++++++++++++++++++++++++++++");

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
        queryParams['startDate'] = startDateTime.toUtc().toIso8601String();
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
        queryParams['endDate'] = endDateTime.toUtc().toIso8601String();
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
      print(response);
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
      // Build query parameters
      Map<String, dynamic> queryParams = {};

      if (startDate != null) {
        // Format start date to include time (start of day)
        final startDateTime = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
        );
        queryParams['startDate'] = startDateTime.toUtc().toIso8601String();
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
        queryParams['endDate'] = endDateTime.toUtc().toIso8601String();
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

  // POST PHONE CALL
  Future postPhoneCall(data) async {
    try {
      final response = await DioUtil.dio.post("$link/call/dial", data: data);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      return e;
    }
  }

  Future startPostPhoneCall() async {
    try {
      final response = await DioUtil.dio.post("$link/call/start-call");
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      return e;
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
      print("Follow-up API error: $e");
      return [];
    }
  }

  Future<AllMissedFupsRes> getMissedFUps({
    String? currentDateTime,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};
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

      print("======================================");
      print("CREATE LEAD REQUEST");
      print("======================================");

      print("Fields:");
      for (final field in formData.fields) {
        print("${field.key}: ${field.value}");
      }

      print("Documents: ${formData.files.length}");

      for (final file in formData.files) {
        print("Document: ${file.value.filename}");
      }

      print("======================================");

      final response = await DioUtil.dio.post(
        "$link/lead",
        data: formData,
        options: Options(contentType: "multipart/form-data"),
      );

      print("======================================");
      print("CREATE LEAD RESPONSE");
      print("======================================");
      print(response.data);
      print("======================================");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception("Failed to create lead: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("======================================");
      print("CREATE LEAD ERROR");
      print("======================================");
      print("Status: ${e.response?.statusCode}");
      print("Response: ${e.response?.data}");
      print("======================================");

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
        'search': search,
        'page': page,
        'limit': limit,
      };

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

      print("STATUS : ${response.statusCode}");
      print("BODY : ${response.data}");

      return LocationResponse.fromJson(response.data);
    } on DioException catch (e) {
      print("ERROR STATUS : ${e.response?.statusCode}");
      print("ERROR BODY : ${e.response?.data}");
      rethrow;
    }
  }

  Future<LocationResponse> getStates(String countryId) async {
    try {
      final response = await DioUtil.dio.get(
        "$link/location/states/$countryId",
      );

      print("STATE STATUS : ${response.statusCode}");
      print("STATE BODY : ${response.data}");

      return LocationResponse.fromJson(response.data);
    } on DioException catch (e) {
      print("STATE ERROR : ${e.response?.data}");
      rethrow;
    }
  }

  Future<LocationResponse> getCities(String stateId) async {
    try {
      final response = await DioUtil.dio.get("$link/location/cities/$stateId");

      print("CITY STATUS : ${response.statusCode}");
      print("CITY BODY : ${response.data}");

      return LocationResponse.fromJson(response.data);
    } on DioException catch (e) {
      print("CITY ERROR : ${e.response?.data}");
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
}
