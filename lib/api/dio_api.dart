import 'dart:convert';
import 'package:crm_flutter/api/response/all_follow_up_response.dart';
import 'package:crm_flutter/api/response/all_missed_followups_response.dart';
import 'package:crm_flutter/api/response/call_log_response.dart';
import 'package:crm_flutter/api/response/dashboard_res.dart';
import 'package:crm_flutter/api/response/get_whatsappSms_response.dart';
import 'package:crm_flutter/api/response/substatus_lead_stage_response.dart';
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

class DioApi {
  Future register(data) async {
    try {
      final response = await DioUtil.dio.post("$link/auth/signup", data: data);
      if (response.statusCode == 201) {
        return response.data;
      }
    } catch (e) {
      return e;
    }
  }

  Future login(data) async {
    try {
      final response = await DioUtil.dio.post("$link/auth/login", data: data);
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      return e;
    }
  }

  Future logout() async {
    try {
      final response = await DioUtil.dio.post("$link/auth/logout");
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      return e;
    }
  }

  Future<AllLeadStageResponse> getAllLeadStage() async {
    ///1 not getting data************************ it was LAN issue
    try {
      final response = await DioUtil.dio.get("$link/leadstage/all");
      if (response.statusCode == 200) {
        return AllLeadStageResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load lead stages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching lead stages: $e');
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

  Future<AllCallHistoryResponse> getAllCallsHistory(leadId) async {
    try {
      final response = await DioUtil.dio.get("$link/call/$leadId");
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
      final response = await DioUtil.dio.get("$link/lead-source/all");
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
      print("+++++++++++++++++++++++++++++++++++++++++++++++");
      print(response.data);
      print("+++++++++++++++++++++++++++++++++++++++++++++++");
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
      print(
        "++++++++++++++++++ create call history start +++++++++++++++++++++++++++++",
      );
      print(response.data);

      print(
        "++++++++++++++++++ create call history end +++++++++++++++++++++++++++++",
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

  Future createProduct(data) async {
    try {
      final response = await DioUtil.dio.post(
        "$link/product",
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      print("+++++++++++++++Product++++++++++++++++++++++++++++++++");
      print(response.data);
      print("+++++++++++++++++++++++++++++++++++++++++++++++");

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

  Future<AllLeadsResponse> getAllLeads({
    //2 not getting data*********************************************
    int page = 1,
    DateTime? startDate,
    DateTime? endDate,
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

  //
  Future<DashboardDataRes> getDashboard({
    //3 not getting data*********************************************
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
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
      //previous - $link/dashboard/all",
      //now - $link/dashboard/call-duration/userId",

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

  //
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

  Future<AllMissedFupsRes> getMissedFUps({String? currentDateTime}) async {
    try {
      final res = await DioUtil.dio.get(
        '$link/lead/followup/missed',
        queryParameters: {'currentTime': currentDateTime},
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
}
