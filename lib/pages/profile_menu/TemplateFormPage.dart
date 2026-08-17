import 'package:crm_flutter/pages/profile_menu/Controller/template_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TemplateFormPage extends StatefulWidget {
  final String? templateId;

  const TemplateFormPage({
    super.key,
    this.templateId,
  });

  @override
  State<TemplateFormPage> createState() => _TemplateFormPageState();
}

class _TemplateFormPageState extends State<TemplateFormPage> {
  late TemplateController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.find<TemplateController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.templateId != null) {
        controller.loadTemplateForEdit(widget.templateId!);
      } else {
        controller.clearFields();
      }
    });
  }

  // --------------------------------------------------
  // Insert variable into Message Body
  // --------------------------------------------------

  Widget _variableButton({
    required String label,
    required String variable,
  }) {
    return OutlinedButton(
      onPressed: () {
        final textController = controller.bodyController;

        final text = textController.text;

        int start = textController.selection.start;
        int end = textController.selection.end;

        // If there is no valid cursor position,
        // insert the variable at the end.
        if (start < 0 || end < 0) {
          start = text.length;
          end = text.length;
        }

        final newText = text.replaceRange(
          start,
          end,
          variable,
        );

        textController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(
            offset: start + variable.length,
          ),
        );
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.templateId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? "Edit Template" : "Create Template",
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            // --------------------------------------------------
            // Template Name
            // --------------------------------------------------

            TextFormField(
              controller: controller.nameController,
              decoration: const InputDecoration(
                labelText: "Template Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // --------------------------------------------------
            // Campaign
            // --------------------------------------------------

            Obx(() {
              return DropdownButtonFormField<String>(
                initialValue: controller.selectedCampaignId.value.isEmpty
                    ? null
                    : controller.selectedCampaignId.value,

                decoration: const InputDecoration(
                  labelText: "Campaign",
                  border: OutlineInputBorder(),
                ),

                items: controller.campaigns.map((campaign) {
                  return DropdownMenuItem<String>(
                    value: campaign.sId,
                    child: Text(
                      campaign.name ?? "",
                    ),
                  );
                }).toList(),

                onChanged: (value) {
                  if (value != null) {
                    controller.selectedCampaignId.value = value;
                  }
                },
              );
            }),

            const SizedBox(height: 20),

            // --------------------------------------------------
            // Channel
            // --------------------------------------------------

            Obx(() {
              return DropdownButtonFormField<String>(
                initialValue: controller.selectedChannel.value,

                decoration: const InputDecoration(
                  labelText: "Channel",
                  border: OutlineInputBorder(),
                ),

                items: const [
                  DropdownMenuItem(
                    value: "sms",
                    child: Text("SMS"),
                  ),
                  DropdownMenuItem(
                    value: "whatsapp",
                    child: Text("WhatsApp"),
                  ),
                  DropdownMenuItem(
                    value: "both",
                    child: Text("Both"),
                  ),
                ],

                onChanged: (value) {
                  if (value != null) {
                    controller.selectedChannel.value = value;
                  }
                },
              );
            }),

            const SizedBox(height: 20),

            // --------------------------------------------------
            // Message Body + Variables
            // --------------------------------------------------

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                TextFormField(
                  controller: controller.bodyController,
                  maxLines: 6,

                  decoration: const InputDecoration(
                    labelText: "Message Body",
                    hintText:
                        "Hello {{customer_name}}, your agent {{agent_name}} will contact you.",
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Insert Variable",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [

                    // Customer Name
                    _variableButton(
                      label: "Customer Name",
                      variable: "{{customer_name}}",
                    ),

                    // Agent Name
                    _variableButton(
                      label: "Agent Name",
                      variable: "{{agent_name}}",
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --------------------------------------------------
            // Active
            // --------------------------------------------------

            Obx(() {
              return SwitchListTile(
                title: const Text("Active"),

                value: controller.isActive.value,

                onChanged: (value) {
                  controller.isActive.value = value;
                },
              );
            }),

            const SizedBox(height: 30),

            // --------------------------------------------------
            // Save / Update
            // --------------------------------------------------

            SizedBox(
              width: double.infinity,
              height: 50,

              child: Obx(() {
                return ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          if (isEdit) {
                            controller.updateTemplate(
                              widget.templateId!,
                            );
                          } else {
                            controller.createTemplate();
                          }
                        },

                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 22,
                          width: 22,

                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isEdit ? "Update" : "Save",
                        ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}