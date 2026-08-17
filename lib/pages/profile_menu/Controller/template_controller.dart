import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/all_campaigns_response.dart';
import 'package:crm_flutter/api/response/all_templates_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TemplateController extends GetxController {
  final DioApi _dioApi = DioApi();

  /// Loading
  RxBool isLoading = false.obs;
  RxBool isFetchingCampaigns = false.obs;
  RxBool isFetchingTemplates = false.obs;

  /// Template List
  RxList<TemplateData> templates = <TemplateData>[].obs;

  /// Campaign Dropdown
  RxList<CampaignData> campaigns = <CampaignData>[].obs;

  /// Selected Values
  RxString selectedCampaignId = ''.obs;
  RxString selectedChannel = 'sms'.obs;
  RxBool isActive = true.obs;

  /// Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchCampaigns();
    fetchTemplates();
  }

  void clearFields() {
    nameController.clear();
    bodyController.clear();
    selectedCampaignId.value = '';
    selectedChannel.value = 'sms';
    isActive.value = true;
  }

  @override
  void onClose() {
    nameController.dispose();
    bodyController.dispose();
    super.onClose();
  }

  Future<void> fetchCampaigns() async {
    try {
      isFetchingCampaigns.value = true;

      final response = await _dioApi.getAllCampaigns();

      campaigns.assignAll(response.data ?? []);
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isFetchingCampaigns.value = false;
    }
  }

  Future<void> createTemplate() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        "Validation",
        "Please enter template name",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedCampaignId.value.isEmpty) {
      Get.snackbar(
        "Validation",
        "Please select a campaign",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (bodyController.text.trim().isEmpty) {
      Get.snackbar(
        "Validation",
        "Please enter message body",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      final request = {
        "name": nameController.text.trim(),
        "body": bodyController.text.trim(),
        "channel": selectedChannel.value,
        "campaign_id": selectedCampaignId.value,
        "is_active": isActive.value,
      };

      await _dioApi.createTemplate(request);

      await fetchTemplates();

      clearFields();

      Get.back();

      Get.snackbar(
        "Success",
        "Template created successfully",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTemplates() async {
    try {
      isFetchingTemplates.value = true;

      final response = await _dioApi.getAllTemplates();

      templates.assignAll(response.data ?? []);
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isFetchingTemplates.value = false;
    }
  }

  Future<void> loadTemplateForEdit(String id) async {
    try {
      isLoading.value = true;

      final response = await _dioApi.getTemplate(id);

      final template = response.data;

      if (template == null) {
        throw Exception("Template data not found");
      }

      nameController.text = template.name ?? "";
      bodyController.text = template.body ?? "";

      selectedChannel.value = template.channel ?? "sms";

      selectedCampaignId.value = template.campaign?.sId ?? "";

      isActive.value = template.isActive ?? true;
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTemplate(String id) async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        "Validation",
        "Please enter template name",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedCampaignId.value.isEmpty) {
      Get.snackbar(
        "Validation",
        "Please select a campaign",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (bodyController.text.trim().isEmpty) {
      Get.snackbar(
        "Validation",
        "Please enter message body",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      final request = {
        "name": nameController.text.trim(),
        "body": bodyController.text.trim(),
        "channel": selectedChannel.value,
        "campaign_id": selectedCampaignId.value,
        "is_active": isActive.value,
      };

      await _dioApi.updateTemplate(id, request);

      await fetchTemplates();

      clearFields();

      Get.back();

      Get.snackbar(
        "Success",
        "Template updated successfully",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTemplate(String id) async {
    try {
      isLoading.value = true;

      await _dioApi.deleteTemplate(id);

      await fetchTemplates();

      Get.snackbar(
        "Success",
        "Template deleted successfully",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> recordTemplateUsage({
    required String leadId,
    required String templateId,
    required String channel,
  }) async {
    try {
      await _dioApi.recordTemplateUsage(
        leadId: leadId,
        templateId: templateId,
        channel: channel,
      );
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }
}
