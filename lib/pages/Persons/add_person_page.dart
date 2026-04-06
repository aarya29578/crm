import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:crm_flutter/pages/Persons/persons_controller.dart';
import 'package:crm_flutter/styles/text_styles.dart';
import 'package:crm_flutter/widgets/multi-text-field.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:crm_flutter/api/response/all_persons_response.dart'
    as personRes;
//import 'package:drop_down_search_field/drop_down_search_field.dart';

class AddPersonPage extends StatefulWidget {
  final bool isEdit;
  final personRes.Data? personData;
  const AddPersonPage({super.key, this.isEdit = false, this.personData});

  @override
  State<AddPersonPage> createState() => _AddPersonPageState();
}

class _AddPersonPageState extends State<AddPersonPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  PersonsController pcontroller = Get.put(PersonsController());

  @override
  void initState() {
    super.initState(); // Always call super.initState() first
    if (widget.isEdit == true) {
      pcontroller.emails.value = widget.personData!.emails!;
      pcontroller.contacts.value = widget.personData!.contactNumbers!;
    }
    pcontroller.getAllOrganizations();
  }

  @override
  void dispose() {
    pcontroller.emails.value = [];
    pcontroller.contacts.value = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          "Enter Person Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0,
          ),
        ),
      ),
      body: FormBuilder(
        key: _formKey,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //Enter Name
                  Text("Enter Name:", style: blackHeading),
                  SizedBox(height: 8),
                  FormBuilderTextField(
                    name: 'name',
                    initialValue: widget.isEdit ? widget.personData!.name : "",
                    decoration: Decorate("Alice Smith"),
                    validator: FormBuilderValidators.required(),
                  ),

                  SizedBox(height: 20),

                  //Enter Email Id
                  Text("Enter up to 3 Email IDs:", style: blackHeading),
                  SizedBox(height: 8),

                  MultiTextFields(
                    name: 'emails',
                    label: 'Email',
                    mainList: pcontroller.emails,
                    formKey: _formKey,
                  ),
                  SizedBox(height: 10),

                  //Enter contact number
                  Text('Enter up to 3 Contact Numbers:', style: blackHeading),
                  const SizedBox(height: 8),
                  MultiTextFields(
                    name: 'contact_numbers',
                    label: '+91-9998979695',
                    mainList: pcontroller.contacts,
                    formKey: _formKey,
                  ),
                  SizedBox(height: 10),

                  //Enter Job Title
                  Text("Enter Job Title:", style: blackHeading),
                  SizedBox(height: 8),
                  FormBuilderTextField(
                    name: 'job_title',
                    initialValue: widget.isEdit == true
                        ? widget.personData!.jobTitle
                        : "",
                    decoration: Decorate("Manager"),
                    validator: FormBuilderValidators.required(),
                  ),

                  SizedBox(height: 10),

                  // Enter Organization
                  Text("Select Organization:", style: blackHeading),
                  SizedBox(height: 15),
                  // FormBuilderField<String>(
                  //   name:
                  //       'organization_id', // This will store the ID, not the name
                  //   initialValue: widget.isEdit
                  //       ? widget.personData?.organization?.sId
                  //       : null,
                  //   validator: FormBuilderValidators.required(
                  //     errorText: 'Please select an organization',
                  //   ),
                  //   builder: (FormFieldState<String?> field) {
                  //     final orgList =
                  //         pcontroller.allOrganizationRes.value.data ?? [];

                  //     // Find the initial organization name if in edit mode
                  //     String? initialName;
                  //     if (widget.isEdit &&
                  //         widget.personData?.organization?.sId != null) {
                  //       initialName = orgList
                  //           .firstWhereOrNull(
                  //             (org) =>
                  //                 org.sId ==
                  //                 widget.personData?.organization?.sId,
                  //           )
                  //           ?.name;
                  //     }

                  //     return DropdownSearch<String>(
                  //       items: orgList
                  //           .map((e) => e.name ?? 'Unnamed Organization')
                  //           .toList(),
                  //       selectedItem: initialName, // Display name initially
                  //       onChanged: (selectedName) {
                  //         if (selectedName == null) {
                  //           field.didChange(null);
                  //           return;
                  //         }

                  //         // Find the organization by name and store its ID
                  //         final selectedOrg = orgList.firstWhereOrNull(
                  //           (org) => org.name == selectedName,
                  //         );

                  //         field.didChange(
                  //           selectedOrg?.sId,
                  //         ); // Store ID in form data
                  //       },
                  //       decoratorProps: DropDownDecoratorProps(
                  //         decoration: InputDecoration(
                  //           labelText: "Select organization",
                  //           labelStyle: TextStyle(color: Colors.grey.shade500),
                  //           border: OutlineInputBorder(),
                  //           contentPadding: EdgeInsets.symmetric(
                  //             horizontal: 12,
                  //           ),
                  //           errorText: field.errorText,
                  //         ),
                  //       ),
                  //       popupProps: PopupProps.menu(
                  //         showSearchBox: true,
                  //         searchFieldProps: TextFieldProps(
                  //           decoration: InputDecoration(
                  //             hintText: "Search organizations...",
                  //             border: OutlineInputBorder(),
                  //             prefixIcon: Icon(Icons.search),
                  //           ),
                  //         ),
                  //         // Display organization names in the dropdown list
                  //         itemBuilder: (context, item, isSelected) {
                  //           return ListTile(
                  //             title: Text(item),
                  //             selected: isSelected,
                  //           );
                  //         },
                  //       ),
                  //     );
                  //   },
                  // ),

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

                              final formData = Map<String, dynamic>.from(
                                _formKey.currentState!.value,
                              );

                              // print("Add person page");
                              // print(formData);
                              formData['emails'] = pcontroller.emails;
                              formData['contact_numbers'] =
                                  pcontroller.contacts;
                              widget.isEdit == true
                                  ? pcontroller.updatePerson(
                                      formData,
                                      widget.personData!.sId,
                                    )
                                  : pcontroller.createPerson(formData);
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
