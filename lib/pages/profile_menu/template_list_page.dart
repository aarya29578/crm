import 'package:crm_flutter/pages/profile_menu/Controller/template_controller.dart';
import 'package:crm_flutter/pages/profile_menu/TemplateFormPage.dart';
import 'package:crm_flutter/pages/profile_menu/templateCard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TemplateListPage extends StatelessWidget {
  TemplateListPage({super.key});

  final TemplateController controller = Get.put(TemplateController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Templates")),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => TemplateFormPage());
        },
        child: const Icon(Icons.add),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.templates.isEmpty) {
          return const Center(child: Text("No Templates Found"));
        }

        return ListView.builder(
          itemCount: controller.templates.length,
          itemBuilder: (context, index) {
            final template = controller.templates[index];

            return TemplateCard(
              template: template,

              onEdit: () {
                Get.to(() => TemplateFormPage(templateId: template.sId));
              },

              onDelete: () {
                showDeleteDialog(context, template.sId!);
              },
            );
          },
        );
      }),
    );
  }

  void showDeleteDialog(BuildContext context, String templateId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Template"),
          content: const Text("Are you sure you want to delete this template?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);

                controller.deleteTemplate(templateId);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
