import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_leads_response.dart' as lead_model;
import 'package:flutter/foundation.dart';

class LeadEditHelper {
  static Future<lead_model.Data> fetchLeadForEditing(String leadId) async {
    final normalizedLeadId = leadId.trim();
    if (normalizedLeadId.isEmpty) {
      throw ArgumentError.value(leadId, 'leadId', 'Lead ID is required');
    }

    debugPrint('Lead edit: fetching details for leadId=$normalizedLeadId');
    try {
      final response = await DioApi().getAllLeadDetails(normalizedLeadId);
      final details = response.data;
      if (response.success != true || details == null) {
        throw StateError('Complete lead details could not be loaded');
      }
      if (details.sId == null || details.sId!.isEmpty) {
        throw StateError('The lead details response did not include a lead ID');
      }
      if (details.sId != normalizedLeadId) {
        throw StateError(
          'The lead details response did not match the selected lead',
        );
      }

      final lead = lead_model.Data.fromJson({
        '_id': details.sId,
        'lead_source_id': details.leadSourceId?.toJson(),
        'sub_source_id': details.leadSubSourceId?.toJson(),
        'lead_stage_id': details.leadStageId?.toJson(),
        'sub_status_id': details.subStatusId?.toJson(),
        'name': details.name?.toJson(),
        'phone': details.phone,
        'email': details.email,
        'address': details.address,
        'pincode': details.pincode,
        'remarks': details.remarks,
        'campaign': details.compaignName?.toJson(),
        'assignedTo': details.assignedTo?.toJson(),
        'priority': details.priority,
        'age': details.age,
        'gender': details.gender,
        'company_name': details.companyName,
        'designation': details.designation,
        'website': details.website,
        'documents': details.documents
            .map((document) => document.toJson())
            .toList(),
        'customList': details.customList,
        'createdAt': details.createdAt,
        'updatedAt': details.updatedAt,
        'status': details.status,
        'location': details.location?.toJson(),
        'listId': details.listId,
        'followUpDate': details.followUpDate,
        'stageFieldValues': details.stageFieldValues,
        'timeline': details.timeline?.map((item) => item.toJson()).toList(),
      });
      debugPrint('Lead edit: details loaded for leadId=$normalizedLeadId');
      return lead;
    } catch (error) {
      debugPrint(
        'Lead edit: detail fetch failed for leadId=$normalizedLeadId '
        'error=$error',
      );
      rethrow;
    }
  }
}
