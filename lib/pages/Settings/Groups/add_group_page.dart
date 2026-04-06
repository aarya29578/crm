import 'package:flutter/material.dart';
import 'package:crm_flutter/pages/Quotes/components/TextFields.dart';
import 'package:crm_flutter/pages/Settings/Groups/group_controller.dart';
import 'package:crm_flutter/styles/text_styles.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:crm_flutter/api/response/all_groups_response.dart' as groupRes;

class AddGroupPage extends StatefulWidget {
  final bool isEdit;
  final groupRes.Data? groupData;
  AddGroupPage({super.key, required this.isEdit, this.groupData});

  @override
  State<AddGroupPage> createState() => _AddGroupPageState();
}

class _AddGroupPageState extends State<AddGroupPage> {
  final _formKey = GlobalKey<FormBuilderState>();

  GroupController groupController = Get.put(GroupController());

  @override
  void initState() {
    super.initState();
    groupController.getAllGroups();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("Add Group Details", style: whiteHeading),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              FormTextField(
                name: "name",
                label: "Enter Name",
                initialValue: widget.isEdit ? widget.groupData?.name ?? "" : "",
              ),
              SizedBox(height: 20),
              FormTextField(
                name: "description",
                label: "Enter Group Description (150 characters)",
                initialValue: widget.isEdit
                    ? widget.groupData?.description ?? ""
                    : "",

                maxLength: 150,
                maxLines: 5,
              ),
              //Submit Button
              SizedBox(height: 50),
              Center(
                child: Center(
                  child: FractionallySizedBox(
                    widthFactor: 1, // 70% of the screen width
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.blueAccent),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.saveAndValidate()) {
                          //var formData = _formKey.currentState!.value;

                          // print(formData);
                          final formData = Map<String, dynamic>.from(
                            _formKey.currentState!.value,
                          );

                          //orgController.createOrganization(structuredData);
                          widget.isEdit == true
                              ? groupController.updateGroup(
                                  formData,
                                  widget.groupData!.sId,
                                )
                              : groupController.createGroup(formData);
                        }
                      },

                      child: Text(
                        "Submit",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
