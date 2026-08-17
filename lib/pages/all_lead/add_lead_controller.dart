import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:crm_flutter/api/dio_api.dart';
import 'package:crm_flutter/api/response/location_response.dart';
import 'package:crm_flutter/api/response/all_sources_response.dart'
    as source_model;
import 'package:crm_flutter/api/response/all_campaigns_response.dart';
import 'package:crm_flutter/api/response/all_lead_stage_response.dart'
    as stage_model;

class AddLeadController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final lastNameController = TextEditingController();

  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  final companyController = TextEditingController();
  final designationController = TextEditingController();

  final addressController = TextEditingController();
  final pincodeController = TextEditingController();
  final websiteController = TextEditingController();

  final ageController = TextEditingController();
  final remarksController = TextEditingController();
  final pnmController = TextEditingController();

  final source = RxnString();
  final campaign = RxnString();
  final assignUser = RxnString();
  final rating = RxnString();

  final country = RxnString();
  final state = RxnString();
  final city = RxnString();

  final status = RxnString();
  final statusDateTime = Rxn<DateTime>();

  final RxList<LocationData> countryList = <LocationData>[].obs;

  final RxList<LocationData> stateList = <LocationData>[].obs;

  final RxList<LocationData> cityList = <LocationData>[].obs;

  final RxList<Map<String, dynamic>> assignUserList =
      <Map<String, dynamic>>[].obs;

  final List<String> ratingList = const [
    "None",
    "Hot",
    "Warm",
    "Cold",
    "Very Hot",
    "Dead",
  ];

  final RxList<source_model.Data> sourceList = <source_model.Data>[].obs;

  final RxList<CampaignData> campaignList = <CampaignData>[].obs;

  final RxList<stage_model.Data> leadStageList = <stage_model.Data>[].obs;

  final gender = "".obs;

  final RxList<PlatformFile> selectedFiles = <PlatformFile>[].obs;

  @override
  void onInit() {
    super.onInit();

    loadSources();
    loadCampaigns();
    loadLeadStages();
    loadCountries();
    loadAssignUsers();
  }

  Future<void> pickDocuments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          "pdf",
          "doc",
          "docx",
          "xls",
          "xlsx",
          "jpg",
          "jpeg",
          "png",
        ],
      );

      if (result == null) {
        return;
      }

      selectedFiles.addAll(result.files);

      Get.snackbar(
        "Files Selected",
        "${result.files.length} file(s) selected",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Unable to select files: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void removeFile(int index) {
    if (index >= 0 && index < selectedFiles.length) {
      selectedFiles.removeAt(index);
    }
  }

  Future<void> loadSources() async {
    try {
      final response = await DioApi().getAllSources();

      sourceList.assignAll(response.data ?? []);

      print("========== SOURCES ==========");
      print(sourceList.length);
      print("=============================");
    } catch (e) {
      print("Load Source Error: $e");
    }
  }

  Future<void> loadCampaigns() async {
    try {
      final response = await DioApi().getAllCampaigns();

      campaignList.assignAll(response.data ?? []);

      print("========== CAMPAIGNS ==========");
      print(campaignList.length);
      print("===============================");
    } catch (e) {
      print("Load Campaign Error: $e");
    }
  }

  Future<void> loadLeadStages() async {
    try {
      final response = await DioApi().getAllLeadStage();

      leadStageList.assignAll(response.data ?? []);

      print("========== LEAD STAGES ==========");
      print(leadStageList.length);
      print("=================================");
    } catch (e) {
      print("Load Lead Stage Error: $e");
    }
  }

  Future<void> loadCountries() async {
    try {
      final response = await DioApi().getCountries();

      countryList.assignAll(response.data ?? []);

      print("Countries Loaded : ${countryList.length}");
    } catch (e) {
      print("Country Error : $e");
    }
  }

  Future<void> loadStates(String countryId) async {
    try {
      state.value = null;
      city.value = null;

      stateList.clear();
      cityList.clear();

      final response = await DioApi().getStates(countryId);

      stateList.assignAll(response.data ?? []);
    } catch (e) {
      print("State Error : $e");
    }
  }

  Future<void> loadCities(String stateId) async {
    try {
      city.value = null;

      cityList.clear();

      final response = await DioApi().getCities(stateId);

      cityList.assignAll(response.data ?? []);

      print("Cities Loaded : ${cityList.length}");
    } catch (e) {
      print("City Error : $e");
    }
  }

  Future<void> createLead() async {
    try {
      final body = {
        "lead_source_id": source.value,

        "campaign": campaign.value,

        "lead_stage_id": status.value,

        "assignedTo": assignUser.value,

        "name": {
          "first": firstNameController.text.trim(),
          "middle": middleNameController.text.trim(),
          "last": lastNameController.text.trim(),
        },

        "phone": int.tryParse(phoneController.text.trim()),

        "email": emailController.text.trim(),

        "location": {
          "country": country.value,
          "state": state.value,
          "city": city.value,
        },

        "address": addressController.text.trim(),

        "pincode": int.tryParse(pincodeController.text.trim()),

        "remarks": remarksController.text.trim(),

        "priority": rating.value,

        "age": int.tryParse(ageController.text.trim()),

        "gender": gender.value,

        "company_name": companyController.text.trim(),

        "designation": designationController.text.trim(),

        "website": websiteController.text.trim(),
      };

      final documentPaths = selectedFiles
          .where((file) => file.path != null)
          .map((file) => file.path!)
          .toList();

      await DioApi().createLead(body, documentFiles: documentPaths);

      clearForm();

      Get.snackbar(
        "Success",
        "Lead created successfully",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print("CREATE LEAD ERROR: $e");

      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future loadAssignUsers() async {
    try {
      final response = await DioApi().getAllUsers();

      print("========== ASSIGN USERS RESPONSE ==========");
      print(response.data);

      if (response.data is List) {
        assignUserList.assignAll(
          List<Map<String, dynamic>>.from(response.data),
        );
      } else if (response.data is Map) {
        final data = response.data["data"];

        if (data is List) {
          assignUserList.assignAll(List<Map<String, dynamic>>.from(data));
        }
      }

      print("Assign Users Loaded : ${assignUserList.length}");

      for (final user in assignUserList) {
        print("${user["_id"]} - ${user["name"]}");
      }

      print("============================================");
    } catch (e) {
      print("Assign User Error : $e");
    }
  }

  Future<void> selectStatusDateTime(BuildContext context) async {
    final now = DateTime.now();

    // First select date
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) {
      return;
    }

    // Select time
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );

    if (selectedTime == null) {
      return;
    }

    final selectedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // Don't allow past date/time
    if (selectedDateTime.isBefore(DateTime.now())) {
      Get.snackbar(
        "Invalid Date & Time",
        "Please select a future date and time.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    statusDateTime.value = selectedDateTime;
  }

  void clearForm() {
    firstNameController.clear();
    middleNameController.clear();
    lastNameController.clear();
    statusDateTime.value = null;

    phoneController.clear();
    emailController.clear();

    companyController.clear();
    designationController.clear();

    addressController.clear();
    pincodeController.clear();
    websiteController.clear();

    ageController.clear();
    remarksController.clear();
    pnmController.clear();

    gender.value = "Male";

    source.value = null;
    campaign.value = null;
    assignUser.value = null;
    rating.value = null;

    country.value = null;
    state.value = null;
    city.value = null;

    status.value = null;

    stateList.clear();
    cityList.clear();

    selectedFiles.clear();

    loadCountries();
  }

  void onClose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();

    phoneController.dispose();
    emailController.dispose();

    companyController.dispose();
    designationController.dispose();

    addressController.dispose();
    pincodeController.dispose();
    websiteController.dispose();

    ageController.dispose();
    remarksController.dispose();
    pnmController.dispose();

    super.onClose();
  }
}
