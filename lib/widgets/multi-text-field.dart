import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

MultiTextFields({
  required String name,
  required String label,
  required List<String> mainList,
  required formKey,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: FormBuilderTextField(
              name: name,
              decoration: InputDecoration(
                hintText: label,
                hintStyle: TextStyle(color: Colors.grey.shade500),
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
              ),
              keyboardType:
                  name == 'contact_numbers'
                      ? TextInputType.phone
                      : TextInputType.emailAddress,
            ),
          ),
          SizedBox(width: 5),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(2),
              backgroundColor: Colors.white,
              elevation: 1,
            ),
            onPressed: () {
              formKey.currentState!.save();

              void showError(String message) {
                showDialog(
                  context: formKey.currentContext!,
                  builder:
                      (context) => AlertDialog(
                        title: Text('Invalid Entry'),
                        content: Text(message),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('OK'),
                          ),
                        ],
                      ),
                );
              }

              final input = formKey.currentState!.value[name]?.trim();

              if (input == null || input.isEmpty) {
                showError("${label} cannot be empty.");
                return;
              }

              if (mainList.length >= 3) {
                showError("You can only add up to 3 ${label.toLowerCase()}s.");
                return;
              }

              if (name == 'contact_numbers') {
                final isValid =
                    RegExp(r'^[\d+-]+$').hasMatch(input) &&
                    input.length >= 10 &&
                    input.length <= 15;

                if (!isValid) {
                  showError(
                    "Invalid contact number. Only digits, '+' and '-' allowed. Length must be between 10 and 15.",
                  );
                  return;
                }
              }

              if (name == 'emails') {
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(input)) {
                  showError("Please enter a valid email address.");
                  return;
                }
              }

              mainList.add(input);
              formKey.currentState!.fields[name]?.reset();
            },
            child: Text(
              "Add",
              style: TextStyle(
                color: Colors.blueAccent,
                letterSpacing: 0,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      if (mainList.isNotEmpty)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              mainList
                  .map(
                    (e) => Chip(
                      label: Text(e, style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.blue,
                      deleteIcon: Icon(Icons.close, color: Colors.white),
                      onDeleted: () {
                        mainList.remove(e);
                      },
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  )
                  .toList(),
        ),
    ],
  );
}
