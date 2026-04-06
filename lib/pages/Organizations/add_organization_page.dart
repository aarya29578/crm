import 'package:flutter/material.dart';
import 'package:crm_flutter/pages/Organizations/organizations_controller.dart';
import 'package:crm_flutter/api/response/all_organizations_response.dart'
    as organizationRes;
import 'package:crm_flutter/styles/text_styles.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class AddOrganizationPage extends StatefulWidget {
  final bool isEdit;
  final organizationRes.Data? organizationData;

  const AddOrganizationPage({
    super.key,
    required this.isEdit,
    this.organizationData,
  });

  @override
  State<AddOrganizationPage> createState() => _AddOrganizationPageState();
}

class _AddOrganizationPageState extends State<AddOrganizationPage> {
  final _formKey = GlobalKey<FormBuilderState>();

  OrganizationsController orgController = Get.put(OrganizationsController());

  @override
  void initState() {
    super.initState(); // Always call super.initState() first
    orgController.getAllOrganizations();
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
        title: Text("Enter Organization Details", style: whiteHeading),
      ),
      body: FormBuilder(
        key: _formKey,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //Enter Organization Name
                Text("Enter Organization Name:", style: blackHeading),
                SizedBox(height: 8),
                FormBuilderTextField(
                  name: 'name',
                  initialValue: widget.isEdit
                      ? widget.organizationData!.name
                      : "",
                  decoration: Decorate("OpenAI Technologies"),
                  validator: FormBuilderValidators.required(),
                ),

                SizedBox(height: 20),

                //Enter Street
                Text("Enter Street:", style: blackHeading),
                SizedBox(height: 8),
                FormBuilderTextField(
                  name: 'street',
                  initialValue: widget.isEdit
                      ? widget.organizationData!.address!.street
                      : "",
                  decoration: Decorate("123 Innovation Road"),
                  maxLines: 2,
                  maxLength: 150,
                  keyboardType: TextInputType.multiline,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.maxLength(
                      150,
                      errorText: 'Street must be at most 150 characters',
                    ),
                  ]),
                ),

                SizedBox(height: 20),

                //Enter City
                Text("Enter City:", style: blackHeading),
                SizedBox(height: 8),
                FormBuilderTextField(
                  name: 'city',
                  initialValue: widget.isEdit
                      ? widget.organizationData!.address!.city
                      : "",
                  decoration: Decorate("Thane"),
                  validator: FormBuilderValidators.required(),
                ),

                SizedBox(height: 20),

                //Enter State
                Text("Enter State:", style: blackHeading),
                SizedBox(height: 8),
                FormBuilderTextField(
                  name: 'state',
                  initialValue: widget.isEdit
                      ? widget.organizationData!.address!.state
                      : "",
                  decoration: Decorate("Maharashtra"),
                  validator: FormBuilderValidators.required(),
                ),

                SizedBox(height: 20),

                //Enter Zip
                Text("Enter ZIP:", style: blackHeading),
                SizedBox(height: 8),
                FormBuilderTextField(
                  name: 'zip',
                  initialValue: widget.isEdit
                      ? widget.organizationData!.address!.zip
                      : "",
                  decoration: Decorate("400606"),
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.numeric(),
                    FormBuilderValidators.match(
                      RegExp(r'^\d{6}$'),
                      errorText: 'Enter a valid 6-digit ZIP',
                    ),
                  ]),
                ),

                SizedBox(height: 20),

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
                          if (_formKey.currentState?.saveAndValidate() ??
                              false) {
                            // var formData = _formKey.currentState!.value;
                            // final formData = Map<String, dynamic>.from(
                            //   _formKey.currentState!.value,
                            // );

                            final formData = _formKey.currentState!.value;
                            print(
                              "++++++++++++++++++++++++++++++++++++++++++++++++++",
                            );
                            print(formData);
                            // Structure the data as required
                            final structuredData = {
                              'name': formData['name'],
                              'address': {
                                'street': formData['street'],
                                'city': formData['city'],
                                'state': formData['state'],
                                'zip': formData['zip'],
                              },
                            };

                            print(structuredData);

                            //orgController.createOrganization(structuredData);
                            widget.isEdit == true
                                ? orgController.updateOrganization(
                                    structuredData,
                                    widget.organizationData!.sId,
                                  )
                                : orgController.createOrganization(
                                    structuredData,
                                  );
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
      ),
    );
  }
}

Decorate(text) {
  return InputDecoration(
    hintText: text,
    hintStyle: TextStyle(color: Colors.grey.shade500), // Add this line
    //label: Text(text, style: TextStyle(color: Colors.grey.shade400)),
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  );
}
