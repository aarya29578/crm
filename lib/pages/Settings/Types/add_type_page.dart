import 'package:flutter/material.dart';
import 'package:crm_flutter/pages/Quotes/components/TextFields.dart';
import 'package:crm_flutter/pages/Settings/Types/type_controller.dart';
import 'package:crm_flutter/styles/text_styles.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';

class AddTypePage extends StatefulWidget {
  const AddTypePage({super.key});

  @override
  State<AddTypePage> createState() => _AddTypePageState();
}

class _AddTypePageState extends State<AddTypePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  TypeController typeController = Get.put(TypeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("Add Lead Types", style: whiteHeading),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            FormBuilder(
              key: _formKey,

              child: FormTextField(name: "name", label: "Enter Lead Type Name"),
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

                        //print(formData);

                        final formData = Map<String, dynamic>.from(
                          _formKey.currentState!.value,
                        );

                        typeController.createType(formData);
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
    );
  }
}
