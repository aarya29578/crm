import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:crm_flutter/styles/color_palette.dart';

import 'add_lead_controller.dart';

class AddLeadPage extends StatelessWidget {
  AddLeadPage({super.key});

  final AddLeadController controller = Get.put(AddLeadController());

  static const double _gap = 16;

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: ColorConstants.MainPurpleBackground,
          width: 2,
        ),
      ),
    );
  }

  Widget _textField(
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: _inputDecoration(label),
    );
  }

  Widget _attachmentSection() {
    return Obx(() {
      final files = controller.selectedFiles;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "Attachments",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),

            // Add File Button
            SizedBox(
              width: double.infinity,
              height: 50,

              child: OutlinedButton.icon(
                onPressed: controller.pickDocuments,

                icon: const Icon(Icons.attach_file),

                label: const Text("Add Attachment"),

                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: ColorConstants.MainPurpleBackground),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Selected Files
            if (files.isNotEmpty) ...[
              const SizedBox(height: 12),

              const Text(
                "Selected Files",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              ...List.generate(files.length, (index) {
                final file = files[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),

                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),

                  child: Row(
                    children: [
                      const Icon(Icons.insert_drive_file, size: 22),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(file.name, overflow: TextOverflow.ellipsis),
                      ),

                      IconButton(
                        onPressed: () {
                          controller.removeFile(index);
                        },

                        icon: const Icon(Icons.close, color: Colors.red),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstants.MainPurpleBackground,

        elevation: 0,

        iconTheme: const IconThemeData(color: Colors.white),

        title: const Text(
          "Add New Lead",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),

      body: Form(
        key: controller.formKey,

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;

              final bool isMobile = maxWidth < 600;

              final double columnWidth = isMobile
                  ? maxWidth
                  : (maxWidth - _gap) / 2;

              Widget field(Widget child, {double? width}) {
                return SizedBox(width: width ?? columnWidth, child: child);
              }

              Widget full(Widget child) {
                return SizedBox(width: maxWidth, child: child);
              }

              return Wrap(
                spacing: _gap,
                runSpacing: _gap,

                children: [
                  field(
                    _textField("First Name", controller.firstNameController),
                  ),

                  field(
                    _textField("Middle Name", controller.middleNameController),
                  ),

                  field(_textField("Last Name", controller.lastNameController)),

                  // SOURCE *
                  field(
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.source.value,

                        isExpanded: true,

                        decoration: _inputDecoration("Source *"),

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Source is required";
                          }

                          return null;
                        },

                        items: controller.sourceList.map((source) {
                          return DropdownMenuItem<String>(
                            value: source.sId,

                            child: Text(source.name ?? ""),
                          );
                        }).toList(),

                        onChanged: (value) {
                          controller.source.value = value;
                        },
                      ),
                    ),
                  ),

                  // ASSIGN USER *
                  field(
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.assignUser.value,

                        isExpanded: true,

                        decoration: _inputDecoration("Assign User *"),

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Assign User is required";
                          }

                          return null;
                        },

                        items: controller.assignUserList.map((user) {
                          return DropdownMenuItem<String>(
                            value: user["_id"]?.toString(),

                            child: Text(user["name"]?.toString() ?? ""),
                          );
                        }).toList(),

                        onChanged: (value) {
                          controller.assignUser.value = value;
                        },
                      ),
                    ),
                  ),

                  //  CAMPAIGN *
                  field(
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.campaign.value,

                        isExpanded: true,

                        decoration: _inputDecoration("Campaign *"),

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Campaign is required";
                          }

                          return null;
                        },

                        items: controller.campaignList.map((campaign) {
                          return DropdownMenuItem<String>(
                            value: campaign.sId,

                            child: Text(campaign.name ?? ""),
                          );
                        }).toList(),

                        onChanged: (value) {
                          controller.campaign.value = value;
                        },
                      ),
                    ),
                  ),

                  // RATING
                  field(
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.rating.value,

                        isExpanded: true,

                        decoration: _inputDecoration("Rating"),

                        items: controller.ratingList.map((item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),

                        onChanged: (value) {
                          controller.rating.value = value;
                        },
                      ),
                    ),
                  ),

                  // AGE
                  field(
                    _textField(
                      "Age",
                      controller.ageController,
                      keyboardType: TextInputType.number,
                    ),
                  ),

              // GENDER
                  field(
                    Padding(
                      padding: const EdgeInsets.only(top: 8),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Text(
                            "Gender",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 8),

                          Obx(
                            () => Wrap(
                              spacing: 12,

                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,

                                  children: [
                                    Radio<String>(
                                      value: "Male",

                                      groupValue: controller.gender.value,

                                      onChanged: (v) {
                                        if (v != null) {
                                          controller.gender.value = v;
                                        }
                                      },
                                    ),

                                    const Text("Male"),
                                  ],
                                ),

                                Row(
                                  mainAxisSize: MainAxisSize.min,

                                  children: [
                                    Radio<String>(
                                      value: "Female",

                                      groupValue: controller.gender.value,

                                      onChanged: (v) {
                                        if (v != null) {
                                          controller.gender.value = v;
                                        }
                                      },
                                    ),

                                    const Text("Female"),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  field(
                    _textField(
                      "Phone Number",
                      controller.phoneController,

                      keyboardType: TextInputType.phone,

                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Phone Number is required";
                        }

                        if (value.trim().length != 10) {
                          return "Enter a valid phone number";
                        }

                        return null;
                      },
                    ),
                  ),

                  field(
                    _textField(
                      "Email",
                      controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),

                  field(
                    _textField("Company Name", controller.companyController),
                  ),

                  field(
                    _textField("Designation", controller.designationController),
                  ),

                  full(
                    _textField(
                      "Address",
                      controller.addressController,
                      maxLines: 3,
                    ),
                  ),

                  field(
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.country.value,

                        isExpanded: true,

                        decoration: _inputDecoration("Country"),

                        items: controller.countryList.map((country) {
                          return DropdownMenuItem<String>(
                            value: country.sId,

                            child: Text(country.name ?? ""),
                          );
                        }).toList(),

                        onChanged: (value) {
                          controller.country.value = value;

                          if (value != null) {
                            controller.loadStates(value);
                          }
                        },
                      ),
                    ),
                  ),

                  field(
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.state.value,

                        isExpanded: true,

                        decoration: _inputDecoration("State"),

                        items: controller.stateList.map((state) {
                          return DropdownMenuItem<String>(
                            value: state.sId,

                            child: Text(state.name ?? ""),
                          );
                        }).toList(),

                        onChanged: (value) {
                          controller.state.value = value;

                          if (value != null) {
                            controller.loadCities(value);
                          }
                        },
                      ),
                    ),
                  ),

                  field(
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.city.value,

                        isExpanded: true,

                        decoration: _inputDecoration("City"),

                        items: controller.cityList.map((city) {
                          return DropdownMenuItem<String>(
                            value: city.sId,

                            child: Text(city.name ?? ""),
                          );
                        }).toList(),

                        onChanged: (value) {
                          controller.city.value = value;
                        },
                      ),
                    ),
                  ),

                  field(
                    _textField(
                      "Pincode",
                      controller.pincodeController,
                      keyboardType: TextInputType.number,
                    ),
                  ),

                  field(_textField("Website", controller.websiteController)),

                  field(
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.status.value,

                        isExpanded: true,

                        decoration: _inputDecoration("Status *"),

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Status is required";
                          }

                          return null;
                        },

                        items: controller.leadStageList.map((stage) {
                          return DropdownMenuItem<String>(
                            value: stage.sId,
                            child: Text(stage.name ?? ""),
                          );
                        }).toList(),

                        onChanged: (value) {
                          controller.status.value = value;

                          // Clear previously selected date/time
                          controller.statusDateTime.value = null;
                        },
                      ),
                    ),
                  ),

                  // Date & Time appears only after selecting Status
                  Obx(() {
                    if (controller.status.value == null ||
                        controller.status.value!.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return field(
                      InkWell(
                        onTap: () => controller.selectStatusDateTime(context),
                        child: InputDecorator(
                          decoration: _inputDecoration("Date & Time *"),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20),
                              const SizedBox(width: 10),

                              Expanded(
                                child: Text(
                                  controller.statusDateTime.value == null
                                      ? "Select date & time"
                                      : "${controller.statusDateTime.value!.day.toString().padLeft(2, '0')}/"
                                            "${controller.statusDateTime.value!.month.toString().padLeft(2, '0')}/"
                                            "${controller.statusDateTime.value!.year} "
                                            "${TimeOfDay.fromDateTime(controller.statusDateTime.value!).format(context)}",
                                  style: TextStyle(
                                    color:
                                        controller.statusDateTime.value == null
                                        ? Colors.grey
                                        : Colors.black,
                                  ),
                                ),
                              ),

                              const Icon(Icons.access_time),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  field(_textField("PNM", controller.pnmController)),

                  full(
                    _textField(
                      "Remarks",
                      controller.remarksController,
                      maxLines: 4,
                    ),
                  ),

                  full(_attachmentSection()),

                  SizedBox(
                    width: maxWidth,

                    child: isMobile
                        ? Column(
                            children: [
                              // Cancel
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(52),

                                  side: BorderSide(
                                    color: ColorConstants.MainPurpleBackground,
                                  ),

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),

                                onPressed: () => Get.back(),

                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: ColorConstants.MainPurpleBackground,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Create Lead
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      ColorConstants.MainPurpleBackground,

                                  foregroundColor: Colors.white,

                                  minimumSize: const Size.fromHeight(52),

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),

                                onPressed: () async {
                                  if (!controller.formKey.currentState!
                                      .validate()) {
                                    Get.snackbar(
                                      "Required Fields",
                                      "Please fill all required fields.",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );

                                    return;
                                  }

                                  await controller.createLead();
                                },

                                child: const Text(
                                  "Create Lead",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              // Cancel
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(52),

                                    side: BorderSide(
                                      color:
                                          ColorConstants.MainPurpleBackground,
                                    ),

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),

                                  onPressed: () => Get.back(),

                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color:
                                          ColorConstants.MainPurpleBackground,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 16),

                              // Create Lead
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        ColorConstants.MainPurpleBackground,

                                    foregroundColor: Colors.white,

                                    minimumSize: const Size.fromHeight(52),

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),

                                  onPressed: () async {
                                    if (!controller.formKey.currentState!
                                        .validate()) {
                                      Get.snackbar(
                                        "Required Fields",
                                        "Please fill all required fields.",
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );

                                      return;
                                    }

                                    await controller.createLead();
                                  },

                                  child: const Text(
                                    "Create Lead",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
